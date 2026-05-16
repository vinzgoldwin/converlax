import { feedbackJsonSchema, feedbackResponseSchema } from "./schema.js";

export class UpstreamError extends Error {
  constructor(code, message, statusCode = 502, retryable = true) {
    super(message);
    this.name = "UpstreamError";
    this.code = code;
    this.statusCode = statusCode;
    this.retryable = retryable;
  }
}

const SYSTEM_PROMPT = [
  "You are Converlax's calm speaking-practice coach.",
  "Give concise, practical feedback for English speaking practice.",
  "If the target language is not English, write feedback in simple English and correct the learner's target-language phrase.",
  "The input is a speech-recognition transcript, not audio. Do not claim you heard sounds, accent, volume, or exact pronunciation.",
  "Pronunciation notes must be based on transcript limitations: rhythm, word endings, stress, pauses, and likely clarity.",
  "Be encouraging without being fluffy. Prefer one clear next action."
].join(" ");

function buildUserPrompt(input) {
  return [
    "Return only JSON that matches the provided schema.",
    "Evaluate this spoken attempt for a language learner.",
    "",
    JSON.stringify({
      transcript: input.transcript,
      context: input.context ?? {}
    }, null, 2)
  ].join("\n");
}

function safeParseJson(text) {
  try {
    return JSON.parse(text);
  } catch {
    return null;
  }
}

function upstreamErrorFromStatus(status, bodyText) {
  const parsed = safeParseJson(bodyText);
  const upstreamMessage = parsed?.error?.message;
  const message = upstreamMessage || "OpenRouter did not return a successful response.";

  switch (status) {
    case 401:
    case 403:
      return new UpstreamError("OPENROUTER_AUTH_FAILED", "OpenRouter credentials are not accepted.", 503, false);
    case 402:
      return new UpstreamError("OPENROUTER_PAYMENT_REQUIRED", "OpenRouter account credits are unavailable.", 503, false);
    case 408:
      return new UpstreamError("OPENROUTER_TIMEOUT", "OpenRouter timed out before returning feedback.", 504, true);
    case 413:
      return new UpstreamError("OPENROUTER_PAYLOAD_TOO_LARGE", "The transcript is too long for feedback.", 400, false);
    case 422:
      return new UpstreamError("OPENROUTER_REJECTED_REQUEST", message, 502, false);
    case 429:
      return new UpstreamError("OPENROUTER_RATE_LIMITED", "OpenRouter is rate limiting feedback requests.", 429, true);
    default:
      return new UpstreamError("OPENROUTER_ERROR", message, status >= 500 ? 502 : 400, status >= 500);
  }
}

function extractMessageContent(payload) {
  const content = payload?.choices?.[0]?.message?.content;
  if (typeof content === "string") {
    return content;
  }
  if (content && typeof content === "object") {
    return JSON.stringify(content);
  }
  return "";
}

export async function requestOpenRouterFeedback(input, config, fetchImpl = fetch) {
  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), config.openRouterTimeoutMs);

  let response;
  try {
    response = await fetchImpl(`${config.openRouterBaseUrl}/chat/completions`, {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${config.openRouterApiKey}`,
        "Content-Type": "application/json",
        "HTTP-Referer": config.openRouterAppReferer,
        "X-OpenRouter-Title": config.openRouterAppTitle
      },
      body: JSON.stringify({
        model: config.openRouterModel,
        messages: [
          { role: "system", content: SYSTEM_PROMPT },
          { role: "user", content: buildUserPrompt(input) }
        ],
        temperature: 0.25,
        max_tokens: 700,
        response_format: {
          type: "json_schema",
          json_schema: {
            name: "converlax_speaking_feedback",
            strict: true,
            schema: feedbackJsonSchema
          }
        }
      }),
      signal: controller.signal
    });
  } catch (error) {
    if (error?.name === "AbortError") {
      throw new UpstreamError("OPENROUTER_TIMEOUT", "OpenRouter took too long to return feedback.", 504, true);
    }
    throw new UpstreamError("OPENROUTER_UNREACHABLE", "Could not reach OpenRouter.", 502, true);
  } finally {
    clearTimeout(timeout);
  }

  const bodyText = await response.text();
  if (!response.ok) {
    throw upstreamErrorFromStatus(response.status, bodyText);
  }

  const payload = safeParseJson(bodyText);
  if (!payload) {
    throw new UpstreamError("OPENROUTER_INVALID_JSON", "OpenRouter returned invalid JSON.", 502, true);
  }

  const messageContent = extractMessageContent(payload);
  const feedbackJson = safeParseJson(messageContent);
  if (!feedbackJson) {
    throw new UpstreamError("AI_FEEDBACK_INVALID_JSON", "The model returned feedback in an invalid format.", 502, true);
  }

  const parsed = feedbackResponseSchema.safeParse(feedbackJson);
  if (!parsed.success) {
    throw new UpstreamError("AI_FEEDBACK_INVALID_SCHEMA", "The model returned incomplete feedback.", 502, true);
  }

  return {
    feedback: parsed.data,
    upstream: {
      id: typeof payload.id === "string" ? payload.id : null,
      model: typeof payload.model === "string" ? payload.model : config.openRouterModel
    }
  };
}

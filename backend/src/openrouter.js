import {
  feedbackJsonSchema,
  feedbackResponseSchema,
  tutorJsonSchema,
  tutorResponseSchema
} from "./schema.js";

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

const TUTOR_SYSTEM_PROMPT = [
  "You are Converlax's calm conversational AI tutor for beginner English speaking practice.",
  "Stay focused on helping the learner say one useful English idea more clearly.",
  "Do not become a generic chatbot. Do not add lesson menus, analytics, confidence scores, or long explanations.",
  "Return a short natural tutor reply, one corrected or more natural version, and one focused next speaking prompt.",
  "Use recent context only to choose useful beginner practice. The learner's latest message is always the priority.",
  "If the message is off topic, gently steer it back to simple speaking practice."
].join(" ");

function buildFeedbackUserPrompt(input) {
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

function buildTutorUserPrompt(input) {
  return [
    "Return only JSON that matches the provided schema.",
    "Tutor this beginner English learner's latest message.",
    "",
    JSON.stringify({
      learnerMessage: input.message,
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
  return requestOpenRouterJson({
    input,
    config,
    fetchImpl,
    systemPrompt: SYSTEM_PROMPT,
    userPrompt: buildFeedbackUserPrompt(input),
    schemaName: "converlax_speaking_feedback",
    jsonSchema: feedbackJsonSchema,
    responseSchema: feedbackResponseSchema,
    invalidJsonCode: "AI_FEEDBACK_INVALID_JSON",
    invalidSchemaCode: "AI_FEEDBACK_INVALID_SCHEMA",
    resultKey: "feedback",
    maxTokens: 700,
    temperature: 0.25
  });
}

export async function requestOpenRouterTutor(input, config, fetchImpl = fetch) {
  return requestOpenRouterJson({
    input,
    config,
    fetchImpl,
    systemPrompt: TUTOR_SYSTEM_PROMPT,
    userPrompt: buildTutorUserPrompt(input),
    schemaName: "converlax_tutor_response",
    jsonSchema: tutorJsonSchema,
    responseSchema: tutorResponseSchema,
    invalidJsonCode: "AI_TUTOR_INVALID_JSON",
    invalidSchemaCode: "AI_TUTOR_INVALID_SCHEMA",
    resultKey: "tutor",
    maxTokens: 420,
    temperature: 0.35
  });
}

async function requestOpenRouterJson({
  config,
  fetchImpl,
  systemPrompt,
  userPrompt,
  schemaName,
  jsonSchema,
  responseSchema,
  invalidJsonCode,
  invalidSchemaCode,
  resultKey,
  maxTokens,
  temperature
}) {
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
          { role: "system", content: systemPrompt },
          { role: "user", content: userPrompt }
        ],
        temperature,
        max_tokens: maxTokens,
        response_format: {
          type: "json_schema",
          json_schema: {
            name: schemaName,
            strict: true,
            schema: jsonSchema
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
  const responseJson = safeParseJson(messageContent);
  if (!responseJson) {
    throw new UpstreamError(invalidJsonCode, "The model returned an invalid format.", 502, true);
  }

  const parsed = responseSchema.safeParse(responseJson);
  if (!parsed.success) {
    throw new UpstreamError(invalidSchemaCode, "The model returned incomplete tutor output.", 502, true);
  }

  return {
    [resultKey]: parsed.data,
    upstream: {
      id: typeof payload.id === "string" ? payload.id : null,
      model: typeof payload.model === "string" ? payload.model : config.openRouterModel
    }
  };
}

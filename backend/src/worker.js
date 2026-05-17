import { requestOpenRouterFeedback, requestOpenRouterTutor, UpstreamError } from "./openrouter.js";
import { feedbackRequestSchema, tutorRequestSchema } from "./schema.js";

const DEFAULT_TIMEOUT_MS = 15000;

function integerFromEnv(value, fallback) {
  const parsed = Number.parseInt(value ?? "", 10);
  return Number.isFinite(parsed) && parsed > 0 ? parsed : fallback;
}

function configFromEnv(env) {
  return {
    openRouterApiKey: env.OPENROUTER_API_KEY ?? "",
    openRouterBaseUrl: env.OPENROUTER_BASE_URL ?? "https://openrouter.ai/api/v1",
    openRouterModel: env.OPENROUTER_MODEL ?? "google/gemini-3.1-flash-lite",
    openRouterTimeoutMs: integerFromEnv(env.OPENROUTER_TIMEOUT_MS, DEFAULT_TIMEOUT_MS),
    openRouterAppReferer: env.OPENROUTER_APP_REFERER ?? "https://converlax.local",
    openRouterAppTitle: env.OPENROUTER_APP_TITLE ?? "Converlax"
  };
}

function jsonResponse(body, status = 200, extraHeaders = {}) {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      "Content-Type": "application/json",
      "Cache-Control": "no-store",
      ...extraHeaders
    }
  });
}

function corsHeaders(env) {
  const origin = env.CORS_ORIGIN?.trim();
  if (!origin) {
    return {};
  }

  return {
    "Access-Control-Allow-Origin": origin,
    "Access-Control-Allow-Methods": "GET,POST,OPTIONS",
    "Access-Control-Allow-Headers": "Content-Type"
  };
}

function publicError(code, message, retryable) {
  return {
    ok: false,
    error: {
      code,
      message,
      retryable
    }
  };
}

function validationErrorResponse(result) {
  return {
    ok: false,
    error: {
      code: "INVALID_REQUEST",
      message: "The feedback request is missing required fields or has invalid values.",
      retryable: false,
      details: result.error.issues.map((issue) => ({
        path: issue.path.join("."),
        message: issue.message
      }))
    }
  };
}

async function readJson(request) {
  const contentLength = Number.parseInt(request.headers.get("content-length") ?? "0", 10);
  if (Number.isFinite(contentLength) && contentLength > 32 * 1024) {
    return { tooLarge: true };
  }

  try {
    return { body: await request.json() };
  } catch {
    return { invalidJson: true };
  }
}

async function handleFeedback(request, env) {
  const bodyResult = await readJson(request);
  if (bodyResult.tooLarge) {
    return jsonResponse(publicError(
      "PAYLOAD_TOO_LARGE",
      "The feedback request is too large.",
      false
    ), 413, corsHeaders(env));
  }

  if (bodyResult.invalidJson) {
    return jsonResponse(publicError(
      "INVALID_JSON",
      "The feedback request body must be valid JSON.",
      false
    ), 400, corsHeaders(env));
  }

  const parsed = feedbackRequestSchema.safeParse(bodyResult.body);
  if (!parsed.success) {
    return jsonResponse(validationErrorResponse(parsed), 400, corsHeaders(env));
  }

  const config = configFromEnv(env);
  if (!config.openRouterApiKey) {
    return jsonResponse(publicError(
      "OPENROUTER_NOT_CONFIGURED",
      "AI feedback is not configured on the backend.",
      false
    ), 503, corsHeaders(env));
  }

  try {
    const result = await requestOpenRouterFeedback(parsed.data, config);
    return jsonResponse({
      ok: true,
      feedback: result.feedback,
      meta: {
        provider: "openrouter",
        model: result.upstream.model,
        requestId: result.upstream.id
      }
    }, 200, corsHeaders(env));
  } catch (error) {
    if (error instanceof UpstreamError) {
      return jsonResponse(publicError(error.code, error.message, error.retryable), error.statusCode, corsHeaders(env));
    }

    return jsonResponse(publicError(
      "INTERNAL_ERROR",
      "Feedback failed unexpectedly.",
      true
    ), 500, corsHeaders(env));
  }
}

async function handleTutor(request, env) {
  const bodyResult = await readJson(request);
  if (bodyResult.tooLarge) {
    return jsonResponse(publicError(
      "PAYLOAD_TOO_LARGE",
      "The tutor request is too large.",
      false
    ), 413, corsHeaders(env));
  }

  if (bodyResult.invalidJson) {
    return jsonResponse(publicError(
      "INVALID_JSON",
      "The tutor request body must be valid JSON.",
      false
    ), 400, corsHeaders(env));
  }

  const parsed = tutorRequestSchema.safeParse(bodyResult.body);
  if (!parsed.success) {
    return jsonResponse(validationErrorResponse(parsed), 400, corsHeaders(env));
  }

  const config = configFromEnv(env);
  if (!config.openRouterApiKey) {
    return jsonResponse(publicError(
      "OPENROUTER_NOT_CONFIGURED",
      "AI Tutor is not configured on the backend.",
      false
    ), 503, corsHeaders(env));
  }

  try {
    const result = await requestOpenRouterTutor(parsed.data, config);
    return jsonResponse({
      ok: true,
      tutor: result.tutor,
      meta: {
        provider: "openrouter",
        model: result.upstream.model,
        requestId: result.upstream.id
      }
    }, 200, corsHeaders(env));
  } catch (error) {
    if (error instanceof UpstreamError) {
      return jsonResponse(publicError(error.code, error.message, error.retryable), error.statusCode, corsHeaders(env));
    }

    return jsonResponse(publicError(
      "INTERNAL_ERROR",
      "Tutor failed unexpectedly.",
      true
    ), 500, corsHeaders(env));
  }
}

export default {
  async fetch(request, env) {
    const url = new URL(request.url);

    if (request.method === "OPTIONS") {
      return new Response(null, {
        status: 204,
        headers: corsHeaders(env)
      });
    }

    if (request.method === "GET" && url.pathname === "/health") {
      const config = configFromEnv(env);
      return jsonResponse({
        ok: true,
        service: "converlax-ai-feedback",
        openRouterConfigured: Boolean(config.openRouterApiKey),
        model: config.openRouterModel,
        runtime: "cloudflare-workers"
      }, 200, corsHeaders(env));
    }

    if (request.method === "POST" && url.pathname === "/v1/feedback") {
      return handleFeedback(request, env);
    }

    if (request.method === "POST" && url.pathname === "/v1/tutor") {
      return handleTutor(request, env);
    }

    return jsonResponse(publicError("NOT_FOUND", "Endpoint not found.", false), 404, corsHeaders(env));
  }
};

import Fastify from "fastify";
import cors from "@fastify/cors";
import rateLimit from "@fastify/rate-limit";
import { fileURLToPath } from "node:url";
import { loadConfig } from "./config.js";
import { requestOpenRouterFeedback, UpstreamError } from "./openrouter.js";
import { feedbackRequestSchema } from "./schema.js";

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

export async function buildServer({
  config = loadConfig(),
  fetchFeedback = requestOpenRouterFeedback
} = {}) {
  const app = Fastify({
    logger: {
      redact: ["req.headers.authorization", "headers.authorization"]
    },
    bodyLimit: 32 * 1024
  });

  await app.register(cors, {
    origin: config.corsOrigin
  });

  await app.register(rateLimit, {
    max: config.rateLimitMax,
    timeWindow: config.rateLimitWindow,
    errorResponseBuilder: () => publicError(
      "RATE_LIMITED",
      "Too many feedback requests. Please wait a moment and try again.",
      true
    )
  });

  app.get("/health", async () => ({
    ok: true,
    service: "converlax-ai-feedback",
    openRouterConfigured: Boolean(config.openRouterApiKey),
    model: config.openRouterModel
  }));

  app.post("/v1/feedback", async (request, reply) => {
    const parsed = feedbackRequestSchema.safeParse(request.body);
    if (!parsed.success) {
      return reply.code(400).send(validationErrorResponse(parsed));
    }

    if (!config.openRouterApiKey) {
      return reply.code(503).send(publicError(
        "OPENROUTER_NOT_CONFIGURED",
        "AI feedback is not configured on the backend.",
        false
      ));
    }

    const input = parsed.data;
    request.log.info({
      transcriptLength: input.transcript.length,
      mode: input.context?.mode ?? "unknown",
      lessonTitle: input.context?.lessonTitle ?? input.context?.roleplayTitle ?? "unknown"
    }, "feedback request accepted");

    try {
      const result = await fetchFeedback(input, config);
      return reply.send({
        ok: true,
        feedback: result.feedback,
        meta: {
          provider: "openrouter",
          model: result.upstream.model,
          requestId: result.upstream.id
        }
      });
    } catch (error) {
      if (error instanceof UpstreamError) {
        request.log.warn({ code: error.code, retryable: error.retryable }, "feedback upstream error");
        return reply.code(error.statusCode).send(publicError(error.code, error.message, error.retryable));
      }

      request.log.error({ err: error }, "feedback unexpected error");
      return reply.code(500).send(publicError(
        "INTERNAL_ERROR",
        "Feedback failed unexpectedly.",
        true
      ));
    }
  });

  return app;
}

async function start() {
  const config = loadConfig();
  const app = await buildServer({ config });

  try {
    await app.listen({ port: config.port, host: "0.0.0.0" });
  } catch (error) {
    app.log.error(error);
    process.exit(1);
  }
}

const currentFile = fileURLToPath(import.meta.url);
if (process.argv[1] === currentFile) {
  start();
}

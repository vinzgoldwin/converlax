const DEFAULT_PORT = 8787;
const DEFAULT_TIMEOUT_MS = 15000;

function integerFromEnv(value, fallback) {
  const parsed = Number.parseInt(value ?? "", 10);
  return Number.isFinite(parsed) && parsed > 0 ? parsed : fallback;
}

export function loadConfig(env = process.env) {
  return {
    port: integerFromEnv(env.PORT, DEFAULT_PORT),
    openRouterApiKey: env.OPENROUTER_API_KEY ?? "",
    openRouterBaseUrl: env.OPENROUTER_BASE_URL ?? "https://openrouter.ai/api/v1",
    openRouterModel: env.OPENROUTER_MODEL ?? "google/gemini-3.1-flash-lite",
    openRouterTimeoutMs: integerFromEnv(env.OPENROUTER_TIMEOUT_MS, DEFAULT_TIMEOUT_MS),
    openRouterAppReferer: env.OPENROUTER_APP_REFERER ?? "https://converlax.local",
    openRouterAppTitle: env.OPENROUTER_APP_TITLE ?? "Converlax",
    rateLimitMax: integerFromEnv(env.RATE_LIMIT_MAX, 30),
    rateLimitWindow: env.RATE_LIMIT_WINDOW ?? "1 minute",
    corsOrigin: env.CORS_ORIGIN?.trim() || false
  };
}

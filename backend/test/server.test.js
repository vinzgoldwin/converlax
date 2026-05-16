import test from "node:test";
import assert from "node:assert/strict";
import { buildServer } from "../src/server.js";

const baseConfig = {
  port: 8787,
  openRouterApiKey: "test-key",
  openRouterBaseUrl: "https://openrouter.ai/api/v1",
  openRouterModel: "test/model",
  openRouterTimeoutMs: 1000,
  openRouterAppReferer: "https://converlax.local",
  openRouterAppTitle: "Converlax",
  rateLimitMax: 100,
  rateLimitWindow: "1 minute",
  corsOrigin: false
};

const sampleFeedback = {
  overallSpeakingConfidence: 82,
  pronunciationNotes: "Keep the final word clear and pause before the question.",
  grammarCorrection: "I went to the store yesterday.",
  naturalVersion: "I went to the store yesterday. How about you?",
  vocabularyImprovement: "Use 'picked up' when you bought something quickly.",
  fluencyTip: "Say the first sentence, pause, then ask the follow-up question.",
  didWell: "You gave a complete idea.",
  tryNext: "Use the past tense 'went' in the next attempt.",
  suggestedSavedPhrase: "I went to the store yesterday.",
  reviewItemSuggestion: {
    prompt: "Say this in the past: I go to the store yesterday.",
    answer: "I went to the store yesterday."
  }
};

test("health reports service status without exposing secrets", async () => {
  const app = await buildServer({ config: baseConfig });
  const response = await app.inject({ method: "GET", url: "/health" });

  assert.equal(response.statusCode, 200);
  assert.deepEqual(response.json(), {
    ok: true,
    service: "converlax-ai-feedback",
    openRouterConfigured: true,
    model: "test/model"
  });

  await app.close();
});

test("feedback endpoint validates payloads", async () => {
  const app = await buildServer({ config: baseConfig });
  const response = await app.inject({
    method: "POST",
    url: "/v1/feedback",
    payload: { transcript: "" }
  });

  assert.equal(response.statusCode, 400);
  assert.equal(response.json().ok, false);
  assert.equal(response.json().error.code, "INVALID_REQUEST");

  await app.close();
});

test("feedback endpoint returns predictable JSON", async () => {
  const app = await buildServer({
    config: baseConfig,
    fetchFeedback: async () => ({
      feedback: sampleFeedback,
      upstream: {
        id: "gen-test",
        model: "test/model"
      }
    })
  });

  const response = await app.inject({
    method: "POST",
    url: "/v1/feedback",
    payload: {
      transcript: "I go to the store yesterday",
      context: {
        mode: "Free Talk",
        prompt: "Tell me about your day."
      }
    }
  });

  const body = response.json();
  assert.equal(response.statusCode, 200);
  assert.equal(body.ok, true);
  assert.deepEqual(body.feedback, sampleFeedback);
  assert.deepEqual(body.meta, {
    provider: "openrouter",
    model: "test/model",
    requestId: "gen-test"
  });

  await app.close();
});

test("feedback endpoint fails closed when backend key is missing", async () => {
  const app = await buildServer({
    config: {
      ...baseConfig,
      openRouterApiKey: ""
    }
  });

  const response = await app.inject({
    method: "POST",
    url: "/v1/feedback",
    payload: {
      transcript: "I go to the store yesterday"
    }
  });

  assert.equal(response.statusCode, 503);
  assert.equal(response.json().error.code, "OPENROUTER_NOT_CONFIGURED");

  await app.close();
});

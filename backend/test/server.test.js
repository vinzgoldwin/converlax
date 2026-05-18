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

const sampleTutor = {
  tutorReply: "Good. You're talking about yesterday, so use past tense.",
  correction: "I went to work yesterday, and I was tired.",
  naturalAlternative: "I had a long day at work yesterday.",
  nextPrompt: "Tell me why you were tired.",
  savedPhrase: "I went to work yesterday.",
  reviewItem: {
    prompt: "Say this in the past: I go to work yesterday.",
    answer: "I went to work yesterday."
  },
  mistakePattern: {
    id: "past-tense",
    title: "Past tense",
    explanation: "Use a past verb for yesterday or another finished time.",
    exampleLearnerSentence: "I go to work yesterday and I tired",
    correctedSentence: "I went to work yesterday, and I was tired.",
    confidence: 0.86
  },
  sessionSummary: {
    improvedPhrase: "I had a long day at work yesterday.",
    mistakePattern: "Past tense",
    savedReviewItem: "I went to work yesterday.",
    nextPrompt: "Tell me why you were tired."
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

test("tutor endpoint validates payloads", async () => {
  const app = await buildServer({ config: baseConfig });
  const response = await app.inject({
    method: "POST",
    url: "/v1/tutor",
    payload: { message: "" }
  });

  assert.equal(response.statusCode, 400);
  assert.equal(response.json().ok, false);
  assert.equal(response.json().error.code, "INVALID_REQUEST");

  await app.close();
});

test("tutor endpoint returns conversational tutor JSON", async () => {
  let capturedInput;
  const app = await buildServer({
    config: baseConfig,
    fetchTutor: async (input) => {
      capturedInput = input;
      return {
        tutor: sampleTutor,
        upstream: {
          id: "gen-tutor-test",
          model: "test/model"
        }
      };
    }
  });

  const response = await app.inject({
    method: "POST",
    url: "/v1/tutor",
    payload: {
      message: "I go to work yesterday and I tired",
      context: {
        currentLessonTitle: "Talk about yesterday",
        nextRecommendation: "Practice past tense",
        recentSavedPhrases: ["I was tired."],
        recurringMistakes: [{
          id: "past-tense",
          title: "Past tense",
          explanation: "Use a past verb for finished time.",
          exampleLearnerSentence: "I go yesterday.",
          correctedSentence: "I went yesterday.",
          count: 2,
          lastSeenDay: "2026-05-18",
          priorityScore: 0.88
        }],
        recentReviewPerformance: [{
          prompt: "I went yesterday.",
          source: "Tutor",
          lastReviewedDay: "2026-05-18",
          ease: 0.48,
          mistakeCount: 2,
          successCount: 0
        }]
      }
    }
  });

  const body = response.json();
  assert.equal(response.statusCode, 200);
  assert.equal(body.ok, true);
  assert.deepEqual(body.tutor, sampleTutor);
  assert.equal(capturedInput.message, "I go to work yesterday and I tired");
  assert.equal(capturedInput.context.currentLessonTitle, "Talk about yesterday");
  assert.equal(capturedInput.context.recurringMistakes[0].id, "past-tense");
  assert.deepEqual(body.meta, {
    provider: "openrouter",
    model: "test/model",
    requestId: "gen-tutor-test"
  });

  await app.close();
});

test("tutor endpoint fails closed when backend key is missing", async () => {
  const app = await buildServer({
    config: {
      ...baseConfig,
      openRouterApiKey: ""
    }
  });

  const response = await app.inject({
    method: "POST",
    url: "/v1/tutor",
    payload: {
      message: "I go to work yesterday"
    }
  });

  assert.equal(response.statusCode, 503);
  assert.equal(response.json().error.code, "OPENROUTER_NOT_CONFIGURED");

  await app.close();
});

import test from "node:test";
import assert from "node:assert/strict";
import worker from "../src/worker.js";

const baseEnv = {
  OPENROUTER_API_KEY: "test-key",
  OPENROUTER_BASE_URL: "https://openrouter.ai/api/v1",
  OPENROUTER_MODEL: "test/model",
  OPENROUTER_TIMEOUT_MS: "1000",
  OPENROUTER_APP_REFERER: "https://converlax.local",
  OPENROUTER_APP_TITLE: "Converlax"
};

const sampleTutor = {
  tutorReply: "Good. You're talking about yesterday, so use past tense.",
  correction: "I went to work yesterday.",
  naturalAlternative: "Yesterday, I went to work.",
  nextPrompt: "Say it again in past tense.",
  savedPhrase: "I went to work yesterday.",
  reviewItem: {
    prompt: "Say this in the past: I go to work yesterday.",
    answer: "I went to work yesterday."
  },
  mistakePattern: {
    id: "past-tense",
    title: "Past tense",
    explanation: "Use a past verb for yesterday or another finished time.",
    exampleLearnerSentence: "I go to work yesterday.",
    correctedSentence: "I went to work yesterday.",
    confidence: 0.86
  },
  sessionSummary: {
    improvedPhrase: "Yesterday, I went to work.",
    mistakePattern: "Past tense",
    savedReviewItem: "I went to work yesterday.",
    nextPrompt: "Say it again in past tense."
  }
};

function jsonRequest(path, body) {
  return new Request(`https://converlax.test${path}`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json"
    },
    body: JSON.stringify(body)
  });
}

test("worker exposes tutor endpoint", async () => {
  const originalFetch = globalThis.fetch;
  let capturedOpenRouterBody;

  globalThis.fetch = async (_url, init) => {
    capturedOpenRouterBody = JSON.parse(init.body);
    return new Response(JSON.stringify({
      id: "gen-worker-tutor-test",
      model: "test/model",
      choices: [
        {
          message: {
            content: JSON.stringify(sampleTutor)
          }
        }
      ]
    }), {
      status: 200,
      headers: {
        "Content-Type": "application/json"
      }
    });
  };

  try {
    const response = await worker.fetch(jsonRequest("/v1/tutor", {
      message: "I go to work yesterday",
      context: {
        targetLanguage: "English",
        proficiencyLevel: "beginner",
        currentLessonTitle: "Introduce yourself",
        recurringMistakes: [{
          id: "past-tense",
          title: "Past tense",
          explanation: "Use a past verb for finished time.",
          exampleLearnerSentence: "I go yesterday.",
          correctedSentence: "I went yesterday.",
          count: 2,
          lastSeenDay: "2026-05-18",
          priorityScore: 0.88
        }]
      }
    }), baseEnv);
    const body = await response.json();

    assert.equal(response.status, 200);
    assert.equal(body.ok, true);
    assert.deepEqual(body.tutor, sampleTutor);
    assert.equal(body.meta.provider, "openrouter");
    assert.equal(body.meta.requestId, "gen-worker-tutor-test");
    assert.equal(capturedOpenRouterBody.model, "test/model");
    assert.equal(capturedOpenRouterBody.messages[1].content.includes("I go to work yesterday"), true);
  } finally {
    globalThis.fetch = originalFetch;
  }
});

test("worker tutor endpoint validates payloads", async () => {
  const response = await worker.fetch(jsonRequest("/v1/tutor", {
    message: ""
  }), baseEnv);
  const body = await response.json();

  assert.equal(response.status, 400);
  assert.equal(body.ok, false);
  assert.equal(body.error.code, "INVALID_REQUEST");
});

test("worker tutor endpoint fails closed without backend key", async () => {
  const response = await worker.fetch(jsonRequest("/v1/tutor", {
    message: "I go to work yesterday"
  }), {
    ...baseEnv,
    OPENROUTER_API_KEY: ""
  });
  const body = await response.json();

  assert.equal(response.status, 503);
  assert.equal(body.ok, false);
  assert.equal(body.error.code, "OPENROUTER_NOT_CONFIGURED");
});

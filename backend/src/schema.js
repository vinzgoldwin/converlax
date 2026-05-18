import { z } from "zod";

const optionalText = z.string().trim().max(500).optional();
const mistakePatternSchema = z.object({
  id: z.string().trim().min(1).max(80),
  title: z.string().trim().min(1).max(80),
  explanation: z.string().trim().min(1).max(180),
  exampleLearnerSentence: z.string().trim().min(1).max(220),
  correctedSentence: z.string().trim().min(1).max(220),
  confidence: z.number().min(0).max(1).optional()
}).strict();

export const feedbackRequestSchema = z.object({
  transcript: z.string().trim().min(1).max(4000),
  context: z.object({
    mode: optionalText,
    lessonTitle: optionalText,
    prompt: optionalText,
    expectedPhrase: optionalText,
    targetLanguage: optionalText,
    proficiencyLevel: optionalText,
    roleplayTitle: optionalText,
    roleplaySetting: optionalText,
    usefulPhrases: z.array(z.string().trim().min(1).max(160)).max(8).optional()
  }).strict().default({}),
  clientRequestId: z.string().trim().max(80).optional()
}).strict();

export const tutorRequestSchema = z.object({
  message: z.string().trim().min(1).max(1200),
  context: z.object({
    targetLanguage: optionalText,
    proficiencyLevel: optionalText,
    currentLessonTitle: optionalText,
    currentLessonPrompt: optionalText,
    currentPrompt: optionalText,
    answeredPrompt: optionalText,
    turnCount: z.number().int().min(0).max(10).optional(),
    maxTurns: z.number().int().min(1).max(10).optional(),
    nextRecommendation: optionalText,
    recentSavedPhrases: z.array(z.string().trim().min(1).max(160)).max(8).optional(),
    recentTutorMessages: z.array(z.object({
      role: z.enum(["learner", "tutor"]),
      text: z.string().trim().min(1).max(360)
    }).strict()).max(8).optional(),
    conversationTurns: z.array(z.object({
      prompt: z.string().trim().min(1).max(160),
      learnerMessage: z.string().trim().min(1).max(360),
      tutorReply: z.string().trim().min(1).max(160),
      nextPrompt: z.string().trim().min(1).max(160),
      savedPhrase: z.string().trim().min(1).max(180).optional()
    }).strict()).max(5).optional(),
    recurringMistakes: z.array(z.object({
      id: z.string().trim().min(1).max(80),
      title: z.string().trim().min(1).max(80),
      explanation: z.string().trim().min(1).max(180),
      exampleLearnerSentence: z.string().trim().min(1).max(220),
      correctedSentence: z.string().trim().min(1).max(220),
      count: z.number().int().min(1).max(99),
      lastSeenDay: z.string().trim().min(1).max(20),
      priorityScore: z.number().min(0).max(1)
    }).strict()).max(3).optional(),
    recentReviewPerformance: z.array(z.object({
      prompt: z.string().trim().min(1).max(220),
      source: z.string().trim().min(1).max(120),
      lastReviewedDay: z.string().trim().min(1).max(20).optional(),
      ease: z.number().min(0).max(1),
      mistakeCount: z.number().int().min(0).max(99),
      successCount: z.number().int().min(0).max(99)
    }).strict()).max(5).optional()
  }).strict().default({}),
  clientRequestId: z.string().trim().max(80).optional()
}).strict();

export const feedbackResponseSchema = z.object({
  overallSpeakingConfidence: z.number().int().min(0).max(100),
  pronunciationNotes: z.string().trim().min(1).max(360),
  grammarCorrection: z.string().trim().min(1).max(360),
  naturalVersion: z.string().trim().min(1).max(360),
  vocabularyImprovement: z.string().trim().min(1).max(360),
  fluencyTip: z.string().trim().min(1).max(360),
  didWell: z.string().trim().min(1).max(240),
  tryNext: z.string().trim().min(1).max(240),
  suggestedSavedPhrase: z.string().trim().min(1).max(200),
  reviewItemSuggestion: z.object({
    prompt: z.string().trim().min(1).max(220),
    answer: z.string().trim().min(1).max(220)
  }).strict()
}).strict();

export const tutorResponseSchema = z.object({
  tutorReply: z.string().trim().min(1).max(120),
  correction: z.string().trim().min(1).max(280),
  naturalAlternative: z.string().trim().min(1).max(220),
  nextPrompt: z.string().trim().min(1).max(120),
  savedPhrase: z.string().trim().min(1).max(180),
  reviewItem: z.object({
    prompt: z.string().trim().min(1).max(220),
    answer: z.string().trim().min(1).max(220)
  }).strict(),
  mistakePattern: mistakePatternSchema,
  sessionSummary: z.object({
    improvedPhrase: z.string().trim().min(1).max(220),
    mistakePattern: z.string().trim().min(1).max(80),
    savedReviewItem: z.string().trim().min(1).max(220),
    nextPrompt: z.string().trim().min(1).max(160)
  }).strict()
}).strict();

export const feedbackJsonSchema = {
  type: "object",
  additionalProperties: false,
  required: [
    "overallSpeakingConfidence",
    "pronunciationNotes",
    "grammarCorrection",
    "naturalVersion",
    "vocabularyImprovement",
    "fluencyTip",
    "didWell",
    "tryNext",
    "suggestedSavedPhrase",
    "reviewItemSuggestion"
  ],
  properties: {
    overallSpeakingConfidence: {
      type: "integer",
      minimum: 0,
      maximum: 100,
      description: "The learner's overall speaking confidence score for this attempt."
    },
    pronunciationNotes: {
      type: "string",
      minLength: 1,
      maxLength: 360,
      description: "Pronunciation-oriented advice based only on transcript evidence, rhythm, stress, endings, and likely clarity."
    },
    grammarCorrection: {
      type: "string",
      minLength: 1,
      maxLength: 360,
      description: "A corrected version or a brief grammar note."
    },
    naturalVersion: {
      type: "string",
      minLength: 1,
      maxLength: 360,
      description: "A more natural spoken version."
    },
    vocabularyImprovement: {
      type: "string",
      minLength: 1,
      maxLength: 360,
      description: "A concise vocabulary upgrade the learner can use."
    },
    fluencyTip: {
      type: "string",
      minLength: 1,
      maxLength: 360,
      description: "One practical fluency tip for the next attempt."
    },
    didWell: {
      type: "string",
      minLength: 1,
      maxLength: 240,
      description: "One thing the learner did well."
    },
    tryNext: {
      type: "string",
      minLength: 1,
      maxLength: 240,
      description: "One small action to try next."
    },
    suggestedSavedPhrase: {
      type: "string",
      minLength: 1,
      maxLength: 200,
      description: "A useful phrase to save for future review."
    },
    reviewItemSuggestion: {
      type: "object",
      additionalProperties: false,
      required: ["prompt", "answer"],
      properties: {
        prompt: {
          type: "string",
          minLength: 1,
          maxLength: 220
        },
        answer: {
          type: "string",
          minLength: 1,
          maxLength: 220
        }
      }
    }
  }
};

export const tutorJsonSchema = {
  type: "object",
  additionalProperties: false,
  required: [
    "tutorReply",
    "correction",
    "naturalAlternative",
    "nextPrompt",
    "savedPhrase",
    "reviewItem",
    "mistakePattern",
    "sessionSummary"
  ],
  properties: {
    tutorReply: {
      type: "string",
      minLength: 1,
      maxLength: 120,
      description: "One short natural reply from a calm beginner English tutor. Under 16 words."
    },
    correction: {
      type: "string",
      minLength: 1,
      maxLength: 280,
      description: "A corrected or more natural version of the learner's message."
    },
    naturalAlternative: {
      type: "string",
      minLength: 1,
      maxLength: 220,
      description: "One short natural beginner-friendly version of the corrected idea."
    },
    nextPrompt: {
      type: "string",
      minLength: 1,
      maxLength: 120,
      description: "Exactly one focused speaking task. Under 12 words. No 'then' or multi-step prompts."
    },
    savedPhrase: {
      type: "string",
      minLength: 1,
      maxLength: 180,
      description: "A useful corrected phrase worth saving for future practice."
    },
    reviewItem: {
      type: "object",
      additionalProperties: false,
      required: ["prompt", "answer"],
      properties: {
        prompt: {
          type: "string",
          minLength: 1,
          maxLength: 220
        },
        answer: {
          type: "string",
          minLength: 1,
          maxLength: 220
        }
      }
    },
    mistakePattern: {
      type: "object",
      additionalProperties: false,
      required: ["id", "title", "explanation", "exampleLearnerSentence", "correctedSentence", "confidence"],
      properties: {
        id: {
          type: "string",
          minLength: 1,
          maxLength: 80,
          description: "Stable kebab-case mistake pattern id, such as past-tense or missing-to-be."
        },
        title: {
          type: "string",
          minLength: 1,
          maxLength: 80
        },
        explanation: {
          type: "string",
          minLength: 1,
          maxLength: 180,
          description: "Short learner-friendly explanation."
        },
        exampleLearnerSentence: {
          type: "string",
          minLength: 1,
          maxLength: 220
        },
        correctedSentence: {
          type: "string",
          minLength: 1,
          maxLength: 220
        },
        confidence: {
          type: "number",
          minimum: 0,
          maximum: 1
        }
      }
    },
    sessionSummary: {
      type: "object",
      additionalProperties: false,
      required: ["improvedPhrase", "mistakePattern", "savedReviewItem", "nextPrompt"],
      properties: {
        improvedPhrase: {
          type: "string",
          minLength: 1,
          maxLength: 220
        },
        mistakePattern: {
          type: "string",
          minLength: 1,
          maxLength: 80
        },
        savedReviewItem: {
          type: "string",
          minLength: 1,
          maxLength: 220
        },
        nextPrompt: {
          type: "string",
          minLength: 1,
          maxLength: 160
        }
      }
    }
  }
};

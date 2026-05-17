import { z } from "zod";

const optionalText = z.string().trim().max(500).optional();

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
    nextRecommendation: optionalText,
    recentSavedPhrases: z.array(z.string().trim().min(1).max(160)).max(8).optional(),
    recentTutorMessages: z.array(z.object({
      role: z.enum(["learner", "tutor"]),
      text: z.string().trim().min(1).max(360)
    }).strict()).max(8).optional()
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
  tutorReply: z.string().trim().min(1).max(280),
  correction: z.string().trim().min(1).max(280),
  nextPrompt: z.string().trim().min(1).max(220),
  savedPhrase: z.string().trim().min(1).max(180).optional(),
  reviewItem: z.object({
    prompt: z.string().trim().min(1).max(220),
    answer: z.string().trim().min(1).max(220)
  }).strict().optional()
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
  required: ["tutorReply", "correction", "nextPrompt"],
  properties: {
    tutorReply: {
      type: "string",
      minLength: 1,
      maxLength: 280,
      description: "One short natural reply from a calm beginner English tutor."
    },
    correction: {
      type: "string",
      minLength: 1,
      maxLength: 280,
      description: "A corrected or more natural version of the learner's message."
    },
    nextPrompt: {
      type: "string",
      minLength: 1,
      maxLength: 220,
      description: "One focused next speaking prompt. Keep it specific and speakable."
    },
    savedPhrase: {
      type: "string",
      minLength: 1,
      maxLength: 180,
      description: "Optional phrase worth saving for future practice."
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
    }
  }
};

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

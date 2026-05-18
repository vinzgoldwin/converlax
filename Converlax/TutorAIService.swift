import Foundation

struct TutorAIResponse: Codable, Hashable {
    let tutorReply: String
    let correction: String
    let naturalAlternative: String
    let nextPrompt: String
    let savedPhrase: String
    let reviewItem: TutorAIReviewItem
    let mistakePattern: TutorAIMistakePattern
    let sessionSummary: TutorAISessionSummary
}

struct TutorAIReviewItem: Codable, Hashable {
    let prompt: String
    let answer: String
}

struct TutorAIMistakePattern: Codable, Hashable {
    let id: String
    let title: String
    let explanation: String
    let exampleLearnerSentence: String
    let correctedSentence: String
    let confidence: Double?
}

struct TutorAISessionSummary: Codable, Hashable {
    let improvedPhrase: String
    let mistakePattern: String
    let savedReviewItem: String
    let nextPrompt: String
}

struct TutorAIMessageContext: Codable, Hashable {
    let role: String
    let text: String
}

struct TutorAITurnContext: Codable, Hashable {
    let prompt: String
    let learnerMessage: String
    let tutorReply: String
    let nextPrompt: String
    let savedPhrase: String?
}

struct TutorAIMistakePatternContext: Codable, Hashable {
    let id: String
    let title: String
    let explanation: String
    let exampleLearnerSentence: String
    let correctedSentence: String
    let count: Int
    let lastSeenDay: String
    let priorityScore: Double
}

struct TutorAIReviewPerformanceContext: Codable, Hashable {
    let prompt: String
    let source: String
    let lastReviewedDay: String?
    let ease: Double
    let mistakeCount: Int
    let successCount: Int
}

struct TutorAIRequestContext: Codable, Hashable {
    var targetLanguage: String?
    var proficiencyLevel: String?
    var currentLessonTitle: String?
    var currentLessonPrompt: String?
    var currentPrompt: String?
    var answeredPrompt: String?
    var turnCount: Int?
    var maxTurns: Int?
    var nextRecommendation: String?
    var recentSavedPhrases: [String]?
    var recentTutorMessages: [TutorAIMessageContext]?
    var conversationTurns: [TutorAITurnContext]?
    var recurringMistakes: [TutorAIMistakePatternContext]?
    var recentReviewPerformance: [TutorAIReviewPerformanceContext]?
}

private struct TutorAIRequestBody: Encodable {
    let message: String
    let context: TutorAIRequestContext
}

private struct TutorAIEnvelope: Decodable {
    let ok: Bool
    let tutor: TutorAIResponse?
    let error: AIFeedbackBackendError?
}

struct TutorAIService {
    static let shared = TutorAIService()

    private let baseURL: URL
    private let session: URLSession

    init(baseURL: URL? = Self.defaultBaseURL, session: URLSession = .shared) {
        self.baseURL = baseURL ?? URL(string: "https://converlax-ai-feedback.vinzgoldwin.workers.dev")!
        self.session = session
    }

    func response(message: String, context: TutorAIRequestContext) async throws -> TutorAIResponse {
        let cleanMessage = message.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanMessage.isEmpty else {
            throw AIFeedbackServiceError.invalidResponse
        }

        if ProcessInfo.processInfo.arguments.contains("-ConverlaxUseMockTutorAI") {
            return Self.mockResponse(for: cleanMessage)
        }

        let endpoint = baseURL.appendingPathComponent("v1/tutor")
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.timeoutInterval = 15
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(TutorAIRequestBody(message: cleanMessage, context: context))

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw AIFeedbackServiceError.transport(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AIFeedbackServiceError.invalidResponse
        }

        let envelope: TutorAIEnvelope
        do {
            envelope = try JSONDecoder().decode(TutorAIEnvelope.self, from: data)
        } catch {
            throw AIFeedbackServiceError.invalidResponse
        }

        if envelope.ok, let tutor = envelope.tutor {
            return tutor
        }

        if let error = envelope.error {
            throw AIFeedbackServiceError.backend(error, statusCode: httpResponse.statusCode)
        }

        throw AIFeedbackServiceError.invalidResponse
    }

    static func fallbackResponse(for message: String) -> TutorAIResponse {
        let cleanMessage = message.trimmingCharacters(in: .whitespacesAndNewlines)
        let corrected = localCorrection(for: cleanMessage)
        let naturalAlternative = localNaturalAlternative(for: cleanMessage, correction: corrected)
        let seed = MistakePatternDetector.detect(learnerSentence: cleanMessage, correctedSentence: corrected)
        let mistakePattern = TutorAIMistakePattern(seed: seed, learnerSentence: cleanMessage, correctedSentence: corrected)
        let reviewPrompt = reviewPrompt(for: seed, fallback: corrected)

        return TutorAIResponse(
            tutorReply: fallbackTutorReply(for: seed),
            correction: corrected,
            naturalAlternative: naturalAlternative,
            nextPrompt: "Say it one more time slowly.",
            savedPhrase: corrected,
            reviewItem: TutorAIReviewItem(prompt: reviewPrompt, answer: corrected),
            mistakePattern: mistakePattern,
            sessionSummary: TutorAISessionSummary(
                improvedPhrase: naturalAlternative,
                mistakePattern: mistakePattern.title,
                savedReviewItem: reviewPrompt,
                nextPrompt: "Say it one more time slowly."
            )
        )
    }

    static func fallbackMessage(for error: Error) -> String {
        AIFeedbackService.fallbackMessage(for: error).replacingOccurrences(of: "AI feedback", with: "AI Tutor")
    }

    private static func mockResponse(for message: String) -> TutorAIResponse {
        let corrected = "I went to work yesterday, and I was tired."
        let naturalAlternative = "I had a long day at work yesterday."
        return TutorAIResponse(
            tutorReply: "Good. You're talking about yesterday, so use past tense.",
            correction: corrected,
            naturalAlternative: naturalAlternative,
            nextPrompt: "Tell me why you were tired.",
            savedPhrase: "I went to work yesterday.",
            reviewItem: TutorAIReviewItem(
                prompt: "Say this in the past: I go to work yesterday.",
                answer: "I went to work yesterday."
            ),
            mistakePattern: TutorAIMistakePattern(
                id: "past-tense",
                title: "Past tense",
                explanation: "Use a past verb when you talk about yesterday or another finished time.",
                exampleLearnerSentence: message,
                correctedSentence: corrected,
                confidence: 0.86
            ),
            sessionSummary: TutorAISessionSummary(
                improvedPhrase: naturalAlternative,
                mistakePattern: "Past tense",
                savedReviewItem: "I went to work yesterday.",
                nextPrompt: "Tell me why you were tired."
            )
        )
    }

    private static func localCorrection(for message: String) -> String {
        let clean = message.trimmingCharacters(in: .whitespacesAndNewlines)
        let lower = clean.lowercased()
        if lower.contains("i go to work yesterday") && lower.contains("i tired") {
            return "I went to work yesterday, and I was tired."
        }
        if lower.contains("i go ") && lower.contains("yesterday") {
            return clean
                .replacingOccurrences(of: "I go", with: "I went")
                .replacingOccurrences(of: "i go", with: "I went")
                .appendingSentencePunctuation()
        }
        if lower.contains("i tired") {
            return clean
                .replacingOccurrences(of: "I tired", with: "I was tired")
                .replacingOccurrences(of: "i tired", with: "I was tired")
                .appendingSentencePunctuation()
        }
        return clean.appendingSentencePunctuation()
    }

    private static func localNaturalAlternative(for message: String, correction: String) -> String {
        let lower = message.lowercased()
        if lower.contains("work yesterday") && lower.contains("tired") {
            return "I had a long day at work yesterday."
        }
        if lower.contains("tired") {
            return "I was tired, so I took it slow."
        }
        return correction
    }

    private static func fallbackTutorReply(for seed: MistakePatternSeed?) -> String {
        guard let seed else {
            return "I can help with that. Keep it short and clear."
        }

        switch seed.id {
        case "past-tense":
            return "Good idea. Use past tense for yesterday."
        case "missing-to-be":
            return "Good start. Add the be verb."
        case "short-answer":
            return "Good start. Make it one complete sentence."
        default:
            return "Good start. Let's make it clearer."
        }
    }

    private static func reviewPrompt(for seed: MistakePatternSeed?, fallback: String) -> String {
        guard let seed else {
            return "Repeat this clear sentence."
        }

        switch seed.id {
        case "past-tense":
            return "Say this in the past: \(seed.exampleLearnerSentence)"
        case "missing-to-be":
            return "Add the be verb."
        case "missing-articles":
            return "Add a, an, or the where needed."
        case "subject-verb-agreement":
            return "Make the subject and verb agree."
        case "word-order":
            return "Fix the question word order."
        default:
            return fallback
        }
    }

    private static var defaultBaseURL: URL? {
        if let argument = ProcessInfo.processInfo.converlaxArgumentValue(after: "-ConverlaxTutorAIBaseURL"),
           let url = URL(string: argument) {
            return url
        }

        if let environmentValue = ProcessInfo.processInfo.environment["CONVERLAX_TUTOR_AI_BASE_URL"],
           let url = URL(string: environmentValue) {
            return url
        }

        if let argument = ProcessInfo.processInfo.converlaxArgumentValue(after: "-ConverlaxAIFeedbackBaseURL"),
           let url = URL(string: argument) {
            return url
        }

        return nil
    }
}

private extension String {
    func appendingSentencePunctuation() -> String {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "." }
        if [".", "?", "!"].contains(String(trimmed.suffix(1))) {
            return trimmed
        }
        return "\(trimmed)."
    }
}

extension TutorAIMistakePattern {
    init(seed: MistakePatternSeed) {
        self.init(
            id: seed.id,
            title: seed.title,
            explanation: seed.explanation,
            exampleLearnerSentence: seed.exampleLearnerSentence,
            correctedSentence: seed.correctedSentence,
            confidence: seed.confidence
        )
    }

    init(seed: MistakePatternSeed?, learnerSentence: String, correctedSentence: String) {
        if let seed {
            self.init(seed: seed)
        } else {
            self.init(
                id: "clarity",
                title: "Clear sentence",
                explanation: "Use one short complete sentence so your idea is easy to answer.",
                exampleLearnerSentence: learnerSentence,
                correctedSentence: correctedSentence,
                confidence: 0.5
            )
        }
    }

    func seed(defaultLearnerSentence: String, defaultCorrectedSentence: String) -> MistakePatternSeed? {
        let cleanID = id.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanExplanation = explanation.trimmingCharacters(in: .whitespacesAndNewlines)
        let learner = exampleLearnerSentence.trimmingCharacters(in: .whitespacesAndNewlines)
        let corrected = correctedSentence.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanID.isEmpty, !cleanTitle.isEmpty, !cleanExplanation.isEmpty else { return nil }

        return MistakePatternSeed(
            id: stablePatternID(cleanID),
            title: String(cleanTitle.prefix(80)),
            explanation: String(cleanExplanation.prefix(180)),
            exampleLearnerSentence: String((learner.isEmpty ? defaultLearnerSentence : learner).prefix(220)),
            correctedSentence: String((corrected.isEmpty ? defaultCorrectedSentence : corrected).prefix(220)),
            confidence: min(max(confidence ?? 0.68, 0), 1)
        )
    }

    private func stablePatternID(_ value: String) -> String {
        let characters = value.lowercased().map { character -> Character in
            character.isLetter || character.isNumber ? character : "-"
        }
        let collapsed = String(characters).split(separator: "-").joined(separator: "-")
        return String(collapsed.prefix(48)).isEmpty ? "pattern" : String(collapsed.prefix(48))
    }
}

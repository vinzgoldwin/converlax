import Foundation

struct TutorAIResponse: Codable, Hashable {
    let tutorReply: String
    let correction: String
    let nextPrompt: String
    let savedPhrase: String?
    let reviewItem: TutorAIReviewItem?
}

struct TutorAIReviewItem: Codable, Hashable {
    let prompt: String
    let answer: String
}

struct TutorAIMessageContext: Codable, Hashable {
    let role: String
    let text: String
}

struct TutorAIRequestContext: Codable, Hashable {
    var targetLanguage: String?
    var proficiencyLevel: String?
    var currentLessonTitle: String?
    var currentLessonPrompt: String?
    var nextRecommendation: String?
    var recentSavedPhrases: [String]?
    var recentTutorMessages: [TutorAIMessageContext]?
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
        let corrected = cleanMessage.hasSuffix(".") || cleanMessage.hasSuffix("?") || cleanMessage.hasSuffix("!")
            ? cleanMessage
            : "\(cleanMessage)."

        return TutorAIResponse(
            tutorReply: "I can help with that. Keep it short and say one clear idea.",
            correction: corrected,
            nextPrompt: "Say it one more time slowly.",
            savedPhrase: corrected,
            reviewItem: TutorAIReviewItem(prompt: "Say this more clearly.", answer: corrected)
        )
    }

    static func fallbackMessage(for error: Error) -> String {
        AIFeedbackService.fallbackMessage(for: error).replacingOccurrences(of: "AI feedback", with: "AI Tutor")
    }

    private static func mockResponse(for message: String) -> TutorAIResponse {
        TutorAIResponse(
            tutorReply: "Good. You're talking about yesterday, so use past tense.",
            correction: "I went to work yesterday, and I was tired.",
            nextPrompt: "Say it once more, then ask me: How was your day?",
            savedPhrase: "I went to work yesterday.",
            reviewItem: TutorAIReviewItem(
                prompt: "Say this in the past: I go to work yesterday.",
                answer: "I went to work yesterday."
            )
        )
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

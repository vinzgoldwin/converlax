import Foundation

struct AIFeedback: Codable, Hashable {
    let overallSpeakingConfidence: Int
    let pronunciationNotes: String
    let grammarCorrection: String
    let naturalVersion: String
    let vocabularyImprovement: String
    let fluencyTip: String
    let didWell: String
    let tryNext: String
    let suggestedSavedPhrase: String
    let reviewItemSuggestion: AIFeedbackReviewItem
}

struct AIFeedbackReviewItem: Codable, Hashable {
    let prompt: String
    let answer: String
}

struct AIFeedbackRequestContext: Codable, Hashable {
    var mode: String?
    var lessonTitle: String?
    var prompt: String?
    var expectedPhrase: String?
    var targetLanguage: String?
    var proficiencyLevel: String?
    var roleplayTitle: String?
    var roleplaySetting: String?
    var usefulPhrases: [String]?
}

private struct AIFeedbackRequestBody: Encodable {
    let transcript: String
    let context: AIFeedbackRequestContext
}

private struct AIFeedbackEnvelope: Decodable {
    let ok: Bool
    let feedback: AIFeedback?
    let error: AIFeedbackBackendError?
}

struct AIFeedbackBackendError: Decodable, Error {
    let code: String
    let message: String
    let retryable: Bool
}

enum AIFeedbackServiceError: LocalizedError {
    case invalidBackendURL
    case invalidResponse
    case backend(AIFeedbackBackendError, statusCode: Int)
    case transport(Error)

    var errorDescription: String? {
        switch self {
        case .invalidBackendURL:
            "AI feedback backend URL is invalid."
        case .invalidResponse:
            "AI feedback returned an invalid response."
        case .backend(let error, _):
            error.message
        case .transport:
            "AI feedback backend is unavailable."
        }
    }
}

struct AIFeedbackService {
    static let shared = AIFeedbackService()

    private let baseURL: URL
    private let session: URLSession

    init(baseURL: URL? = Self.defaultBaseURL, session: URLSession = .shared) {
        self.baseURL = baseURL ?? URL(string: "http://127.0.0.1:8787")!
        self.session = session
    }

    func feedback(transcript: String, context: AIFeedbackRequestContext) async throws -> AIFeedback {
        let cleanTranscript = transcript.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanTranscript.isEmpty else {
            throw AIFeedbackServiceError.invalidResponse
        }

        let endpoint = baseURL.appendingPathComponent("v1/feedback")
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.timeoutInterval = 15
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(AIFeedbackRequestBody(transcript: cleanTranscript, context: context))

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

        let envelope: AIFeedbackEnvelope
        do {
            envelope = try JSONDecoder().decode(AIFeedbackEnvelope.self, from: data)
        } catch {
            throw AIFeedbackServiceError.invalidResponse
        }

        if envelope.ok, let feedback = envelope.feedback {
            return feedback
        }

        if let error = envelope.error {
            throw AIFeedbackServiceError.backend(error, statusCode: httpResponse.statusCode)
        }

        throw AIFeedbackServiceError.invalidResponse
    }

    static func fallbackMessage(for error: Error) -> String {
        if let serviceError = error as? AIFeedbackServiceError {
            switch serviceError {
            case .backend(let backendError, _) where backendError.code == "RATE_LIMITED":
                return "AI feedback is busy. Showing local guidance for now."
            case .backend(let backendError, _) where !backendError.retryable:
                return "AI feedback is not configured. Showing local guidance."
            default:
                break
            }
        }

        return "AI feedback is unavailable. Showing local guidance."
    }

    private static var defaultBaseURL: URL? {
        if let argument = ProcessInfo.processInfo.converlaxArgumentValue(after: "-ConverlaxAIFeedbackBaseURL"),
           let url = URL(string: argument) {
            return url
        }

        if let environmentValue = ProcessInfo.processInfo.environment["CONVERLAX_AI_FEEDBACK_BASE_URL"],
           let url = URL(string: environmentValue) {
            return url
        }

        return URL(string: "http://127.0.0.1:8787")
    }
}

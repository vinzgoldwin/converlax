import SwiftUI

enum AppTab: Hashable {
    case home
    case practice
    case review
    case profile

    static var launchDefault: AppTab {
        let arguments = ProcessInfo.processInfo.arguments
        guard
            let flagIndex = arguments.firstIndex(of: "-ConverlaxInitialTab"),
            arguments.indices.contains(flagIndex + 1)
        else {
            return .home
        }

        switch arguments[flagIndex + 1] {
        case "practice", "freeTalk", "roleplays":
            return .practice
        case "review":
            return .review
        case "profile":
            return .profile
        default:
            return .home
        }
    }
}

enum ActiveSheet: Identifiable {
    case level
    case streak

    var id: String {
        switch self {
        case .level: "level"
        case .streak: "streak"
        }
    }
}

enum HomeRoute: Hashable {
    case courseDetail
    case tutor
    case lesson(BeginnerLesson)
    case lessonDetail(BeginnerLesson)
    case lessonLines(BeginnerLesson)
    case videoLesson(BeginnerLesson)
    case speakingDrill(BeginnerLesson)
    case qaLesson(BeginnerLesson)
    case customLesson
    case vocab
    case verbs

    static var launchDefaultPath: [HomeRoute] {
        let arguments = ProcessInfo.processInfo.arguments
        let launchLanguage: TargetLanguage = arguments.contains("-ConverlaxUseEnglishContent") ? .english : .french
        let launchLessonID = arguments.firstIndex(of: "-ConverlaxInitialLessonID").flatMap { idIndex in
            arguments.indices.contains(idIndex + 1) ? arguments[idIndex + 1] : nil
        }
        let launchLesson = launchLessonID.flatMap(BeginnerContent.lesson(id:)) ?? BeginnerContent.lessons(for: launchLanguage).first ?? BeginnerContent.lessons[0]
        guard
            let flagIndex = arguments.firstIndex(of: "-ConverlaxInitialHomeRoute"),
            arguments.indices.contains(flagIndex + 1)
        else {
            return []
        }

        switch arguments[flagIndex + 1] {
        case "courseDetail":
            return [.courseDetail]
        case "tutor":
            return [.tutor]
        case "lesson":
            return [.lesson(launchLesson)]
        case "lessonDetail":
            return [.lessonDetail(launchLesson)]
        case "lessonLines":
            return [.lessonLines(launchLesson)]
        case "videoLesson":
            return [.videoLesson(launchLesson)]
        case "speakingDrill":
            return [.speakingDrill(launchLesson)]
        case "qaLesson":
            return [.qaLesson(launchLesson)]
        case "customLesson":
            return [.customLesson]
        case "vocab":
            return [.vocab]
        case "verbs":
            return [.verbs]
        default:
            return []
        }
    }
}

enum PracticeRoute: Hashable {
    case session
    case tutor
    case createRoleplay
    case topics
    case topic(RoleplayTopic)
    case roleplay(RoleplayScenario)
    case history
    case favorites
    case community
    case communityRoleplay(RoleplayScenario)

    static var launchDefaultPath: [PracticeRoute] {
        let arguments = ProcessInfo.processInfo.arguments
        guard
            let flagIndex = arguments.firstIndex(where: { $0 == "-ConverlaxInitialPracticeRoute" || $0 == "-ConverlaxInitialFreeTalkRoute" }),
            arguments.indices.contains(flagIndex + 1)
        else {
            return []
        }

        switch arguments[flagIndex + 1] {
        case "session":
            return [.session]
        case "tutor":
            return [.tutor]
        case "createRoleplay":
            return [.createRoleplay]
        case "topics":
            return [.topics]
        case "topic":
            return PhaseOneContent.topics.first.map { [.topic($0)] } ?? []
        case "roleplay":
            return PhaseOneContent.roleplays.first.map { [.roleplay($0)] } ?? []
        case "history":
            return [.history]
        case "favorites":
            return [.favorites]
        case "community":
            return [.community]
        case "communityRoleplay":
            return PhaseOneContent.roleplays.first(where: \.isCommunity).map { [.communityRoleplay($0)] } ?? []
        default:
            return []
        }
    }
}

enum ReviewRoute: Hashable {
    case smartReview
    case savedLinesReview
    case savedLineSearch
    case reviewInfo

    static var launchDefaultPath: [ReviewRoute] {
        let arguments = ProcessInfo.processInfo.arguments
        guard
            let flagIndex = arguments.firstIndex(of: "-ConverlaxInitialReviewRoute"),
            arguments.indices.contains(flagIndex + 1)
        else {
            return []
        }

        switch arguments[flagIndex + 1] {
        case "smartReview":
            return [.smartReview]
        case "savedLinesReview":
            return [.savedLinesReview]
        case "savedLineSearch":
            return [.savedLineSearch]
        case "reviewInfo":
            return [.reviewInfo]
        default:
            return []
        }
    }
}

enum ProfileRoute: Hashable {
    case savedLines
    case activities
    case practiceHistory
    case settings
    case membership
    case editProfile
    case referrals
    case notifications
    case support
    case appLanguage
    case courseLanguage
    case voiceRecognition
    case login
    case resetPassword

    static var launchDefaultPath: [ProfileRoute] {
        let arguments = ProcessInfo.processInfo.arguments
        guard
            let flagIndex = arguments.firstIndex(of: "-ConverlaxInitialProfileRoute"),
            arguments.indices.contains(flagIndex + 1)
        else {
            return []
        }

        switch arguments[flagIndex + 1] {
        case "savedLines":
            return [.savedLines]
        case "activities":
            return [.activities]
        case "practiceHistory", "history":
            return [.practiceHistory]
        case "settings":
            return [.settings]
        case "membership":
            return [.membership]
        case "editProfile":
            return [.editProfile]
        case "referrals":
            return [.referrals]
        case "notifications":
            return [.settings, .notifications]
        case "support":
            return [.settings, .support]
        case "appLanguage":
            return [.settings, .appLanguage]
        case "courseLanguage":
            return [.settings, .courseLanguage]
        case "voiceRecognition":
            return [.settings, .voiceRecognition]
        case "login":
            return [.settings, .login]
        case "resetPassword":
            return [.settings, .resetPassword]
        default:
            return []
        }
    }
}

enum LessonTrack: String, CaseIterable, Identifiable {
    case course = "Course"
    case practice = "Practice"

    var id: String { rawValue }
}

enum TargetLanguage: String, CaseIterable, Codable, Identifiable {
    case english = "English"
    case french = "French"
    case spanish = "Spanish"
    case italian = "Italian"

    var id: String { rawValue }

    var isAvailable: Bool {
        self == .french || self == .english
    }

    var courseName: String {
        switch self {
        case .english: "English"
        case .french: "French"
        case .spanish: "Spanish preview"
        case .italian: "Italian preview"
        }
    }

    var sampleNote: String {
        switch self {
        case .english: "Beginner English"
        case .french: "Beginner French"
        case .spanish: "Beginner Spanish preview"
        case .italian: "Beginner Italian preview"
        }
    }

    var unitTitle: String {
        switch self {
        case .english: "Conversation Essentials"
        case .french: "Beginner Essentials"
        case .spanish: "Spanish Preview"
        case .italian: "Italian Preview"
        }
    }

    var unitDescription: String {
        switch self {
        case .english: "A complete starter unit for introductions, small talk, cafes, directions, help, plans, routines, shopping, and work."
        case .french: "A complete starter unit for greetings, cafe orders, directions, and hotel check-in."
        case .spanish, .italian: "This course path is not available yet."
        }
    }
}

enum Level: String, CaseIterable, Codable, Identifiable {
    case beginner = "Beginner"
    case elementary = "Elementary"
    case upperElementary = "Upper Elementary"
    case intermediate = "Intermediate"

    var id: String { rawValue }

    var code: String {
        switch self {
        case .beginner: "A1"
        case .elementary: "A1+"
        case .upperElementary: "A2"
        case .intermediate: "B1"
        }
    }

    var description: String {
        switch self {
        case .beginner: "Introduce yourself, order food, and handle simple travel moments."
        case .elementary: "Talk about routines, places, and daily experiences."
        case .upperElementary: "Handle local topics, appointments, and confident small talk."
        case .intermediate: "Explain opinions, narrate events, and keep a conversation moving."
        }
    }

    var index: Int {
        switch self {
        case .beginner: 1
        case .elementary: 2
        case .upperElementary: 3
        case .intermediate: 4
        }
    }
}

enum LessonAccent: String, Codable, Hashable {
    case blue
    case mint
    case amber
    case violet

    var color: Color {
        switch self {
        case .blue: .primaryBlue
        case .mint: .mintSuccess
        case .amber: .warmAmber
        case .violet: .violetAccent
        }
    }
}

enum LessonStepKind: String, Codable, Hashable {
    case teach
    case choice
    case speak
}

enum SavedLearningKind: String, Codable, Hashable {
    case line = "Line"
    case word = "Word"
    case phrase = "Phrase"
    case tutorMessage = "Tutor"
    case mistake = "Mistake"
    case roleplayPhrase = "Situation"
}

enum SpeechPracticePhase: String, Codable, Hashable {
    case permissionNeeded
    case ready
    case recording
    case paused
    case processing
    case transcript
    case feedback
    case accepted
    case error

    var title: String {
        switch self {
        case .permissionNeeded: "Mic permission needed"
        case .ready: "Ready to speak"
        case .recording: "Recording"
        case .paused: "Paused"
        case .processing: "Processing"
        case .transcript: "Transcript ready"
        case .feedback: "Feedback ready"
        case .accepted: "Accepted"
        case .error: "Try again"
        }
    }

    var actionTitle: String {
        switch self {
        case .permissionNeeded: "Enable mock mic"
        case .ready: "Start recording"
        case .recording: "Stop recording"
        case .paused: "Resume"
        case .processing: "Processing"
        case .transcript: "Get feedback"
        case .feedback: "Accept"
        case .accepted: "Practice again"
        case .error: "Retry"
        }
    }
}

struct SavedLearningObject: Codable, Hashable, Identifiable {
    let id: String
    let kind: SavedLearningKind
    let text: String
    let translation: String
    let source: String
    let note: String
    let createdDay: String
}

struct LearningFeedback: Codable, Hashable, Identifiable {
    let id: String
    let source: String
    let pronunciation: Int
    let grammar: Int
    let vocabulary: Int
    let fluency: Int
    let meaning: Int
    let confidence: Int
    let promptText: String
    let attemptedText: String
    let correction: String
    let betterPhrase: String
    let pronunciationTip: String
    let claritySignal: String
    let savedTakeaway: String
    let nextAction: String
    let createdDay: String

    var averageScore: Int {
        (pronunciation + grammar + vocabulary + fluency + meaning) / 5
    }

    init(
        id: String,
        source: String,
        pronunciation: Int,
        grammar: Int,
        vocabulary: Int,
        fluency: Int,
        meaning: Int,
        confidence: Int,
        promptText: String = "",
        attemptedText: String = "",
        correction: String,
        betterPhrase: String,
        pronunciationTip: String = "Say the sentence in one smooth breath and keep the final word clear.",
        claritySignal: String = "",
        savedTakeaway: String = "",
        nextAction: String = "Try one more spoken attempt.",
        createdDay: String
    ) {
        self.id = id
        self.source = source
        self.pronunciation = pronunciation
        self.grammar = grammar
        self.vocabulary = vocabulary
        self.fluency = fluency
        self.meaning = meaning
        self.confidence = confidence
        self.promptText = promptText
        self.attemptedText = attemptedText
        self.correction = correction
        self.betterPhrase = betterPhrase
        self.pronunciationTip = pronunciationTip
        self.claritySignal = claritySignal
        self.savedTakeaway = savedTakeaway
        self.nextAction = nextAction
        self.createdDay = createdDay
    }

    enum CodingKeys: String, CodingKey {
        case id
        case source
        case pronunciation
        case grammar
        case vocabulary
        case fluency
        case meaning
        case confidence
        case promptText
        case attemptedText
        case correction
        case betterPhrase
        case pronunciationTip
        case claritySignal
        case savedTakeaway
        case nextAction
        case createdDay
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        source = try container.decode(String.self, forKey: .source)
        pronunciation = try container.decode(Int.self, forKey: .pronunciation)
        grammar = try container.decode(Int.self, forKey: .grammar)
        vocabulary = try container.decode(Int.self, forKey: .vocabulary)
        fluency = try container.decode(Int.self, forKey: .fluency)
        meaning = try container.decode(Int.self, forKey: .meaning)
        confidence = try container.decode(Int.self, forKey: .confidence)
        promptText = try container.decodeIfPresent(String.self, forKey: .promptText) ?? ""
        attemptedText = try container.decodeIfPresent(String.self, forKey: .attemptedText) ?? ""
        correction = try container.decode(String.self, forKey: .correction)
        betterPhrase = try container.decode(String.self, forKey: .betterPhrase)
        pronunciationTip = try container.decodeIfPresent(String.self, forKey: .pronunciationTip) ?? "Say the sentence in one smooth breath and keep the final word clear."
        claritySignal = try container.decodeIfPresent(String.self, forKey: .claritySignal) ?? ""
        savedTakeaway = try container.decodeIfPresent(String.self, forKey: .savedTakeaway) ?? betterPhrase
        nextAction = try container.decodeIfPresent(String.self, forKey: .nextAction) ?? "Try one more spoken attempt."
        createdDay = try container.decode(String.self, forKey: .createdDay)
    }
}

struct ScheduledReviewItem: Codable, Hashable, Identifiable {
    let id: String
    let objectID: String
    let kind: SavedLearningKind
    let prompt: String
    let answer: String
    let source: String
    var lastReviewedDay: String?
    var nextDueDay: String
    var ease: Double
    var mistakeCount: Int
    var listeningFirst: Bool
    var speakingRetry: Bool
}

struct LearningSessionSummary: Codable, Hashable, Identifiable {
    let id: String
    let title: String
    let transcript: String
    let corrections: [String]
    let strongPhrases: [String]
    let weakPhrases: [String]
    let suggestedReviewIDs: [String]
    let nextRecommendation: String
    let dateLabel: String
}

struct SkillProgress: Codable, Hashable, Identifiable {
    let id: String
    var title: String
    var completed: Int
    var confidence: Int
}

struct SavedWord: Codable, Hashable, Identifiable {
    let term: String
    let translation: String
    let example: String

    var id: String { term.lowercased() }
}

struct SavedLine: Codable, Hashable, Identifiable {
    let id: String
    let text: String
    let translation: String
    let source: String
    let note: String
}

struct RoleplayTopic: Codable, Hashable, Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let symbol: String
    let colorName: LessonAccent
    let scenarioIDs: [String]
}

struct RoleplayScenario: Codable, Hashable, Identifiable {
    let id: String
    let topicID: String
    let title: String
    let subtitle: String
    let setting: String
    let difficulty: Level
    let minutes: Int
    let lines: [SavedLine]
    let isCommunity: Bool
}

struct UsageSession: Codable, Hashable, Identifiable {
    let id: String
    let title: String
    let detail: String
    let minutes: Int
    let dateLabel: String
}

struct LearningActivity: Codable, Hashable, Identifiable {
    let id: String
    let title: String
    let detail: String
    let symbol: String
    let dateLabel: String
}

struct ReviewItem: Codable, Hashable, Identifiable {
    let id: String
    let prompt: String
    let answer: String
    let source: String
    var dueLabel: String = "Today"
    var confidence: Int = 70
}

struct NextLearningRecommendation: Equatable {
    let title: String
    let detail: String
    let reason: String
    let symbol: String
}

struct LessonStep: Codable, Hashable, Identifiable {
    let id: String
    let kind: LessonStepKind
    let title: String
    let prompt: String
    let helper: String
    let choices: [String]
    let correctAnswer: String?
}

struct BeginnerLesson: Hashable, Identifiable {
    let id: String
    let unit: Int
    let title: String
    let subtitle: String
    let icon: String
    let accent: LessonAccent
    let minutes: Int
    let steps: [LessonStep]
    let savedWords: [SavedWord]
}

struct LearningProfile: Codable, Equatable {
    var schemaVersion = 3
    var targetLanguage: TargetLanguage = .english
    var currentLevel: Level = .beginner
    var completedLessonIDs: Set<String> = []
    var currentLessonID: String = BeginnerContent.firstLessonID(for: .english)
    var streak: Int = 0
    var savedWords: [SavedWord] = []
    var savedLines: [SavedLine] = []
    var savedLearningObjects: [SavedLearningObject] = []
    var scheduledReviews: [ScheduledReviewItem] = []
    var feedbackEvents: [LearningFeedback] = []
    var sessionSummaries: [LearningSessionSummary] = []
    var skillProgress: [SkillProgress] = []
    var favoriteRoleplayIDs: Set<String> = []
    var usageSessions: [UsageSession] = []
    var activities: [LearningActivity] = []
    var hasCompletedOnboarding = false
    var lastCompletionDay: String?
    var dailyGoal: Int = 2
    var hapticsEnabled = true
    var soundEnabled = true
    var tutorAudioEnabled = false
    var voiceRecognitionEnabled = false
    var notificationsEnabled = true

    init() {}

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        schemaVersion = try container.decodeIfPresent(Int.self, forKey: .schemaVersion) ?? 1
        targetLanguage = try container.decodeIfPresent(TargetLanguage.self, forKey: .targetLanguage) ?? .french
        currentLevel = try container.decodeIfPresent(Level.self, forKey: .currentLevel) ?? .beginner
        completedLessonIDs = try container.decodeIfPresent(Set<String>.self, forKey: .completedLessonIDs) ?? []
        currentLessonID = try container.decodeIfPresent(String.self, forKey: .currentLessonID) ?? BeginnerContent.firstLessonID(for: targetLanguage)
        streak = try container.decodeIfPresent(Int.self, forKey: .streak) ?? 0
        savedWords = try container.decodeIfPresent([SavedWord].self, forKey: .savedWords) ?? []
        savedLines = try container.decodeIfPresent([SavedLine].self, forKey: .savedLines) ?? []
        savedLearningObjects = try container.decodeIfPresent([SavedLearningObject].self, forKey: .savedLearningObjects) ?? []
        scheduledReviews = try container.decodeIfPresent([ScheduledReviewItem].self, forKey: .scheduledReviews) ?? []
        feedbackEvents = try container.decodeIfPresent([LearningFeedback].self, forKey: .feedbackEvents) ?? []
        sessionSummaries = try container.decodeIfPresent([LearningSessionSummary].self, forKey: .sessionSummaries) ?? []
        skillProgress = try container.decodeIfPresent([SkillProgress].self, forKey: .skillProgress) ?? []
        favoriteRoleplayIDs = try container.decodeIfPresent(Set<String>.self, forKey: .favoriteRoleplayIDs) ?? []
        usageSessions = try container.decodeIfPresent([UsageSession].self, forKey: .usageSessions) ?? []
        activities = try container.decodeIfPresent([LearningActivity].self, forKey: .activities) ?? []
        hasCompletedOnboarding = try container.decodeIfPresent(Bool.self, forKey: .hasCompletedOnboarding) ?? false
        lastCompletionDay = try container.decodeIfPresent(String.self, forKey: .lastCompletionDay)
        dailyGoal = try container.decodeIfPresent(Int.self, forKey: .dailyGoal) ?? 2
        hapticsEnabled = try container.decodeIfPresent(Bool.self, forKey: .hapticsEnabled) ?? true
        soundEnabled = try container.decodeIfPresent(Bool.self, forKey: .soundEnabled) ?? true
        tutorAudioEnabled = try container.decodeIfPresent(Bool.self, forKey: .tutorAudioEnabled) ?? false
        voiceRecognitionEnabled = try container.decodeIfPresent(Bool.self, forKey: .voiceRecognitionEnabled) ?? false
        notificationsEnabled = try container.decodeIfPresent(Bool.self, forKey: .notificationsEnabled) ?? true
    }
}

struct ChatMessage: Identifiable, Equatable {
    let id = UUID()
    let text: String
    let isUser: Bool
    var canSave = false
}

enum QuickPracticeRoute: Hashable {
    case vocab
    case verbs
}

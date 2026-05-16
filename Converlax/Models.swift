import SwiftUI

extension ProcessInfo {
    func converlaxArgumentValue(after flag: String) -> String? {
        let arguments = arguments
        guard let flagIndex = arguments.firstIndex(of: flag), arguments.indices.contains(flagIndex + 1) else {
            return nil
        }
        return arguments[flagIndex + 1]
    }

    var converlaxInitialHomeRoute: String? {
        converlaxArgumentValue(after: "-ConverlaxInitialHomeRoute")
    }
}

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
    case startLesson

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
        case "startLesson":
            return [.startLesson]
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
        case .spanish: "Spanish"
        case .italian: "Italian"
        }
    }

    var sampleNote: String {
        switch self {
        case .english: "Beginner English"
        case .french: "Beginner French"
        case .spanish: "Beginner Spanish"
        case .italian: "Beginner Italian"
        }
    }

    var unitTitle: String {
        switch self {
        case .english: "English Speaking Path"
        case .french: "Beginner Essentials"
        case .spanish: "Spanish Essentials"
        case .italian: "Italian Essentials"
        }
    }

    var unitDescription: String {
        switch self {
        case .english: "Practical conversation units for first chats, daily life, food, travel, work, calls, problems, opinions, and help."
        case .french: "A complete starter unit for greetings, cafe orders, directions, and hotel check-in."
        case .spanish, .italian: "Switch to English or French for the guided starter course."
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
        case .upperElementary: "Handle everyday topics, appointments, and confident small talk."
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

struct LearnerProfile: Codable, Equatable {
    var displayName = ""
    var nickname: String?
    var avatarChoice: LearnerAvatarChoice = .melo
    var nativeLanguage = ""
    var learningReason: LearningReason = .speakWithConfidence
    var speakingConfidence: SpeakingConfidenceLevel = .warmingUp
    var dailySpeakingGoal: DailySpeakingGoal = .fiveMinutes
    var practiceFocus: PracticeFocus = .everydayConversation
    var reminderPreference: ReminderPreference?

    init() {}

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        displayName = (try? container.decodeIfPresent(String.self, forKey: .displayName)) ?? ""
        nickname = (try? container.decodeIfPresent(String.self, forKey: .nickname)) ?? nil
        avatarChoice = (try? container.decodeIfPresent(LearnerAvatarChoice.self, forKey: .avatarChoice)) ?? .melo
        nativeLanguage = (try? container.decodeIfPresent(String.self, forKey: .nativeLanguage)) ?? ""
        learningReason = (try? container.decodeIfPresent(LearningReason.self, forKey: .learningReason)) ?? .speakWithConfidence
        speakingConfidence = (try? container.decodeIfPresent(SpeakingConfidenceLevel.self, forKey: .speakingConfidence)) ?? .warmingUp
        dailySpeakingGoal = (try? container.decodeIfPresent(DailySpeakingGoal.self, forKey: .dailySpeakingGoal)) ?? .fiveMinutes
        practiceFocus = (try? container.decodeIfPresent(PracticeFocus.self, forKey: .practiceFocus)) ?? .everydayConversation
        reminderPreference = (try? container.decodeIfPresent(ReminderPreference.self, forKey: .reminderPreference)) ?? nil
    }

    var preferredName: String {
        if let nickname = sanitizedOptional(nickname) {
            return nickname
        }
        return sanitizedText(displayName, limit: 50)
    }

    var sanitized: LearnerProfile {
        var next = self
        next.displayName = sanitizedText(displayName, limit: 50)
        next.nickname = sanitizedOptional(nickname, limit: 32)
        next.nativeLanguage = sanitizedText(nativeLanguage, limit: 40)
        return next
    }

    private func sanitizedText(_ value: String, limit: Int) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return String(trimmed.prefix(limit))
    }

    private func sanitizedOptional(_ value: String?, limit: Int = 32) -> String? {
        guard let value else { return nil }
        let trimmed = sanitizedText(value, limit: limit)
        return trimmed.isEmpty ? nil : trimmed
    }
}

enum LearnerAvatarChoice: String, CaseIterable, Codable, Identifiable {
    case melo
    case waving
    case thinking
    case celebrating

    var id: String { rawValue }

    var title: String {
        switch self {
        case .melo: "Melo"
        case .waving: "Melo waving"
        case .thinking: "Melo thinking"
        case .celebrating: "Melo celebrating"
        }
    }

    var mascotState: ConverlaxMascotState {
        switch self {
        case .melo: .avatar
        case .waving: .waving
        case .thinking: .thinking
        case .celebrating: .celebrating
        }
    }
}

enum LearningReason: String, CaseIterable, Codable, Identifiable {
    case speakWithConfidence
    case travel
    case work
    case study
    case friendsAndFamily
    case dailyLife

    var id: String { rawValue }

    var title: String {
        switch self {
        case .speakWithConfidence: "Speak with confidence"
        case .travel: "Travel"
        case .work: "Work"
        case .study: "Study"
        case .friendsAndFamily: "Friends and family"
        case .dailyLife: "Daily life"
        }
    }
}

enum SpeakingConfidenceLevel: String, CaseIterable, Codable, Identifiable {
    case warmingUp
    case cautious
    case steady
    case confident

    var id: String { rawValue }

    var title: String {
        switch self {
        case .warmingUp: "Warming up"
        case .cautious: "Cautious"
        case .steady: "Steady"
        case .confident: "Confident"
        }
    }
}

enum DailySpeakingGoal: String, CaseIterable, Codable, Identifiable {
    case threeMinutes
    case fiveMinutes
    case tenMinutes
    case fifteenMinutes

    var id: String { rawValue }

    var title: String {
        switch self {
        case .threeMinutes: "3 minutes"
        case .fiveMinutes: "5 minutes"
        case .tenMinutes: "10 minutes"
        case .fifteenMinutes: "15 minutes"
        }
    }
}

enum PracticeFocus: String, CaseIterable, Codable, Identifiable {
    case everydayConversation
    case pronunciation
    case listeningThenSpeaking
    case travel
    case workAndStudy

    var id: String { rawValue }

    var title: String {
        switch self {
        case .everydayConversation: "Everyday conversation"
        case .pronunciation: "Pronunciation"
        case .listeningThenSpeaking: "Listening then speaking"
        case .travel: "Travel"
        case .workAndStudy: "Work and study"
        }
    }
}

enum ReminderPreference: String, CaseIterable, Codable, Identifiable {
    case morning
    case midday
    case evening

    var id: String { rawValue }

    var title: String {
        switch self {
        case .morning: "Morning"
        case .midday: "Midday"
        case .evening: "Evening"
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
    case requestingPermission
    case permissionNeeded
    case permissionDenied
    case ready
    case recording
    case paused
    case processing
    case transcribing
    case transcript
    case feedback
    case accepted
    case noSpeech
    case error

    var title: String {
        switch self {
        case .requestingPermission: "Requesting access"
        case .permissionNeeded, .permissionDenied: "Voice needs access"
        case .ready: "Ready to speak"
        case .recording: "Recording"
        case .paused: "Paused"
        case .processing, .transcribing: "Transcribing"
        case .transcript: "Transcript ready"
        case .feedback: "Feedback ready"
        case .accepted: "Speaking saved"
        case .noSpeech: "No speech recognized"
        case .error: "Try again"
        }
    }

    var actionTitle: String {
        switch self {
        case .requestingPermission: "Requesting access"
        case .permissionNeeded, .permissionDenied: "Try again"
        case .ready: "Start speaking"
        case .recording: "Use this recording"
        case .paused: "Resume"
        case .processing, .transcribing: "Transcribing"
        case .transcript: "Use this phrase"
        case .feedback: "Next turn"
        case .accepted: "Practice again"
        case .noSpeech, .error: "Try again"
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
    let grammarCorrection: String
    let naturalVersion: String
    let pronunciationNotes: String
    let vocabularyImprovement: String
    let fluencyTip: String
    let didWell: String
    let tryNext: String
    let reviewItemPrompt: String
    let reviewItemAnswer: String
    let feedbackProvider: String
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
        grammarCorrection: String = "",
        naturalVersion: String = "",
        pronunciationNotes: String = "",
        vocabularyImprovement: String = "",
        fluencyTip: String = "",
        didWell: String = "",
        tryNext: String = "",
        reviewItemPrompt: String = "",
        reviewItemAnswer: String = "",
        feedbackProvider: String = "local",
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
        self.grammarCorrection = grammarCorrection
        self.naturalVersion = naturalVersion
        self.pronunciationNotes = pronunciationNotes
        self.vocabularyImprovement = vocabularyImprovement
        self.fluencyTip = fluencyTip
        self.didWell = didWell
        self.tryNext = tryNext
        self.reviewItemPrompt = reviewItemPrompt
        self.reviewItemAnswer = reviewItemAnswer
        self.feedbackProvider = feedbackProvider
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
        case grammarCorrection
        case naturalVersion
        case pronunciationNotes
        case vocabularyImprovement
        case fluencyTip
        case didWell
        case tryNext
        case reviewItemPrompt
        case reviewItemAnswer
        case feedbackProvider
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
        grammarCorrection = try container.decodeIfPresent(String.self, forKey: .grammarCorrection) ?? ""
        naturalVersion = try container.decodeIfPresent(String.self, forKey: .naturalVersion) ?? ""
        pronunciationNotes = try container.decodeIfPresent(String.self, forKey: .pronunciationNotes) ?? ""
        vocabularyImprovement = try container.decodeIfPresent(String.self, forKey: .vocabularyImprovement) ?? ""
        fluencyTip = try container.decodeIfPresent(String.self, forKey: .fluencyTip) ?? ""
        didWell = try container.decodeIfPresent(String.self, forKey: .didWell) ?? ""
        tryNext = try container.decodeIfPresent(String.self, forKey: .tryNext) ?? ""
        reviewItemPrompt = try container.decodeIfPresent(String.self, forKey: .reviewItemPrompt) ?? ""
        reviewItemAnswer = try container.decodeIfPresent(String.self, forKey: .reviewItemAnswer) ?? ""
        feedbackProvider = try container.decodeIfPresent(String.self, forKey: .feedbackProvider) ?? "local"
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

struct CompletionCelebrationResult: Equatable {
    let title: String
    let subtitle: String
    let xpEarned: Int
    let levelBefore: Int
    let levelAfter: Int
    let levelProgressBefore: Double
    let levelProgressAfter: Double
    let savedItemsCreated: Int
    let nextActionTitle: String
    let nextActionDetail: String

    var levelProgressTitle: String {
        levelAfter > levelBefore ? "Reached Level \(levelAfter)" : "Level \(levelAfter) progress moved"
    }

    var levelProgressDetail: String {
        let beforePercent = Int((levelProgressBefore * 100).rounded())
        let afterPercent = Int((levelProgressAfter * 100).rounded())
        if levelAfter > levelBefore {
            return "Level \(levelBefore) \(beforePercent)% to Level \(levelAfter) \(afterPercent)%"
        }
        return "\(beforePercent)% to \(afterPercent)%"
    }
}

struct JourneyProgress: Equatable {
    let totalXP: Int
    let levelNumber: Int
    let currentTitle: String
    let currentTitleDetail: String
    let nextTitle: String
    let nextLearnerTitle: LearnerTitle?
    let nextTitleUnlockLevel: Int?
    let xpToNextTitle: Int
    let xpRemaining: Int
    let xpInCurrentLevel: Int
    let xpPerLevel: Int
    let xpSources: [JourneyXPSource]
    let unlockedLearnerTitles: [LearnerTitle]
    let unlockedMilestones: [JourneyMilestone]

    var levelProgress: Double {
        guard xpPerLevel > 0 else { return 0 }
        return Double(xpInCurrentLevel) / Double(xpPerLevel)
    }

    init(profile: LearningProfile, completedLessonCount: Int, totalLessonCount: Int) {
        let speakingSessionCount = profile.sessionSummaries.filter { $0.id.hasPrefix("summary-usage-session-") }.count
        let reviewedItemCount = profile.scheduledReviews.filter { $0.lastReviewedDay != nil }.count
        let savedLineCount = profile.savedLines.count
        let streakDayCount = max(profile.streak, 0)

        let sources = [
            JourneyXPSource(id: "lessons", title: "Lessons", count: completedLessonCount, xp: completedLessonCount * 120),
            JourneyXPSource(id: "speaking", title: "Speaking", count: speakingSessionCount, xp: speakingSessionCount * 80),
            JourneyXPSource(id: "reviews", title: "Reviews", count: reviewedItemCount, xp: reviewedItemCount * 35),
            JourneyXPSource(id: "saved-lines", title: "Saved lines", count: savedLineCount, xp: savedLineCount * 25),
            JourneyXPSource(id: "streak", title: "Streak", count: streakDayCount, xp: streakDayCount * 30)
        ]
        let levelSize = 500
        let earnedXP = sources.reduce(0) { $0 + $1.xp }
        let computedLevelNumber = max(1, (earnedXP / levelSize) + 1)
        let computedXPInCurrentLevel = earnedXP % levelSize
        let computedXPRemaining = max(0, levelSize - computedXPInCurrentLevel)

        xpSources = sources
        totalXP = earnedXP
        xpPerLevel = levelSize
        levelNumber = computedLevelNumber
        xpInCurrentLevel = computedXPInCurrentLevel
        xpRemaining = computedXPRemaining

        let titleCatalog = JourneyProgress.learnerTitles
        let unlockedTitles = titleCatalog.filter { $0.unlockLevel <= computedLevelNumber }
        let currentLearnerTitle = unlockedTitles.last ?? titleCatalog[0]
        let upcomingLearnerTitle = titleCatalog.first { $0.unlockLevel > computedLevelNumber }

        unlockedLearnerTitles = unlockedTitles
        currentTitle = currentLearnerTitle.name
        currentTitleDetail = currentLearnerTitle.detail
        nextLearnerTitle = upcomingLearnerTitle
        nextTitle = upcomingLearnerTitle?.name ?? currentLearnerTitle.name
        nextTitleUnlockLevel = upcomingLearnerTitle?.unlockLevel
        if let upcomingLearnerTitle {
            let levelsToEarnBeforeUnlock = max(0, upcomingLearnerTitle.unlockLevel - computedLevelNumber - 1)
            xpToNextTitle = levelsToEarnBeforeUnlock * levelSize + computedXPRemaining
        } else {
            xpToNextTitle = 0
        }

        let milestoneCatalog = JourneyProgress.milestones(
            completedLessonCount: completedLessonCount,
            totalLessonCount: totalLessonCount,
            speakingSessionCount: speakingSessionCount,
            reviewedItemCount: reviewedItemCount,
            savedLineCount: savedLineCount,
            streakDayCount: streakDayCount
        )

        unlockedMilestones = milestoneCatalog.filter(\.isUnlocked)
    }

    private static let learnerTitles: [LearnerTitle] = [
        LearnerTitle(id: "first-steps", name: "First Steps", unlockLevel: 1, detail: "Started the learning path"),
        LearnerTitle(id: "phrase-builder", name: "Phrase Builder", unlockLevel: 2, detail: "Building useful everyday phrases"),
        LearnerTitle(id: "conversation-starter", name: "Conversation Starter", unlockLevel: 3, detail: "Ready to open simple exchanges"),
        LearnerTitle(id: "steady-speaker", name: "Steady Speaker", unlockLevel: 5, detail: "Practicing speech with consistency"),
        LearnerTitle(id: "review-navigator", name: "Review Navigator", unlockLevel: 7, detail: "Keeping saved language active"),
        LearnerTitle(id: "everyday-communicator", name: "Everyday Communicator", unlockLevel: 10, detail: "Handling common situations with confidence"),
        LearnerTitle(id: "confident-conversationalist", name: "Confident Conversationalist", unlockLevel: 14, detail: "Sustaining longer beginner conversations")
    ]

    private static func milestones(
        completedLessonCount: Int,
        totalLessonCount: Int,
        speakingSessionCount: Int,
        reviewedItemCount: Int,
        savedLineCount: Int,
        streakDayCount: Int
    ) -> [JourneyMilestone] {
        [
            JourneyMilestone(id: "path-finder", title: "Path Finder", detail: "Journey started", symbol: "map.fill", isUnlocked: true),
            JourneyMilestone(id: "daily-starter", title: "Daily Starter", detail: "Complete one lesson", symbol: "checkmark.seal.fill", isUnlocked: completedLessonCount >= 1),
            JourneyMilestone(id: "first-voice", title: "First Voice", detail: "Finish one speaking session", symbol: "mic.fill", isUnlocked: speakingSessionCount >= 1),
            JourneyMilestone(id: "review-builder", title: "Review Builder", detail: "Review one saved item", symbol: "bolt.fill", isUnlocked: reviewedItemCount >= 1),
            JourneyMilestone(id: "line-collector", title: "Line Collector", detail: "Save five lines", symbol: "bookmark.fill", isUnlocked: savedLineCount >= 5),
            JourneyMilestone(id: "course-climber", title: "Course Climber", detail: "Complete three lessons", symbol: "figure.walk", isUnlocked: completedLessonCount >= 3),
            JourneyMilestone(id: "streak-keeper", title: "Streak Keeper", detail: "Reach a three-day streak", symbol: "flame.fill", isUnlocked: streakDayCount >= 3),
            JourneyMilestone(id: "voice-regular", title: "Voice Regular", detail: "Finish five speaking sessions", symbol: "waveform", isUnlocked: speakingSessionCount >= 5),
            JourneyMilestone(id: "review-regular", title: "Review Regular", detail: "Review ten saved items", symbol: "arrow.clockwise", isUnlocked: reviewedItemCount >= 10),
            JourneyMilestone(id: "unit-finisher", title: "Unit Finisher", detail: "Complete the current course unit", symbol: "trophy.fill", isUnlocked: totalLessonCount > 0 && completedLessonCount >= totalLessonCount)
        ]
    }
}

struct JourneyXPSource: Equatable, Identifiable {
    let id: String
    let title: String
    let count: Int
    let xp: Int
}

struct LearnerTitle: Equatable, Identifiable {
    let id: String
    let name: String
    let unlockLevel: Int
    let detail: String
}

struct JourneyMilestone: Equatable, Identifiable {
    let id: String
    let title: String
    let detail: String
    let symbol: String
    let isUnlocked: Bool
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
    static let currentSchemaVersion = 4

    var schemaVersion = Self.currentSchemaVersion
    var learnerProfile = LearnerProfile()
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
    var voiceRecognitionEnabled = true
    var notificationsEnabled = true

    init() {}

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        schemaVersion = try container.decodeIfPresent(Int.self, forKey: .schemaVersion) ?? 1
        learnerProfile = (try? container.decodeIfPresent(LearnerProfile.self, forKey: .learnerProfile)) ?? LearnerProfile()
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
        voiceRecognitionEnabled = try container.decodeIfPresent(Bool.self, forKey: .voiceRecognitionEnabled) ?? true
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

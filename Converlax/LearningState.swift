import Foundation

final class LearningState: ObservableObject {
    @Published private(set) var profile: LearningProfile {
        didSet { save(profile) }
    }

    private let storage: UserDefaults
    private let calendar: Calendar
    private let storageKey = "converlax.learningProfile.v3"
    private let legacyStorageKey = "converlax.learningProfile.v2"
    private let oldestStorageKey = "converlax.learningProfile.v1"

    init(storage: UserDefaults = .standard, calendar: Calendar = .current) {
        self.storage = storage
        self.calendar = calendar

        if let restored = Self.restore(from: storage, key: storageKey) ?? Self.restore(from: storage, key: legacyStorageKey) ?? Self.restore(from: storage, key: oldestStorageKey) {
            profile = Self.launchAdjusted(Self.sanitized(restored))
        } else {
            profile = Self.launchAdjusted(LearningProfile())
        }
    }

    var courseProgress: Double {
        guard !courseLessons.isEmpty else { return 0 }
        return Double(completedLessonCount) / Double(courseLessons.count)
    }

    var completedLessonCount: Int {
        courseLessons.filter { profile.completedLessonIDs.contains($0.id) }.count
    }

    var remainingLessonCount: Int {
        max(0, courseLessons.count - completedLessonCount)
    }

    var courseLessons: [BeginnerLesson] {
        BeginnerContent.lessons(for: profile.targetLanguage)
    }

    var courseSavedWords: [SavedWord] {
        let courseWordIDs = Set(courseLessons.flatMap(\.savedWords).map(\.id))
        return profile.savedWords.filter { courseWordIDs.contains($0.id) }
    }

    var savedLines: [SavedLine] {
        seededSavedLines(profile.savedLines)
    }

    var savedLearningObjects: [SavedLearningObject] {
        seededLearningObjects(profile.savedLearningObjects)
    }

    var scheduledReviewItems: [ScheduledReviewItem] {
        seededScheduledReviews(profile.scheduledReviews)
    }

    var dueReviewItems: [ScheduledReviewItem] {
        let today = dayString(for: Date())
        let due = scheduledReviewItems.filter { $0.nextDueDay <= today }
        return due.isEmpty ? scheduledReviewItems : due
    }

    var latestFeedback: LearningFeedback? {
        profile.feedbackEvents.first
    }

    var sessionSummaries: [LearningSessionSummary] {
        profile.sessionSummaries
    }

    var skillProgress: [SkillProgress] {
        seededSkillProgress(profile.skillProgress)
    }

    var nextRecommendation: String {
        if !dueReviewItems.isEmpty {
            return "Review \(dueReviewItems.count) due items"
        }
        if let weakSkill = skillProgress.min(by: { $0.confidence < $1.confidence }) {
            return "Practice \(weakSkill.title.lowercased())"
        }
        return "Continue \(currentLesson.title.lowercased())"
    }

    var roleplayTopics: [RoleplayTopic] {
        PhaseOneContent.topics
    }

    var roleplays: [RoleplayScenario] {
        PhaseOneContent.roleplays
    }

    var communityRoleplays: [RoleplayScenario] {
        roleplays.filter(\.isCommunity)
    }

    var favoriteRoleplays: [RoleplayScenario] {
        roleplays.filter { profile.favoriteRoleplayIDs.contains($0.id) }
    }

    var usageSessions: [UsageSession] {
        seededUsageSessions(profile.usageSessions)
    }

    var activities: [LearningActivity] {
        seededActivities(profile.activities)
    }

    var reviewItems: [ReviewItem] {
        dueReviewItems.map {
            ReviewItem(
                id: $0.id,
                prompt: $0.prompt,
                answer: $0.answer,
                source: $0.source,
                dueLabel: $0.nextDueDay,
                confidence: Int($0.ease * 100)
            )
        }
    }

    var currentLesson: BeginnerLesson {
        BeginnerContent.lesson(id: profile.currentLessonID) ?? courseLessons.first ?? BeginnerContent.lessons[0]
    }

    func isCompleted(_ lesson: BeginnerLesson) -> Bool {
        profile.completedLessonIDs.contains(lesson.id)
    }

    func isCurrent(_ lesson: BeginnerLesson) -> Bool {
        profile.currentLessonID == lesson.id
    }

    func isUnlocked(_ lesson: BeginnerLesson) -> Bool {
        guard let index = courseLessons.firstIndex(of: lesson) else { return false }
        if index == 0 { return true }
        let previous = courseLessons[index - 1]
        return isCompleted(previous) || isCompleted(lesson)
    }

    func completeOnboarding(language: TargetLanguage, level: Level) {
        var next = profile
        next.targetLanguage = language.isAvailable ? language : .french
        next.currentLevel = level
        next.currentLessonID = nextFirstLessonID(for: next.targetLanguage, completedLessonIDs: next.completedLessonIDs)
        next.hasCompletedOnboarding = true
        profile = next
    }

    func selectTargetLanguage(_ language: TargetLanguage) {
        guard language.isAvailable else { return }
        var next = profile
        next.targetLanguage = language
        next.currentLessonID = nextFirstLessonID(for: language, completedLessonIDs: next.completedLessonIDs)
        profile = next
    }

    func selectLevel(_ level: Level) {
        var next = profile
        next.currentLevel = level
        profile = next
    }

    func setDailyGoal(_ goal: Int) {
        var next = profile
        next.dailyGoal = min(max(goal, 1), 6)
        profile = next
    }

    func setHapticsEnabled(_ enabled: Bool) {
        var next = profile
        next.hapticsEnabled = enabled
        profile = next
    }

    func setSoundEnabled(_ enabled: Bool) {
        var next = profile
        next.soundEnabled = enabled
        profile = next
    }

    func setTutorAudioEnabled(_ enabled: Bool) {
        var next = profile
        next.tutorAudioEnabled = enabled
        profile = next
    }

    func setVoiceRecognitionEnabled(_ enabled: Bool) {
        var next = profile
        next.voiceRecognitionEnabled = enabled
        profile = next
    }

    func setNotificationsEnabled(_ enabled: Bool) {
        var next = profile
        next.notificationsEnabled = enabled
        profile = next
    }

    func completeLesson(_ lesson: BeginnerLesson, now: Date = Date()) {
        var next = profile
        let inserted = next.completedLessonIDs.insert(lesson.id).inserted

        for word in lesson.savedWords where !next.savedWords.contains(word) {
            next.savedWords.append(word)
            addLearningObject(
                SavedLearningObject(
                    id: "word-\(word.id)",
                    kind: .word,
                    text: word.term,
                    translation: word.translation,
                    source: lesson.title,
                    note: word.example,
                    createdDay: dayString(for: now)
                ),
                in: &next,
                now: now
            )
        }

        if inserted {
            updateStreak(in: &next, now: now)
            addFeedback(
                mockFeedback(source: lesson.title, correction: "Lesson completed with a complete pass through the core prompts."),
                in: &next
            )
            updateSkill("Course", title: "Course completion", delta: 1, confidenceDelta: 4, in: &next)
            prependActivity(
                LearningActivity(
                    id: "lesson-\(lesson.id)-\(dayString(for: now))",
                    title: "Completed \(lesson.title)",
                    detail: "\(lesson.minutes) min lesson",
                    symbol: "checkmark.seal.fill",
                    dateLabel: "Today"
                ),
                in: &next
            )
        }

        if let upcoming = BeginnerContent.lessons(for: next.targetLanguage).first(where: { !next.completedLessonIDs.contains($0.id) }) {
            next.currentLessonID = upcoming.id
        } else {
            next.currentLessonID = lesson.id
        }

        profile = next
    }

    func saveWord(_ word: SavedWord) {
        var next = profile
        guard !next.savedWords.contains(word) else { return }
        next.savedWords.append(word)
        addLearningObject(
            SavedLearningObject(
                id: "word-\(word.id)",
                kind: .word,
                text: word.term,
                translation: word.translation,
                source: "Saved word",
                note: word.example,
                createdDay: dayString(for: Date())
            ),
            in: &next,
            now: Date()
        )
        profile = next
    }

    func removeWord(_ word: SavedWord) {
        var next = profile
        next.savedWords.removeAll { $0.id == word.id }
        profile = next
    }

    func saveLine(_ line: SavedLine) {
        var next = profile
        guard !seededSavedLines(next.savedLines).contains(where: { $0.id == line.id }) else { return }
        next.savedLines.append(line)
        addLearningObject(
            SavedLearningObject(
                id: "line-\(line.id)",
                kind: .line,
                text: line.text,
                translation: line.translation,
                source: line.source,
                note: line.note,
                createdDay: dayString(for: Date())
            ),
            in: &next,
            now: Date()
        )
        prependActivity(
            LearningActivity(id: "saved-\(line.id)", title: "Saved a line", detail: line.text, symbol: "bookmark.fill", dateLabel: "Today"),
            in: &next
        )
        profile = next
    }

    @discardableResult
    func recordPracticeResult(lesson: BeginnerLesson, step: LessonStep, selectedAnswer: String?, correct: Bool, mode: String, now: Date = Date()) -> LearningFeedback {
        var next = profile
        let correction = correct
            ? "Good answer. Keep the phrase active by reviewing it later."
            : "Correct answer: \(step.correctAnswer ?? step.prompt). Save this as a mistake and retry it in Smart Review."
        let feedback = mockFeedback(source: mode, correction: correction)
        addFeedback(feedback, in: &next)
        updateSkill(mode, title: mode, delta: 1, confidenceDelta: correct ? 4 : -3, in: &next)

        if !correct {
            addLearningObject(
                SavedLearningObject(
                    id: "mistake-\(step.id)",
                    kind: .mistake,
                    text: step.prompt,
                    translation: step.correctAnswer ?? step.helper,
                    source: mode,
                    note: "Mistake saved for retry.",
                    createdDay: dayString(for: now)
                ),
                in: &next,
                now: now
            )
        } else if let selectedAnswer {
            addLearningObject(
                SavedLearningObject(
                    id: "phrase-\(step.id)-\(stableID(selectedAnswer))",
                    kind: .phrase,
                    text: selectedAnswer,
                    translation: step.helper,
                    source: mode,
                    note: "Answered from \(lesson.title).",
                    createdDay: dayString(for: now)
                ),
                in: &next,
                now: now
            )
        }

        profile = next
        return feedback
    }

    @discardableResult
    func acceptSpeechPractice(lesson: BeginnerLesson, step: LessonStep, transcript: String, mode: String, now: Date = Date()) -> LearningFeedback {
        var next = profile
        let feedback = mockFeedback(source: mode, correction: "Transcript accepted. Stress the key phrase and keep the sentence short.")
        addFeedback(feedback, in: &next)
        addLearningObject(
            SavedLearningObject(
                id: "speech-\(step.id)-\(stableID(transcript))",
                kind: .phrase,
                text: transcript,
                translation: step.helper,
                source: mode,
                note: "Speech practice transcript.",
                createdDay: dayString(for: now)
            ),
            in: &next,
            now: now
        )
        updateSkill("Speaking", title: "Speaking confidence", delta: 1, confidenceDelta: 5, in: &next)
        profile = next
        return feedback
    }

    func recordReview(_ item: ScheduledReviewItem, remembered: Bool, now: Date = Date()) {
        var next = profile
        let reviewIndex: Int
        if let existingIndex = next.scheduledReviews.firstIndex(where: { $0.id == item.id }) {
            reviewIndex = existingIndex
        } else {
            next.scheduledReviews.append(item)
            reviewIndex = next.scheduledReviews.count - 1
        }

        next.scheduledReviews[reviewIndex].lastReviewedDay = dayString(for: now)
        next.scheduledReviews[reviewIndex].mistakeCount += remembered ? 0 : 1
        next.scheduledReviews[reviewIndex].ease = min(max(next.scheduledReviews[reviewIndex].ease + (remembered ? 0.12 : -0.18), 0.35), 0.98)

        let dayOffset = remembered ? max(1, Int(next.scheduledReviews[reviewIndex].ease * 5)) : 1
        let nextDate = calendar.date(byAdding: .day, value: dayOffset, to: now) ?? now
        next.scheduledReviews[reviewIndex].nextDueDay = dayString(for: nextDate)

        updateSkill("Review", title: "Review accuracy", delta: 1, confidenceDelta: remembered ? 3 : -2, in: &next)
        prependActivity(
            LearningActivity(id: "review-\(item.id)-\(dayString(for: now))", title: remembered ? "Reviewed an item" : "Marked a weak item", detail: item.prompt, symbol: remembered ? "bolt.fill" : "arrow.clockwise", dateLabel: "Today"),
            in: &next
        )
        profile = next
    }

    func recordConversationSession(title: String, detail: String, minutes: Int, transcript: String, strongPhrases: [String], weakPhrases: [String], now: Date = Date()) {
        var next = profile
        let usage = UsageSession(id: "usage-\(UUID().uuidString)", title: title, detail: detail, minutes: minutes, dateLabel: "Today")
        next.usageSessions.insert(usage, at: 0)

        var reviewIDs: [String] = []
        for phrase in strongPhrases {
            let object = SavedLearningObject(
                id: "strong-\(usage.id)-\(stableID(phrase))",
                kind: .roleplayPhrase,
                text: phrase,
                translation: "Strong phrase from \(title)",
                source: title,
                note: "Keep using this phrase.",
                createdDay: dayString(for: now)
            )
            addLearningObject(object, in: &next, now: now)
            reviewIDs.append("review-\(object.id)")
        }

        for phrase in weakPhrases {
            let object = SavedLearningObject(
                id: "weak-\(usage.id)-\(stableID(phrase))",
                kind: .mistake,
                text: phrase,
                translation: "Retry this phrase with clearer grammar.",
                source: title,
                note: "Generated from session feedback.",
                createdDay: dayString(for: now)
            )
            addLearningObject(object, in: &next, now: now)
            reviewIDs.append("review-\(object.id)")
        }

        let summary = LearningSessionSummary(
            id: "summary-\(usage.id)",
            title: title,
            transcript: transcript,
            corrections: weakPhrases.map { "Tighten: \($0)" },
            strongPhrases: strongPhrases,
            weakPhrases: weakPhrases,
            suggestedReviewIDs: reviewIDs,
            nextRecommendation: nextRecommendationForSession(title: title, weakPhrases: weakPhrases),
            dateLabel: "Today"
        )
        next.sessionSummaries.insert(summary, at: 0)
        addFeedback(mockFeedback(source: title, correction: summary.corrections.first ?? "Conversation completed."), in: &next)
        updateSkill("Speaking", title: "Speaking confidence", delta: 1, confidenceDelta: 4, in: &next)
        updateSkill("Listening", title: "Listening confidence", delta: 1, confidenceDelta: 2, in: &next)
        prependActivity(
            LearningActivity(id: "activity-\(usage.id)", title: "Completed \(title)", detail: "\(weakPhrases.count) review items created", symbol: "waveform", dateLabel: "Today"),
            in: &next
        )
        profile = next
    }

    @discardableResult
    func recordTutorCorrection(for message: String, now: Date = Date()) -> LearningFeedback {
        var next = profile
        let feedback = mockFeedback(source: "Tutor", correction: "Try a shorter learner sentence: \(message)")
        addFeedback(feedback, in: &next)
        addLearningObject(
            SavedLearningObject(
                id: "tutor-message-\(stableID(message))",
                kind: .tutorMessage,
                text: message,
                translation: "Tutor correction",
                source: "Tutor",
                note: feedback.betterPhrase,
                createdDay: dayString(for: now)
            ),
            in: &next,
            now: now
        )
        updateSkill("Tutor", title: "Tutor practice", delta: 1, confidenceDelta: 2, in: &next)
        profile = next
        return feedback
    }

    func removeLine(_ line: SavedLine) {
        var next = profile
        next.savedLines.removeAll { $0.id == line.id }
        profile = next
    }

    func toggleFavorite(_ roleplay: RoleplayScenario) {
        var next = profile
        if next.favoriteRoleplayIDs.contains(roleplay.id) {
            next.favoriteRoleplayIDs.remove(roleplay.id)
        } else {
            next.favoriteRoleplayIDs.insert(roleplay.id)
            prependActivity(
                LearningActivity(id: "favorite-\(roleplay.id)", title: "Added to favorites", detail: roleplay.title, symbol: "star.fill", dateLabel: "Today"),
                in: &next
            )
        }
        profile = next
    }

    func isFavorite(_ roleplay: RoleplayScenario) -> Bool {
        profile.favoriteRoleplayIDs.contains(roleplay.id)
    }

    func recordUsage(title: String, detail: String, minutes: Int) {
        var next = profile
        let usage = UsageSession(id: "usage-\(UUID().uuidString)", title: title, detail: detail, minutes: minutes, dateLabel: "Today")
        next.usageSessions.insert(usage, at: 0)
        prependActivity(
            LearningActivity(id: "activity-\(usage.id)", title: "Completed \(title)", detail: detail, symbol: "waveform", dateLabel: "Today"),
            in: &next
        )
        profile = next
    }

    func resetProgress() {
        var next = profile
        next.completedLessonIDs = []
        next.currentLessonID = BeginnerContent.firstLessonID(for: next.targetLanguage)
        next.streak = 0
        next.savedWords = []
        next.savedLines = []
        next.savedLearningObjects = []
        next.scheduledReviews = []
        next.feedbackEvents = []
        next.sessionSummaries = []
        next.skillProgress = []
        next.favoriteRoleplayIDs = []
        next.usageSessions = []
        next.activities = []
        next.lastCompletionDay = nil
        profile = next
    }

    func restartOnboarding() {
        var next = LearningProfile()
        next.dailyGoal = profile.dailyGoal
        next.hapticsEnabled = profile.hapticsEnabled
        next.soundEnabled = profile.soundEnabled
        profile = next
    }

    private func seededSavedLines(_ customLines: [SavedLine]) -> [SavedLine] {
        var lines = PhaseOneContent.savedLines
        for line in customLines where !lines.contains(where: { $0.id == line.id }) {
            lines.append(line)
        }
        return lines
    }

    private func seededUsageSessions(_ customSessions: [UsageSession]) -> [UsageSession] {
        var sessions = customSessions
        for session in PhaseOneContent.usageSessions where !sessions.contains(where: { $0.id == session.id }) {
            sessions.append(session)
        }
        return sessions
    }

    private func seededActivities(_ customActivities: [LearningActivity]) -> [LearningActivity] {
        var items = customActivities
        for activity in PhaseOneContent.activities where !items.contains(where: { $0.id == activity.id }) {
            items.append(activity)
        }
        return items
    }

    private func seededLearningObjects(_ customObjects: [SavedLearningObject]) -> [SavedLearningObject] {
        var objects = customObjects

        for line in seededSavedLines(profile.savedLines) {
            let object = SavedLearningObject(
                id: "line-\(line.id)",
                kind: .line,
                text: line.text,
                translation: line.translation,
                source: line.source,
                note: line.note,
                createdDay: "Seed"
            )
            if !objects.contains(where: { $0.id == object.id }) {
                objects.append(object)
            }
        }

        for word in profile.savedWords {
            let object = SavedLearningObject(
                id: "word-\(word.id)",
                kind: .word,
                text: word.term,
                translation: word.translation,
                source: "Saved word",
                note: word.example,
                createdDay: "Seed"
            )
            if !objects.contains(where: { $0.id == object.id }) {
                objects.append(object)
            }
        }

        return objects
    }

    private func seededScheduledReviews(_ customReviews: [ScheduledReviewItem]) -> [ScheduledReviewItem] {
        var reviews = customReviews
        let today = dayString(for: Date())

        for item in PhaseOneContent.reviewItems {
            let review = ScheduledReviewItem(
                id: item.id,
                objectID: item.id,
                kind: .phrase,
                prompt: item.prompt,
                answer: item.answer,
                source: item.source,
                lastReviewedDay: nil,
                nextDueDay: today,
                ease: Double(item.confidence) / 100,
                mistakeCount: 0,
                listeningFirst: true,
                speakingRetry: true
            )
            if !reviews.contains(where: { $0.id == review.id }) {
                reviews.append(review)
            }
        }

        for object in seededLearningObjects(profile.savedLearningObjects) {
            let review = reviewItem(for: object, now: Date())
            if !reviews.contains(where: { $0.id == review.id }) {
                reviews.append(review)
            }
        }

        return reviews
    }

    private func seededSkillProgress(_ customProgress: [SkillProgress]) -> [SkillProgress] {
        var progress = customProgress
        let defaults = [
            SkillProgress(id: "speaking", title: "Speaking confidence", completed: 0, confidence: 56),
            SkillProgress(id: "listening", title: "Listening confidence", completed: 0, confidence: 52),
            SkillProgress(id: "vocabulary", title: "Vocabulary growth", completed: profile.savedWords.count, confidence: 60),
            SkillProgress(id: "grammar", title: "Grammar weak points", completed: 0, confidence: 48),
            SkillProgress(id: "review", title: "Review accuracy", completed: 0, confidence: 62)
        ]

        for item in defaults where !progress.contains(where: { $0.id == item.id }) {
            progress.append(item)
        }

        return progress
    }

    private func addLearningObject(_ object: SavedLearningObject, in profile: inout LearningProfile, now: Date) {
        guard !profile.savedLearningObjects.contains(where: { $0.id == object.id }) else { return }
        profile.savedLearningObjects.insert(object, at: 0)

        let review = reviewItem(for: object, now: now)
        if !profile.scheduledReviews.contains(where: { $0.id == review.id }) {
            profile.scheduledReviews.insert(review, at: 0)
        }
    }

    private func reviewItem(for object: SavedLearningObject, now: Date) -> ScheduledReviewItem {
        ScheduledReviewItem(
            id: "review-\(object.id)",
            objectID: object.id,
            kind: object.kind,
            prompt: reviewPrompt(for: object),
            answer: object.translation,
            source: object.source,
            lastReviewedDay: nil,
            nextDueDay: dayString(for: now),
            ease: object.kind == .mistake ? 0.42 : 0.68,
            mistakeCount: object.kind == .mistake ? 1 : 0,
            listeningFirst: object.kind != .word,
            speakingRetry: object.kind != .word
        )
    }

    private func reviewPrompt(for object: SavedLearningObject) -> String {
        switch object.kind {
        case .word:
            return "What does \(object.text) mean?"
        case .mistake:
            return "Retry: \(object.text)"
        case .tutorMessage:
            return "Use this Tutor phrase: \(object.text)"
        default:
            return "Review: \(object.text)"
        }
    }

    private func addFeedback(_ feedback: LearningFeedback, in profile: inout LearningProfile) {
        profile.feedbackEvents.removeAll { $0.id == feedback.id }
        profile.feedbackEvents.insert(feedback, at: 0)
        profile.feedbackEvents = Array(profile.feedbackEvents.prefix(30))
    }

    private func mockFeedback(source: String, correction: String) -> LearningFeedback {
        let day = dayString(for: Date())
        let seed = abs(stableID(source + correction).hashValue)
        return LearningFeedback(
            id: "feedback-\(stableID(source))-\(stableID(correction))-\(day)",
            source: source,
            pronunciation: 72 + seed % 12,
            grammar: 68 + seed % 14,
            vocabulary: 74 + seed % 10,
            fluency: 66 + seed % 16,
            meaning: 76 + seed % 12,
            confidence: 70 + seed % 18,
            correction: correction,
            betterPhrase: "Try: \(correction.replacingOccurrences(of: "Correct answer: ", with: ""))",
            createdDay: day
        )
    }

    private func updateSkill(_ id: String, title: String, delta: Int, confidenceDelta: Int, in profile: inout LearningProfile) {
        let normalizedID = stableID(id)
        if let index = profile.skillProgress.firstIndex(where: { $0.id == normalizedID }) {
            profile.skillProgress[index].completed += delta
            profile.skillProgress[index].confidence = min(max(profile.skillProgress[index].confidence + confidenceDelta, 0), 100)
        } else {
            profile.skillProgress.append(
                SkillProgress(
                    id: normalizedID,
                    title: title,
                    completed: max(delta, 0),
                    confidence: min(max(56 + confidenceDelta, 0), 100)
                )
            )
        }
    }

    private func nextRecommendationForSession(title: String, weakPhrases: [String]) -> String {
        if let weakPhrase = weakPhrases.first {
            return "Review: \(weakPhrase)"
        }
        return "Try another \(title.lowercased()) session"
    }

    private func prependActivity(_ activity: LearningActivity, in profile: inout LearningProfile) {
        profile.activities.removeAll { $0.id == activity.id }
        profile.activities.insert(activity, at: 0)
    }

    private func updateStreak(in profile: inout LearningProfile, now: Date) {
        let today = dayString(for: now)
        guard profile.lastCompletionDay != today else { return }

        let yesterday = dayString(for: calendar.date(byAdding: .day, value: -1, to: now) ?? now)
        if profile.lastCompletionDay == yesterday {
            profile.streak += 1
        } else {
            profile.streak = 1
        }

        profile.lastCompletionDay = today
    }

    private func save(_ profile: LearningProfile) {
        guard let data = try? JSONEncoder().encode(profile) else { return }
        storage.set(data, forKey: storageKey)
    }

    private func dayString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    private func stableID(_ text: String) -> String {
        let characters = text.lowercased().map { character -> Character in
            character.isLetter || character.isNumber ? character : "-"
        }
        let collapsed = String(characters).split(separator: "-").joined(separator: "-")
        return String(collapsed.prefix(48)).isEmpty ? "item" : String(collapsed.prefix(48))
    }

    private func nextFirstLessonID(for language: TargetLanguage, completedLessonIDs: Set<String>) -> String {
        BeginnerContent.lessons(for: language).first { !completedLessonIDs.contains($0.id) }?.id ?? BeginnerContent.firstLessonID(for: language)
    }

    private static func restore(from storage: UserDefaults, key: String) -> LearningProfile? {
        guard let data = storage.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(LearningProfile.self, from: data)
    }

    private static func sanitized(_ profile: LearningProfile) -> LearningProfile {
        var next = profile
        let validIDs = Set(TargetLanguage.allCases.flatMap { BeginnerContent.lessons(for: $0).map(\.id) })
        next.completedLessonIDs = next.completedLessonIDs.intersection(validIDs)
        next.dailyGoal = min(max(next.dailyGoal, 1), 6)
        if next.savedLines.isEmpty {
            next.savedLines = []
        }
        if !next.targetLanguage.isAvailable {
            next.targetLanguage = .french
        }
        let currentLanguageIDs = Set(BeginnerContent.lessons(for: next.targetLanguage).map(\.id))
        if !currentLanguageIDs.contains(next.currentLessonID) {
            next.currentLessonID = BeginnerContent.lessons(for: next.targetLanguage).first { !next.completedLessonIDs.contains($0.id) }?.id ?? BeginnerContent.firstLessonID(for: next.targetLanguage)
        }
        return next
    }

    private static func launchAdjusted(_ profile: LearningProfile) -> LearningProfile {
        guard ProcessInfo.processInfo.arguments.contains("-ConverlaxUseEnglishContent") else {
            return profile
        }

        var next = profile
        next.targetLanguage = .english
        next.currentLevel = .beginner
        next.currentLessonID = BeginnerContent.firstLessonID(for: .english)
        next.hasCompletedOnboarding = true
        return next
    }
}

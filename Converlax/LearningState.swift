import Foundation

final class LearningState: ObservableObject {
    @Published private(set) var profile: LearningProfile {
        didSet { save(profile) }
    }

    private let storage: UserDefaults
    private let calendar: Calendar
    private let fileURL: URL?
    private let storageKey = "converlax.learningProfile.v3"
    private let legacyStorageKey = "converlax.learningProfile.v2"
    private let oldestStorageKey = "converlax.learningProfile.v1"

    init(storage: UserDefaults = .standard, calendar: Calendar = .current, fileURL: URL? = LearningState.defaultProfileFileURL()) {
        self.storage = storage
        self.calendar = calendar
        self.fileURL = fileURL

        if let restored = Self.restore(from: storage, key: storageKey) ?? Self.restore(from: fileURL) ?? Self.restore(from: storage, key: legacyStorageKey) ?? Self.restore(from: storage, key: oldestStorageKey) {
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

    var hasStartedLearning: Bool {
        completedLessonCount > 0 ||
        !profile.savedWords.isEmpty ||
        !profile.savedLines.isEmpty ||
        !profile.feedbackEvents.isEmpty ||
        !profile.sessionSummaries.isEmpty ||
        !profile.activities.isEmpty
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
        return scheduledReviewItems
            .filter { $0.nextDueDay <= today }
            .sorted { lhs, rhs in
                if lhs.nextDueDay != rhs.nextDueDay {
                    return lhs.nextDueDay < rhs.nextDueDay
                }
                let lhsPersonal = isPersonalReviewItem(lhs)
                let rhsPersonal = isPersonalReviewItem(rhs)
                if lhsPersonal != rhsPersonal {
                    return lhsPersonal
                }
                if lhs.mistakeCount != rhs.mistakeCount {
                    return lhs.mistakeCount > rhs.mistakeCount
                }
                return lhs.id < rhs.id
            }
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

    var nextRecommendation: NextLearningRecommendation {
        if !hasStartedLearning {
            return NextLearningRecommendation(
                title: "Start \(currentLesson.title.lowercased())",
                detail: "Begin with one useful speaking lesson.",
                reason: "New learners should start with the first course lesson.",
                symbol: "sparkles"
            )
        }

        let personalDueItems = personalDueReviewItems()
        if !personalDueItems.isEmpty {
            return NextLearningRecommendation(
                title: "Review \(personalDueItems.count) due \(personalDueItems.count == 1 ? "item" : "items")",
                detail: "From your saved lines, lesson answers, and speaking feedback.",
                reason: "These were created by recent learning activity.",
                symbol: "bolt.fill"
            )
        }

        if !isCompleted(currentLesson) {
            return NextLearningRecommendation(
                title: "Continue \(currentLesson.title.lowercased())",
                detail: "Next lesson in your \(profile.targetLanguage.rawValue) path.",
                reason: "Course progress moves forward from here.",
                symbol: "play.fill"
            )
        }

        if let nextLesson = courseLessons.first(where: { !profile.completedLessonIDs.contains($0.id) }) {
            return NextLearningRecommendation(
                title: "Start \(nextLesson.title.lowercased())",
                detail: "You finished the previous lesson.",
                reason: "This is the next unlocked course step.",
                symbol: "arrow.forward.circle.fill"
            )
        }

        if let weakSkill = skillProgress.filter({ $0.completed > 0 }).min(by: { $0.confidence < $1.confidence }) {
            return NextLearningRecommendation(
                title: "Practice \(weakSkill.title.lowercased())",
                detail: "Confidence is \(weakSkill.confidence)%, lower than your other active skills.",
                reason: "Recommendations use your weakest active skill.",
                symbol: "target"
            )
        }

        if !savedLines.isEmpty {
            return NextLearningRecommendation(
                title: "Practice saved lines",
                detail: "\(savedLines.count) saved \(savedLines.count == 1 ? "line" : "lines") ready.",
                reason: "Saved content is always available for review.",
                symbol: "bookmark.fill"
            )
        }

        return NextLearningRecommendation(
            title: "Start \(currentLesson.title.lowercased())",
            detail: "Begin with one useful speaking lesson.",
            reason: "No personal review items are due yet.",
            symbol: "sparkles"
        )
    }

    var journeyProgress: JourneyProgress {
        journeyProgress(for: profile)
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

    func completionCelebration(
        from previousProfile: LearningProfile,
        title: String,
        subtitle: String,
        savedItemsCreated: Int? = nil,
        nextActionTitle: String? = nil,
        nextActionDetail: String? = nil
    ) -> CompletionCelebrationResult {
        let previousProgress = journeyProgress(for: previousProfile)
        let currentProgress = journeyProgress
        let savedObjectDelta = max(0, profile.savedLearningObjects.count - previousProfile.savedLearningObjects.count)
        let savedContentDelta = max(
            0,
            profile.savedLines.count - previousProfile.savedLines.count + profile.savedWords.count - previousProfile.savedWords.count
        )
        let recommendation = nextRecommendation

        return CompletionCelebrationResult(
            title: title,
            subtitle: subtitle,
            xpEarned: max(0, currentProgress.totalXP - previousProgress.totalXP),
            levelBefore: previousProgress.levelNumber,
            levelAfter: currentProgress.levelNumber,
            levelProgressBefore: previousProgress.levelProgress,
            levelProgressAfter: currentProgress.levelProgress,
            savedItemsCreated: savedItemsCreated ?? max(savedObjectDelta, savedContentDelta),
            nextActionTitle: nextActionTitle ?? recommendation.title,
            nextActionDetail: nextActionDetail ?? recommendation.detail
        )
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
        let today = dayString(for: now)
        let inserted = next.completedLessonIDs.insert(lesson.id).inserted
        var reviewIDs: [String] = []

        for word in lesson.savedWords {
            if !next.savedWords.contains(word) {
                next.savedWords.append(word)
            }
            let object = SavedLearningObject(
                id: "word-\(word.id)",
                kind: .word,
                text: word.term,
                translation: word.translation,
                source: lesson.title,
                note: word.example,
                createdDay: today
            )
            addLearningObject(object, in: &next, now: now)
            reviewIDs.append("review-\(object.id)")
        }

        for object in lessonCompletionObjects(for: lesson, now: now) {
            addLearningObject(object, in: &next, now: now)
            reviewIDs.append("review-\(object.id)")
        }

        let usage = UsageSession(
            id: "usage-lesson-\(lesson.id)-\(today)",
            title: inserted ? "Completed \(lesson.title)" : "Practiced \(lesson.title)",
            detail: "\(lesson.minutes) min lesson",
            minutes: lesson.minutes,
            dateLabel: "Today"
        )
        let createdDailySession = upsertUsageSession(usage, in: &next)

        let uniqueReviewIDs = uniqueReviewIDs(reviewIDs)
        let summary = LearningSessionSummary(
            id: "summary-\(usage.id)",
            title: lesson.title,
            transcript: lesson.steps.prefix(3).map(\.prompt).joined(separator: " "),
            corrections: [],
            strongPhrases: lesson.savedWords.prefix(2).map(\.term),
            weakPhrases: [],
            suggestedReviewIDs: uniqueReviewIDs,
            nextRecommendation: lessonSummaryRecommendation(after: lesson, reviewCount: uniqueReviewIDs.count, in: next),
            dateLabel: "Today"
        )
        upsertSessionSummary(summary, in: &next)

        if inserted || createdDailySession {
            updateStreak(in: &next, now: now)
            addFeedback(
                makeFeedback(
                    source: lesson.title,
                    prompt: lesson.title,
                    attempt: "Completed lesson",
                    correction: "Lesson completed with a complete pass through the core prompts.",
                    naturalPhrase: lesson.steps.last?.prompt ?? lesson.title,
                    savedTakeaway: lesson.steps.last?.prompt ?? lesson.title,
                    nextAction: summary.nextRecommendation
                ),
                in: &next
            )
            updateSkill("Course", title: "Course completion", delta: 1, confidenceDelta: 4, in: &next)
            if !lesson.savedWords.isEmpty {
                updateSkill("Vocabulary", title: "Vocabulary growth", delta: lesson.savedWords.count, confidenceDelta: 2, in: &next)
            }
            prependActivity(
                LearningActivity(
                    id: "lesson-\(lesson.id)-\(today)",
                    title: inserted ? "Completed \(lesson.title)" : "Practiced \(lesson.title)",
                    detail: uniqueReviewIDs.isEmpty ? "\(lesson.minutes) min lesson" : "\(uniqueReviewIDs.count) review items ready",
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
        let now = Date()
        let today = dayString(for: now)
        if !next.savedWords.contains(word) {
            next.savedWords.append(word)
        }
        addLearningObject(
            SavedLearningObject(
                id: "word-\(word.id)",
                kind: .word,
                text: word.term,
                translation: word.translation,
                source: "Saved word",
                note: word.example,
                createdDay: today
            ),
            in: &next,
            now: now
        )
        updateSkill("Vocabulary", title: "Vocabulary growth", delta: 1, confidenceDelta: 1, in: &next)
        prependActivity(
            LearningActivity(id: "saved-word-\(word.id)-\(today)", title: "Saved a word", detail: word.term, symbol: "bookmark.fill", dateLabel: "Today"),
            in: &next
        )
        profile = next
    }

    func removeWord(_ word: SavedWord) {
        var next = profile
        let objectID = "word-\(word.id)"
        next.savedWords.removeAll { $0.id == word.id }
        next.savedLearningObjects.removeAll { $0.id == objectID }
        next.scheduledReviews.removeAll { $0.objectID == objectID || $0.id == "review-\(objectID)" }
        profile = next
    }

    func saveLine(_ line: SavedLine) {
        var next = profile
        let now = Date()
        let today = dayString(for: now)
        if !seededSavedLines(next.savedLines).contains(where: { $0.id == line.id }) {
            next.savedLines.append(line)
        }
        addLearningObject(
            SavedLearningObject(
                id: "line-\(line.id)",
                kind: .line,
                text: line.text,
                translation: line.translation,
                source: line.source,
                note: line.note,
                createdDay: today
            ),
            in: &next,
            now: now
        )
        prependActivity(
            LearningActivity(id: "saved-\(line.id)-\(today)", title: "Saved a line", detail: line.text, symbol: "bookmark.fill", dateLabel: "Today"),
            in: &next
        )
        profile = next
    }

    @discardableResult
    func recordPracticeResult(lesson: BeginnerLesson, step: LessonStep, selectedAnswer: String?, correct: Bool, mode: String, now: Date = Date()) -> LearningFeedback {
        var next = profile
        let correctedLine = correctedLine(for: step)
        let attempted = selectedAnswer ?? "No answer captured"
        let correction = correct
            ? "Good: \(correctedLine)"
            : "Use: \(correctedLine)"
        let feedback = makeFeedback(
            source: mode,
            prompt: step.prompt,
            attempt: attempted,
            correction: correction,
            naturalPhrase: naturalPhrase(for: step, fallback: correctedLine),
            pronunciationTip: rhythmTip(for: correctedLine),
            savedTakeaway: correct ? naturalPhrase(for: step, fallback: correctedLine) : correctedLine,
            nextAction: correct ? "Say the line aloud once, then continue." : "Repeat the corrected line once before moving on."
        )
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
        let cleanTranscript = transcript.trimmingCharacters(in: .whitespacesAndNewlines)
        let correctedLine = correctedSpeechLine(for: step, transcript: cleanTranscript)
        let naturalLine = naturalPhrase(for: step, fallback: self.correctedLine(for: step))
        let feedback = makeFeedback(
            source: speechFeedbackSource(for: mode),
            prompt: step.prompt,
            attempt: cleanTranscript,
            correction: correctedLine,
            naturalPhrase: naturalLine,
            pronunciationTip: rhythmTip(for: correctedLine),
            savedTakeaway: naturalLine,
            nextAction: "Say the natural phrase once more, then continue."
        )
        addFeedback(feedback, in: &next)
        addLearningObject(
            SavedLearningObject(
                id: "speech-\(step.id)-\(stableID(feedback.savedTakeaway))",
                kind: .phrase,
                text: feedback.savedTakeaway,
                translation: feedback.correction,
                source: mode,
                note: feedback.pronunciationTip,
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
        let today = dayString(for: now)
        let reviewIndex: Int
        if let existingIndex = next.scheduledReviews.firstIndex(where: { $0.id == item.id }) {
            reviewIndex = existingIndex
        } else {
            next.scheduledReviews.append(item)
            reviewIndex = next.scheduledReviews.count - 1
        }

        next.scheduledReviews[reviewIndex].lastReviewedDay = today
        next.scheduledReviews[reviewIndex].mistakeCount += remembered ? 0 : 1
        next.scheduledReviews[reviewIndex].ease = min(max(next.scheduledReviews[reviewIndex].ease + (remembered ? 0.12 : -0.18), 0.35), 0.98)
        next.scheduledReviews[reviewIndex].listeningFirst = !remembered && item.kind != .word
        next.scheduledReviews[reviewIndex].speakingRetry = !remembered || item.kind != .word

        let dayOffset = remembered ? max(1, Int(next.scheduledReviews[reviewIndex].ease * 5)) : 1
        let nextDate = calendar.date(byAdding: .day, value: dayOffset, to: now) ?? now
        next.scheduledReviews[reviewIndex].nextDueDay = dayString(for: nextDate)

        let usage = UsageSession(
            id: "usage-review-\(today)",
            title: "Smart Review",
            detail: remembered ? "Remembered: \(item.prompt)" : "Needs practice: \(item.prompt)",
            minutes: 3,
            dateLabel: "Today"
        )
        if upsertUsageSession(usage, in: &next) {
            updateStreak(in: &next, now: now)
        }
        updateSkill("Review", title: "Review accuracy", delta: 1, confidenceDelta: remembered ? 3 : -2, in: &next)
        prependActivity(
            LearningActivity(id: "review-\(item.id)-\(today)", title: remembered ? "Reviewed an item" : "Marked a weak item", detail: item.prompt, symbol: remembered ? "bolt.fill" : "arrow.clockwise", dateLabel: "Today"),
            in: &next
        )
        profile = next
    }

    @discardableResult
    func recordConversationSession(title: String, detail: String, minutes: Int, transcript: String, strongPhrases: [String], weakPhrases: [String], prompt: String = "", now: Date = Date()) -> (summary: LearningSessionSummary, feedback: LearningFeedback) {
        var next = profile
        let today = dayString(for: now)
        let usage = UsageSession(
            id: "usage-session-\(stableID(title))-\(stableID(transcript))-\(today)",
            title: title,
            detail: detail,
            minutes: minutes,
            dateLabel: "Today"
        )
        let createdSession = upsertUsageSession(usage, in: &next)

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

        let sessionPrompt = prompt.isEmpty ? detail : prompt
        let feedback = makeFeedback(
            source: title,
            prompt: sessionPrompt,
            attempt: transcript,
            correction: conversationCorrection(transcript: transcript, weakPhrases: weakPhrases, strongPhrases: strongPhrases),
            naturalPhrase: conversationNaturalPhrase(transcript: transcript, strongPhrases: strongPhrases),
            pronunciationTip: conversationTip(for: transcript),
            savedTakeaway: conversationTakeaway(weakPhrases: weakPhrases, strongPhrases: strongPhrases, transcript: transcript),
            nextAction: nextRecommendationForSession(title: title, weakPhrases: weakPhrases)
        )

        if reviewIDs.isEmpty {
            let object = SavedLearningObject(
                id: "session-takeaway-\(usage.id)-\(stableID(feedback.savedTakeaway))",
                kind: .phrase,
                text: feedback.savedTakeaway,
                translation: feedback.correction,
                source: title,
                note: feedback.pronunciationTip,
                createdDay: dayString(for: now)
            )
            addLearningObject(object, in: &next, now: now)
            reviewIDs.append("review-\(object.id)")
        }

        let summary = LearningSessionSummary(
            id: "summary-\(usage.id)",
            title: title,
            transcript: transcript,
            corrections: [feedback.correction],
            strongPhrases: strongPhrases,
            weakPhrases: weakPhrases,
            suggestedReviewIDs: reviewIDs,
            nextRecommendation: feedback.nextAction,
            dateLabel: "Today"
        )
        upsertSessionSummary(summary, in: &next)
        addFeedback(feedback, in: &next)
        if createdSession {
            updateStreak(in: &next, now: now)
            updateSkill("Speaking", title: "Speaking confidence", delta: 1, confidenceDelta: 4, in: &next)
            updateSkill("Listening", title: "Listening confidence", delta: 1, confidenceDelta: 2, in: &next)
            prependActivity(
                LearningActivity(id: "activity-\(usage.id)", title: "Completed \(title)", detail: "\(reviewIDs.count) review items created", symbol: "waveform", dateLabel: "Today"),
                in: &next
            )
        }
        profile = next
        return (summary, feedback)
    }

    @discardableResult
    func recordTutorCorrection(for message: String, now: Date = Date()) -> LearningFeedback {
        var next = profile
        let natural = tutorNaturalPhrase(for: message)
        let feedback = makeFeedback(
            source: "Tutor",
            prompt: "Tutor chat",
            attempt: message,
            correction: "Try: \(natural)",
            naturalPhrase: natural,
            pronunciationTip: tutorTip(for: natural),
            savedTakeaway: natural,
            nextAction: "Save the phrase, then say it once in voice mode."
        )
        addFeedback(feedback, in: &next)
        addLearningObject(
            SavedLearningObject(
                id: "tutor-message-\(stableID(natural))",
                kind: .tutorMessage,
                text: natural,
                translation: feedback.correction,
                source: "Tutor",
                note: feedback.pronunciationTip,
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
        let objectID = "line-\(line.id)"
        next.savedLines.removeAll { $0.id == line.id }
        next.savedLearningObjects.removeAll { $0.id == objectID }
        next.scheduledReviews.removeAll { $0.objectID == objectID || $0.id == "review-\(objectID)" }
        profile = next
    }

    func toggleFavorite(_ roleplay: RoleplayScenario) {
        var next = profile
        if next.favoriteRoleplayIDs.contains(roleplay.id) {
            next.favoriteRoleplayIDs.remove(roleplay.id)
        } else {
            next.favoriteRoleplayIDs.insert(roleplay.id)
            prependActivity(
                LearningActivity(id: "favorite-\(roleplay.id)", title: "Saved a situation", detail: roleplay.title, symbol: "star.fill", dateLabel: "Today"),
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
        let today = dayString(for: Date())
        let usage = UsageSession(id: "usage-\(stableID(title))-\(today)", title: title, detail: detail, minutes: minutes, dateLabel: "Today")
        upsertUsageSession(usage, in: &next)
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

        if !hasStartedLearning {
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
        }

        let reviewObjects = hasStartedLearning ? profile.savedLearningObjects : seededLearningObjects(profile.savedLearningObjects)
        for object in reviewObjects {
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

    private func journeyProgress(for snapshot: LearningProfile) -> JourneyProgress {
        let lessons = BeginnerContent.lessons(for: snapshot.targetLanguage)
        let completedCount = lessons.filter { snapshot.completedLessonIDs.contains($0.id) }.count
        return JourneyProgress(
            profile: snapshot,
            completedLessonCount: completedCount,
            totalLessonCount: lessons.count
        )
    }

    private func personalDueReviewItems() -> [ScheduledReviewItem] {
        dueReviewItems.filter(isPersonalReviewItem)
    }

    private func isPersonalReviewItem(_ item: ScheduledReviewItem) -> Bool {
        let persistedReviewIDs = Set(profile.scheduledReviews.map(\.id))
        let seededStandaloneIDs = Set(PhaseOneContent.reviewItems.map(\.id))
        return persistedReviewIDs.contains(item.id) && !seededStandaloneIDs.contains(item.id)
    }

    private func lessonCompletionObjects(for lesson: BeginnerLesson, now: Date) -> [SavedLearningObject] {
        let today = dayString(for: now)
        let reviewableSteps = lesson.steps
            .filter { $0.kind == .speak || $0.kind == .teach }
            .prefix(2)

        return reviewableSteps.map { step in
            let phrase = naturalPhrase(for: step, fallback: correctedLine(for: step))
            return SavedLearningObject(
                id: "lesson-\(lesson.id)-step-\(step.id)",
                kind: step.kind == .speak ? .phrase : .line,
                text: phrase,
                translation: step.helper,
                source: lesson.title,
                note: "Added when you completed the lesson.",
                createdDay: today
            )
        }
    }

    private func uniqueReviewIDs(_ ids: [String]) -> [String] {
        var seen: Set<String> = []
        return ids.filter { seen.insert($0).inserted }
    }

    private func lessonSummaryRecommendation(after lesson: BeginnerLesson, reviewCount: Int, in profile: LearningProfile) -> String {
        if reviewCount > 0 {
            return "Review \(reviewCount) new \(reviewCount == 1 ? "item" : "items"), then continue the course."
        }
        if let upcoming = BeginnerContent.lessons(for: profile.targetLanguage).first(where: { !profile.completedLessonIDs.contains($0.id) }) {
            return "Continue with \(upcoming.title)."
        }
        return "Practice saved lines to keep the unit active."
    }

    @discardableResult
    private func upsertUsageSession(_ session: UsageSession, in profile: inout LearningProfile) -> Bool {
        let existed = profile.usageSessions.contains { $0.id == session.id }
        profile.usageSessions.removeAll { $0.id == session.id }
        profile.usageSessions.insert(session, at: 0)
        profile.usageSessions = Array(profile.usageSessions.prefix(40))
        return !existed
    }

    private func upsertSessionSummary(_ summary: LearningSessionSummary, in profile: inout LearningProfile) {
        profile.sessionSummaries.removeAll { $0.id == summary.id }
        profile.sessionSummaries.insert(summary, at: 0)
        profile.sessionSummaries = Array(profile.sessionSummaries.prefix(30))
    }

    private func addLearningObject(_ object: SavedLearningObject, in profile: inout LearningProfile, now: Date) {
        if !profile.savedLearningObjects.contains(where: { $0.id == object.id }) {
            profile.savedLearningObjects.insert(object, at: 0)
            profile.savedLearningObjects = Array(profile.savedLearningObjects.prefix(80))
        }

        let review = reviewItem(for: object, now: now)
        if !profile.scheduledReviews.contains(where: { $0.id == review.id }) {
            profile.scheduledReviews.insert(review, at: 0)
            profile.scheduledReviews = Array(profile.scheduledReviews.prefix(100))
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

    private func makeFeedback(
        source: String,
        prompt: String = "",
        attempt: String = "",
        correction: String,
        naturalPhrase: String? = nil,
        pronunciationTip: String? = nil,
        savedTakeaway: String? = nil,
        nextAction: String? = nil
    ) -> LearningFeedback {
        let day = dayString(for: Date())
        let seed = abs(stableID(source + attempt + correction).hashValue)
        let pronunciation = 72 + seed % 12
        let fluency = 66 + seed % 16
        let meaning = 76 + seed % 12
        let clarity = (pronunciation + fluency + meaning) / 3
        let betterPhrase = naturalPhrase ?? "Try: \(correction.replacingOccurrences(of: "Use: ", with: ""))"
        return LearningFeedback(
            id: "feedback-\(stableID(source))-\(stableID(attempt + correction))-\(day)",
            source: source,
            pronunciation: pronunciation,
            grammar: 68 + seed % 14,
            vocabulary: 74 + seed % 10,
            fluency: fluency,
            meaning: meaning,
            confidence: 70 + seed % 18,
            promptText: prompt,
            attemptedText: attempt,
            correction: correction,
            betterPhrase: betterPhrase,
            pronunciationTip: pronunciationTip ?? "Say the phrase in one smooth breath and keep the final word clear.",
            claritySignal: claritySignal(for: clarity),
            savedTakeaway: savedTakeaway ?? betterPhrase,
            nextAction: nextAction ?? "Try one more spoken attempt.",
            createdDay: day
        )
    }

    private func correctedLine(for step: LessonStep) -> String {
        if step.prompt.contains("___"), let answer = step.correctAnswer {
            return step.prompt.replacingOccurrences(of: "___", with: answer)
        }
        return step.correctAnswer ?? step.prompt
    }

    private func speechFeedbackSource(for mode: String) -> String {
        mode.localizedCaseInsensitiveContains("speaking") ? mode : "\(mode) speaking"
    }

    private func correctedSpeechLine(for step: LessonStep, transcript: String) -> String {
        let expected = correctedLine(for: step)
        guard !transcript.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return "No clear speech was captured. Try: \(expected)"
        }

        if expected.localizedCaseInsensitiveContains("reservation") {
            return "Bonjour, j'ai une reservation. Add a small pause after Bonjour."
        }

        if transcript == expected {
            return "Clear attempt. Keep this version: \(expected)"
        }

        return "Use this clearer version: \(expected)"
    }

    private func naturalPhrase(for step: LessonStep, fallback: String) -> String {
        let line = correctedLine(for: step)
        if line.localizedCaseInsensitiveContains("reservation") {
            return "Bonjour, j'ai une reservation under Kevin."
        }
        if line.contains("___"), let answer = step.correctAnswer {
            return line.replacingOccurrences(of: "___", with: answer)
        }
        return fallback
    }

    private func rhythmTip(for line: String) -> String {
        if line.contains(",") {
            return "Pause briefly at the comma, then finish the sentence without rushing."
        }
        if line.contains("?") {
            return "Lift your voice slightly on the final word so it sounds like a question."
        }
        return "Stress the main noun or verb, then let the last word land clearly."
    }

    private func conversationCorrection(transcript: String, weakPhrases: [String], strongPhrases: [String]) -> String {
        if let weak = weakPhrases.first {
            if weak.localizedCaseInsensitiveContains("in night") {
                return "Correct it to: I usually study English at night."
            }
            return "Tighten this line: \(weak)"
        }
        if let strong = strongPhrases.first {
            return "Keep this clear version: \(strong)"
        }
        return "Keep it short and complete: \(transcript)"
    }

    private func conversationNaturalPhrase(transcript: String, strongPhrases: [String]) -> String {
        if let strong = strongPhrases.first {
            return strong
        }
        return transcript
    }

    private func conversationTakeaway(weakPhrases: [String], strongPhrases: [String], transcript: String) -> String {
        if let weak = weakPhrases.first, weak.localizedCaseInsensitiveContains("in night") {
            return "I usually study English at night."
        }
        if let strong = strongPhrases.first {
            return strong
        }
        return transcript
    }

    private func conversationTip(for transcript: String) -> String {
        if transcript.contains("?") {
            return "Make a short pause before the question so the listener hears two clear ideas."
        }
        return "Keep the sentence to one idea, then pause before adding more detail."
    }

    private func tutorNaturalPhrase(for message: String) -> String {
        let lowercased = message.lowercased()
        if lowercased.contains("order coffee") {
            return "Could I have a coffee, please?"
        }
        if lowercased.contains("travel") {
            return "Could you help me find the station?"
        }
        if lowercased.contains("saved words") {
            return "Can we practice my saved words?"
        }
        return message.hasSuffix("?") ? message : "\(message)."
    }

    private func tutorTip(for phrase: String) -> String {
        if phrase.hasSuffix("?") {
            return "Use a gentle rising tone at the end of the question."
        }
        return "Say the first half slowly, then finish with a confident final word."
    }

    private func claritySignal(for score: Int) -> String {
        if score >= 78 {
            return "Clear enough to use in conversation"
        }
        if score >= 68 {
            return "Mostly clear; one slower retry will help"
        }
        return "Needs a slower repeat before you continue"
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
            return "Repeat this once, then review it today: \(weakPhrase)"
        }
        return "Try another \(title.lowercased()) session with one longer answer."
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
        storage.synchronize()
        if let fileURL {
            try? FileManager.default.createDirectory(at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            try? data.write(to: fileURL, options: [.atomic])
        }
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

    private static func restore(from fileURL: URL?) -> LearningProfile? {
        guard let fileURL, let data = try? Data(contentsOf: fileURL) else { return nil }
        return try? JSONDecoder().decode(LearningProfile.self, from: data)
    }

    private static func defaultProfileFileURL() -> URL? {
        FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first?
            .appendingPathComponent("Converlax", isDirectory: true)
            .appendingPathComponent("learning-profile-v3.json")
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
        let arguments = ProcessInfo.processInfo.arguments
        guard arguments.contains("-ConverlaxUseEnglishContent") else {
            return profile
        }

        let launchLessonID = arguments.firstIndex(of: "-ConverlaxInitialLessonID").flatMap { idIndex in
            arguments.indices.contains(idIndex + 1) ? arguments[idIndex + 1] : nil
        }

        var next = profile
        next.targetLanguage = .english
        next.currentLevel = .beginner
        next.currentLessonID = launchLessonID.flatMap(BeginnerContent.lesson(id:))?.id ?? BeginnerContent.firstLessonID(for: .english)
        next.hasCompletedOnboarding = true
        return next
    }
}

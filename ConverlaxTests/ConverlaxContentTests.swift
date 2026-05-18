import XCTest
@testable import Converlax

final class ConverlaxContentTests: XCTestCase {
    private let storageKey = "converlax.learningProfile.v3"

    func testEnglishCourseSupportsSustainedDailyPractice() {
        let lessons = BeginnerContent.lessons(for: .english)

        XCTAssertGreaterThanOrEqual(lessons.count, 60)
        XCTAssertEqual(lessons.first?.id, BeginnerContent.firstLessonID(for: .english))
        XCTAssertEqual(lessons.map(\.unit), lessons.map(\.unit).sorted(), "Course order should remain stable by unit.")
        XCTAssertEqual(lessons.map { BeginnerContent.lesson(id: $0.id)?.id }, lessons.map(\.id))
    }

    func testLessonIDsAreUniqueAcrossAvailableContent() {
        let lessons = BeginnerContent.lessons(for: .english) + BeginnerContent.lessons(for: .french)
        let ids = lessons.map(\.id)
        let stepIDs = lessons.flatMap { $0.steps.map(\.id) }

        XCTAssertEqual(Set(ids).count, ids.count)
        XCTAssertEqual(Set(stepIDs).count, stepIDs.count)
    }

    func testEveryEnglishLessonHasSpeakableStepsAndReviewSeeds() {
        for lesson in BeginnerContent.lessons(for: .english) {
            XCTAssertGreaterThanOrEqual(lesson.steps.count, 5, lesson.id)
            XCTAssertTrue(lesson.steps.contains { [.speak, .roleplay, .freeResponse].contains($0.kind) }, lesson.id)
            XCTAssertFalse(lesson.modelPhrase.isEmpty, lesson.id)
            XCTAssertFalse(lesson.primarySkill.isEmpty, lesson.id)
            XCTAssertFalse(lesson.roleplayPrompt.isEmpty, lesson.id)
            XCTAssertGreaterThanOrEqual(lesson.savedWords.count, 3, lesson.id)
            XCTAssertFalse(lesson.reviewPrompts.isEmpty, lesson.id)
            XCTAssertFalse(lesson.naturalVersionExamples.isEmpty, lesson.id)
            XCTAssertFalse(lesson.aiVariationPrompts.isEmpty, lesson.id)
        }
    }

    func testEachEnglishUnitHasMultipleLessons() {
        let grouped = Dictionary(grouping: BeginnerContent.lessons(for: .english), by: \.unit)

        XCTAssertEqual(Set(grouped.keys), Set(1...6))
        for unit in 1...6 {
            XCTAssertGreaterThanOrEqual(grouped[unit, default: []].count, 6, "Unit \(unit)")
        }
    }

    func testLessonCompletionUnlocksNextLesson() {
        let suiteName = "ConverlaxContentTests-\(UUID().uuidString)"
        let suite = UserDefaults(suiteName: suiteName)!
        defer { suite.removePersistentDomain(forName: suiteName) }
        let state = LearningState(storage: suite, fileURL: nil)
        let first = BeginnerContent.lessons(for: .english)[0]
        let second = BeginnerContent.lessons(for: .english)[1]

        XCTAssertTrue(state.isUnlocked(first))
        XCTAssertFalse(state.isUnlocked(second))

        state.completeLesson(first, now: Date(timeIntervalSince1970: 1_700_000_000))

        XCTAssertEqual(state.currentLesson.id, second.id)
        XCTAssertTrue(state.isUnlocked(second))
        XCTAssertFalse(state.dueReviewItems.isEmpty)
    }

    func testEnglishLessonsUnlockInCourseOrderOnly() {
        let suiteName = "ConverlaxContentTests-\(UUID().uuidString)"
        let suite = UserDefaults(suiteName: suiteName)!
        defer { suite.removePersistentDomain(forName: suiteName) }
        let state = LearningState(storage: suite, fileURL: nil)
        let lessons = BeginnerContent.lessons(for: .english)

        XCTAssertTrue(state.isUnlocked(lessons[0]))
        XCTAssertFalse(state.isUnlocked(lessons[1]))
        XCTAssertFalse(state.isUnlocked(lessons[2]))

        state.completeLesson(lessons[0], now: Date(timeIntervalSince1970: 1_700_000_000))

        XCTAssertTrue(state.isUnlocked(lessons[1]))
        XCTAssertFalse(state.isUnlocked(lessons[2]))

        state.completeLesson(lessons[1], now: Date(timeIntervalSince1970: 1_700_086_400))

        XCTAssertTrue(state.isUnlocked(lessons[2]))
        XCTAssertFalse(state.isUnlocked(lessons[3]))
    }

    func testSavedProgressDropsInvalidAndSkippedEnglishLessonIDs() throws {
        let suiteName = "ConverlaxContentTests-\(UUID().uuidString)"
        let suite = UserDefaults(suiteName: suiteName)!
        defer { suite.removePersistentDomain(forName: suiteName) }
        let lessons = BeginnerContent.lessons(for: .english)
        var profile = LearningProfile()
        profile.targetLanguage = .english
        profile.completedLessonIDs = [lessons[0].id, lessons[2].id, "removed-lesson-id"]
        profile.currentLessonID = lessons[2].id
        profile.lessonResumeStepIndices = [
            lessons[1].id: 2,
            lessons[2].id: 3,
            "removed-lesson-id": 1
        ]
        suite.set(try JSONEncoder().encode(profile), forKey: storageKey)

        let state = LearningState(storage: suite, fileURL: nil)

        XCTAssertEqual(state.profile.completedLessonIDs, [lessons[0].id])
        XCTAssertEqual(state.currentLesson.id, lessons[1].id)
        XCTAssertTrue(state.isUnlocked(lessons[1]))
        XCTAssertFalse(state.isUnlocked(lessons[2]))
        XCTAssertEqual(state.profile.lessonResumeStepIndices[lessons[1].id], 2)
        XCTAssertNil(state.profile.lessonResumeStepIndices[lessons[2].id])
        XCTAssertNil(state.profile.lessonResumeStepIndices["removed-lesson-id"])
    }

    func testCurrentLessonIDRecoversToFirstIncompleteLesson() throws {
        let suiteName = "ConverlaxContentTests-\(UUID().uuidString)"
        let suite = UserDefaults(suiteName: suiteName)!
        defer { suite.removePersistentDomain(forName: suiteName) }
        let lessons = BeginnerContent.lessons(for: .english)
        var profile = LearningProfile()
        profile.targetLanguage = .english
        profile.completedLessonIDs = [lessons[0].id]
        profile.currentLessonID = "old-current-lesson-id"
        suite.set(try JSONEncoder().encode(profile), forKey: storageKey)

        let state = LearningState(storage: suite, fileURL: nil)

        XCTAssertEqual(state.currentLesson.id, lessons[1].id)
        XCTAssertEqual(state.profile.currentLessonID, lessons[1].id)
    }

    func testTutorMistakePatternRecordingCreatesMemoryAndReview() {
        let state = makeState()

        state.recordTutorCorrection(
            for: "I go to work yesterday and I tired",
            tutorResponse: sampleTutorResponse(),
            now: Date(timeIntervalSince1970: 1_700_000_000)
        )

        let pattern = state.profile.mistakePatterns.first
        XCTAssertEqual(pattern?.id, "past-tense")
        XCTAssertEqual(pattern?.count, 1)
        XCTAssertEqual(pattern?.correctedSentence, "I went to work yesterday, and I was tired.")
        XCTAssertTrue(state.profile.scheduledReviews.contains { $0.objectID == "mistake-past-tense" })
    }

    func testRepeatedMistakeUpdatesCountAndPriority() {
        let state = makeState()
        let firstDate = Date(timeIntervalSince1970: 1_700_000_000)
        let secondDate = Date(timeIntervalSince1970: 1_700_086_400)

        state.recordTutorCorrection(for: "I go to work yesterday", tutorResponse: sampleTutorResponse(), now: firstDate)
        let firstPriority = state.profile.mistakePatterns.first?.priorityScore ?? 0
        state.recordTutorCorrection(for: "I go to work yesterday", tutorResponse: sampleTutorResponse(), now: secondDate)

        let pattern = state.profile.mistakePatterns.first
        XCTAssertEqual(pattern?.count, 2)
        XCTAssertGreaterThan(pattern?.priorityScore ?? 0, firstPriority)
        XCTAssertGreaterThanOrEqual(state.profile.scheduledReviews.first { $0.objectID == "mistake-past-tense" }?.mistakeCount ?? 0, 2)
    }

    func testReviewPrioritizesRecentRepeatedTutorMistakes() {
        let state = makeState()
        state.saveLine(SavedLine(id: "safe-line", text: "Nice to meet you.", translation: "Greeting", source: "Saved", note: "Use when meeting someone."))
        state.recordTutorCorrection(for: "I go to work yesterday", tutorResponse: sampleTutorResponse(), now: Date(timeIntervalSince1970: 1_700_000_000))
        state.recordTutorCorrection(for: "I go to work yesterday", tutorResponse: sampleTutorResponse(), now: Date(timeIntervalSince1970: 1_700_086_400))

        XCTAssertEqual(state.dueReviewItems.first?.kind, .mistake)
        XCTAssertEqual(state.dueReviewItems.first?.source, "Tutor")
        XCTAssertEqual(state.dueReviewItems.first?.prompt, "I went to work yesterday, and I was tired.")
    }

    func testReviewGraduationLowersMistakePriority() throws {
        let state = makeState()
        state.recordTutorCorrection(for: "I go to work yesterday", tutorResponse: sampleTutorResponse(), now: Date(timeIntervalSince1970: 1_700_000_000))
        let item = try XCTUnwrap(state.dueReviewItems.first { $0.objectID == "mistake-past-tense" })
        let startingPriority = try XCTUnwrap(state.profile.mistakePatterns.first?.priorityScore)

        state.recordReview(item, remembered: true, now: Date(timeIntervalSince1970: 1_700_086_400))
        let afterFirst = try XCTUnwrap(state.profile.scheduledReviews.first { $0.id == item.id })
        state.recordReview(afterFirst, remembered: true, now: Date(timeIntervalSince1970: 1_700_172_800))
        let graduated = try XCTUnwrap(state.profile.scheduledReviews.first { $0.id == item.id })

        XCTAssertEqual(graduated.successCount, 2)
        XCTAssertGreaterThan(graduated.ease, item.ease)
        XCTAssertGreaterThan(graduated.nextDueDay, afterFirst.nextDueDay)
        XCTAssertLessThan(state.profile.mistakePatterns.first?.priorityScore ?? 1, startingPriority)
    }

    func testTutorFallbackIncludesReviewableLearningObject() {
        let response = TutorAIService.fallbackResponse(for: "I go to work yesterday and I tired")

        XCTAssertEqual(response.correction, "I went to work yesterday, and I was tired.")
        XCTAssertEqual(response.naturalAlternative, "I had a long day at work yesterday.")
        XCTAssertEqual(response.nextPrompt, "Say it one more time slowly.")
        XCTAssertFalse(response.nextPrompt.lowercased().contains(" then "))
        XCTAssertEqual(response.savedPhrase, "I went to work yesterday, and I was tired.")
        XCTAssertEqual(response.mistakePattern.id, "past-tense")
        XCTAssertEqual(response.reviewItem.answer, "I went to work yesterday, and I was tired.")
        XCTAssertFalse(response.sessionSummary.savedReviewItem.isEmpty)
    }

    func testTutorSavingUsesRequiredSavedPhraseForLearningObjectAndReview() throws {
        let state = makeState()
        let response = TutorAIResponse(
            tutorReply: "Good. Use past tense for yesterday.",
            correction: "I went to work yesterday.",
            naturalAlternative: "I went to work yesterday.",
            nextPrompt: "Tell me what you did after work.",
            savedPhrase: "I went to work yesterday.",
            reviewItem: TutorAIReviewItem(
                prompt: "Say this in the past: I go to work yesterday.",
                answer: "I went to work yesterday."
            ),
            mistakePattern: TutorAIMistakePattern(
                id: "past-tense",
                title: "Past tense",
                explanation: "Use a past verb when you talk about yesterday.",
                exampleLearnerSentence: "I go to work yesterday.",
                correctedSentence: "I went to work yesterday.",
                confidence: 0.86
            ),
            sessionSummary: TutorAISessionSummary(
                improvedPhrase: "I went to work yesterday.",
                mistakePattern: "Past tense",
                savedReviewItem: "I went to work yesterday.",
                nextPrompt: "Tell me what you did after work."
            )
        )

        state.recordTutorCorrection(
            for: "I go to work yesterday",
            tutorResponse: response,
            now: Date(timeIntervalSince1970: 1_700_000_000)
        )

        let object = try XCTUnwrap(state.profile.savedLearningObjects.first {
            $0.id == "tutor-message-i-went-to-work-yesterday" && $0.text == "I went to work yesterday."
        })
        XCTAssertEqual(object.text, "I went to work yesterday.")
        XCTAssertNotEqual(object.text, response.tutorReply)

        let review = try XCTUnwrap(state.profile.scheduledReviews.first { $0.objectID == object.id })
        XCTAssertEqual(review.prompt, "I went to work yesterday.")
        XCTAssertEqual(review.answer, "Corrected from: I go to work yesterday")
    }

    func testTutorAIResponseParsesNaturalAlternativeAndMistakePattern() throws {
        let json = """
        {
          "tutorReply": "Good. Use past tense for yesterday.",
          "correction": "I went to work yesterday, and I was tired.",
          "naturalAlternative": "I had a long day at work yesterday.",
          "nextPrompt": "Tell me why you were tired.",
          "savedPhrase": "I went to work yesterday.",
          "reviewItem": {
            "prompt": "Say this in the past: I go to work yesterday.",
            "answer": "I went to work yesterday."
          },
          "mistakePattern": {
            "id": "past-tense",
            "title": "Past tense",
            "explanation": "Use a past verb for yesterday.",
            "exampleLearnerSentence": "I go to work yesterday.",
            "correctedSentence": "I went to work yesterday.",
            "confidence": 0.86
          },
          "sessionSummary": {
            "improvedPhrase": "I had a long day at work yesterday.",
            "mistakePattern": "Past tense",
            "savedReviewItem": "I went to work yesterday.",
            "nextPrompt": "Tell me why you were tired."
          }
        }
        """.data(using: .utf8)!

        let response = try JSONDecoder().decode(TutorAIResponse.self, from: json)

        XCTAssertEqual(response.naturalAlternative, "I had a long day at work yesterday.")
        XCTAssertEqual(response.savedPhrase, "I went to work yesterday.")
        XCTAssertEqual(response.reviewItem.prompt, "Say this in the past: I go to work yesterday.")
        XCTAssertEqual(response.mistakePattern.title, "Past tense")
        XCTAssertEqual(response.sessionSummary.mistakePattern, "Past tense")
    }

    func testTutorAIResponseRequiresSavedPhraseAndReviewItem() throws {
        let missingSavedPhrase = """
        {
          "tutorReply": "Good. Use past tense for yesterday.",
          "correction": "I went to work yesterday.",
          "naturalAlternative": "I went to work yesterday.",
          "nextPrompt": "Say it again in past tense.",
          "reviewItem": {
            "prompt": "Say this in the past: I go to work yesterday.",
            "answer": "I went to work yesterday."
          },
          "mistakePattern": {
            "id": "past-tense",
            "title": "Past tense",
            "explanation": "Use a past verb for yesterday.",
            "exampleLearnerSentence": "I go to work yesterday.",
            "correctedSentence": "I went to work yesterday.",
            "confidence": 0.86
          },
          "sessionSummary": {
            "improvedPhrase": "I went to work yesterday.",
            "mistakePattern": "Past tense",
            "savedReviewItem": "I went to work yesterday.",
            "nextPrompt": "Say it again in past tense."
          }
        }
        """.data(using: .utf8)!

        let missingReviewItem = """
        {
          "tutorReply": "Good. Use past tense for yesterday.",
          "correction": "I went to work yesterday.",
          "naturalAlternative": "I went to work yesterday.",
          "nextPrompt": "Say it again in past tense.",
          "savedPhrase": "I went to work yesterday.",
          "mistakePattern": {
            "id": "past-tense",
            "title": "Past tense",
            "explanation": "Use a past verb for yesterday.",
            "exampleLearnerSentence": "I go to work yesterday.",
            "correctedSentence": "I went to work yesterday.",
            "confidence": 0.86
          },
          "sessionSummary": {
            "improvedPhrase": "I went to work yesterday.",
            "mistakePattern": "Past tense",
            "savedReviewItem": "I went to work yesterday.",
            "nextPrompt": "Say it again in past tense."
          }
        }
        """.data(using: .utf8)!

        XCTAssertThrowsError(try JSONDecoder().decode(TutorAIResponse.self, from: missingSavedPhrase))
        XCTAssertThrowsError(try JSONDecoder().decode(TutorAIResponse.self, from: missingReviewItem))
    }

    func testOldProfileDataMigratesMissingLearningSystemFields() throws {
        let suiteName = "ConverlaxContentTests-\(UUID().uuidString)"
        let suite = UserDefaults(suiteName: suiteName)!
        defer { suite.removePersistentDomain(forName: suiteName) }
        let firstLessonID = BeginnerContent.firstLessonID(for: .english)
        let oldJSON = """
        {
          "schemaVersion": 3,
          "targetLanguage": "English",
          "currentLevel": "Beginner",
          "completedLessonIDs": [],
          "currentLessonID": "\(firstLessonID)",
          "scheduledReviews": [
            {
              "id": "review-old",
              "objectID": "old-object",
              "kind": "Mistake",
              "prompt": "I went yesterday.",
              "answer": "Use went for yesterday.",
              "source": "Tutor",
              "nextDueDay": "2026-05-18",
              "ease": 0.4,
              "mistakeCount": 1,
              "listeningFirst": true,
              "speakingRetry": true
            }
          ]
        }
        """.data(using: .utf8)!
        suite.set(oldJSON, forKey: storageKey)

        let state = LearningState(storage: suite, fileURL: nil)

        XCTAssertEqual(state.profile.schemaVersion, LearningProfile.currentSchemaVersion)
        XCTAssertTrue(state.profile.mistakePatterns.isEmpty)
        XCTAssertEqual(state.profile.scheduledReviews.first?.successCount, 0)
    }

    private func makeState() -> LearningState {
        let suiteName = "ConverlaxContentTests-\(UUID().uuidString)"
        let suite = UserDefaults(suiteName: suiteName)!
        addTeardownBlock {
            suite.removePersistentDomain(forName: suiteName)
        }
        var profile = LearningProfile()
        profile.targetLanguage = .english
        profile.hasCompletedOnboarding = true
        suite.set(try! JSONEncoder().encode(profile), forKey: storageKey)
        return LearningState(storage: suite, fileURL: nil)
    }

    private func sampleTutorResponse() -> TutorAIResponse {
        TutorAIResponse(
            tutorReply: "Good. You're talking about yesterday, so use past tense.",
            correction: "I went to work yesterday, and I was tired.",
            naturalAlternative: "I had a long day at work yesterday.",
            nextPrompt: "Tell me why you were tired.",
            savedPhrase: "I went to work yesterday.",
            reviewItem: TutorAIReviewItem(
                prompt: "Say this in the past: I go to work yesterday.",
                answer: "I went to work yesterday."
            ),
            mistakePattern: TutorAIMistakePattern(
                id: "past-tense",
                title: "Past tense",
                explanation: "Use a past verb when you talk about yesterday.",
                exampleLearnerSentence: "I go to work yesterday.",
                correctedSentence: "I went to work yesterday, and I was tired.",
                confidence: 0.86
            ),
            sessionSummary: TutorAISessionSummary(
                improvedPhrase: "I had a long day at work yesterday.",
                mistakePattern: "Past tense",
                savedReviewItem: "I went to work yesterday.",
                nextPrompt: "Tell me why you were tired."
            )
        )
    }
}

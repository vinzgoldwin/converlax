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

    func testLessonTurnIntentsMatchTitlesAndPlaybackRules() {
        let lessons = BeginnerContent.lessons(for: .english) + BeginnerContent.lessons(for: .french)

        for lesson in lessons {
            for step in lesson.steps {
                XCTAssertEqual(step.title, step.turnIntent.rawValue, "\(lesson.id) \(step.id)")
                XCTAssertEqual(step.showsPreSpeechPlayback, step.turnIntent == .listenAndRepeat, "\(lesson.id) \(step.id)")

                switch step.turnIntent {
                case .listenAndRepeat:
                    XCTAssertTrue(step.id.hasSuffix("-model"), "\(lesson.id) \(step.id)")
                    XCTAssertEqual(step.visiblePromptText, step.expectedSpeechText, "\(lesson.id) \(step.id)")
                case .sayThisSentence:
                    XCTAssertFalse(step.id.hasSuffix("-model"), "\(lesson.id) \(step.id)")
                    XCTAssertEqual(step.visiblePromptText, step.expectedSpeechText, "\(lesson.id) \(step.id)")
                    XCTAssertNil(step.correctAnswer, "\(lesson.id) \(step.id)")
                case .answerOutLoud:
                    XCTAssertFalse(step.id.hasSuffix("-model"), "\(lesson.id) \(step.id)")
                    if let correctAnswer = step.correctAnswer {
                        XCTAssertNotEqual(step.visiblePromptText, step.expectedSpeechText, "\(lesson.id) \(step.id)")
                        XCTAssertFalse(
                            step.visiblePromptText.localizedCaseInsensitiveContains(correctAnswer),
                            "\(lesson.id) \(step.id) reveals its answer before speech"
                        )
                    }
                case .chooseAndSay:
                    XCTAssertFalse(step.choices.isEmpty, "\(lesson.id) \(step.id)")
                }
            }
        }
    }

    func testLessonCopyAvoidsMismatchedPrimaryTurnLabels() {
        let lessons = BeginnerContent.lessons(for: .english) + BeginnerContent.lessons(for: .french)
        let bannedPrimaryCopy = [
            "Clear answer",
            "Natural alternative",
            "Natural next line",
            "Say it your way",
            "Speaking goal",
            "Say the clear",
            "clear line",
            "natural French line"
        ]

        for lesson in lessons {
            for step in lesson.steps {
                let primaryCopy = "\(step.title) \(step.helper)"
                for bannedCopy in bannedPrimaryCopy {
                    XCTAssertFalse(
                        primaryCopy.localizedCaseInsensitiveContains(bannedCopy),
                        "\(lesson.id) \(step.id) contains mismatched copy: \(bannedCopy)"
                    )
                }
            }
        }
    }

    func testMascotVoiceMomentRequiresStrongLessonAttempt() {
        var policy = MascotVoiceCelebrationPolicy(minimumInterval: 60)
        let now = Date(timeIntervalSince1970: 1_700_000_000)

        XCTAssertNil(policy.moment(
            for: .lessonStrongAttempt(lessonID: "english-introduce-yourself", confidence: 87),
            isRecording: false,
            now: now
        ))

        let moment = policy.moment(
            for: .lessonStrongAttempt(lessonID: "english-introduce-yourself", confidence: 88),
            isRecording: false,
            now: now
        )

        XCTAssertTrue(["Nice work.", "Good rhythm.", "That sounded clear."].contains(moment?.text ?? ""))
    }

    func testMascotVoiceMomentDoesNotPlayWhileRecordingOrConsumeEvent() {
        var policy = MascotVoiceCelebrationPolicy(minimumInterval: 60)
        let now = Date(timeIntervalSince1970: 1_700_000_000)

        XCTAssertNil(policy.moment(
            for: .lessonCompletion(lessonID: "english-introduce-yourself"),
            isRecording: true,
            now: now
        ))

        XCTAssertEqual(
            policy.moment(
                for: .lessonCompletion(lessonID: "english-introduce-yourself"),
                isRecording: false,
                now: now
            )?.text,
            "Lesson complete."
        )
    }

    func testMascotVoiceMomentThrottlesDifferentEvents() {
        var policy = MascotVoiceCelebrationPolicy(minimumInterval: 60)
        let now = Date(timeIntervalSince1970: 1_700_000_000)

        XCTAssertNotNil(policy.moment(
            for: .lessonStrongAttempt(lessonID: "english-introduce-yourself", confidence: 95),
            isRecording: false,
            now: now
        ))
        XCTAssertNil(policy.moment(
            for: .lessonCompletion(lessonID: "english-introduce-yourself"),
            isRecording: false,
            now: now.addingTimeInterval(30)
        ))
        XCTAssertEqual(
            policy.moment(
                for: .lessonCompletion(lessonID: "english-introduce-yourself"),
                isRecording: false,
                now: now.addingTimeInterval(61)
            )?.text,
            "Lesson complete."
        )
    }

    func testMascotVoiceReviewCompletionOnlySpeaksOnce() {
        var policy = MascotVoiceCelebrationPolicy(minimumInterval: 0)
        let now = Date(timeIntervalSince1970: 1_700_000_000)

        XCTAssertEqual(
            policy.moment(for: .reviewCompletion, isRecording: false, now: now)?.text,
            "Review complete."
        )
        XCTAssertNil(policy.moment(
            for: .reviewCompletion,
            isRecording: false,
            now: now.addingTimeInterval(600)
        ))
    }

    func testHobbyDetailsLessonDoesNotRepeatTurnFourPromptOnTurnSeven() throws {
        let lesson = try XCTUnwrap(BeginnerContent.lesson(id: "english-hobbies-detail"))
        let turnFour = try XCTUnwrap(lesson.steps.first { $0.id == "english-hobbies-detail-alternative" })
        let turnSeven = try XCTUnwrap(lesson.steps.first { $0.id == "english-hobbies-detail-follow-up" })

        XCTAssertEqual(turnFour.prompt, "It helps me relax after work.")
        XCTAssertEqual(turnSeven.prompt, "How did you get into it?")
        XCTAssertNotEqual(turnFour.prompt, turnSeven.prompt)
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

    func testEnglishLevelSelectionStartsDistinctCourseRanges() {
        XCTAssertEqual(BeginnerContent.lessons(for: .english, level: .beginner).first?.unit, 1)
        XCTAssertEqual(BeginnerContent.lessons(for: .english, level: .elementary).first?.unit, 2)
        XCTAssertEqual(BeginnerContent.lessons(for: .english, level: .upperElementary).first?.unit, 3)
        XCTAssertEqual(BeginnerContent.lessons(for: .english, level: .intermediate).first?.unit, 4)
    }

    func testSelectingIntermediateMovesCurrentLessonToIntermediateRange() {
        let state = makeState()

        state.selectLevel(.intermediate)

        XCTAssertEqual(state.profile.currentLevel, .intermediate)
        XCTAssertEqual(state.currentLesson.unit, 4)
        XCTAssertTrue(state.isUnlocked(state.currentLesson))
        XCTAssertFalse(state.courseLessons.contains { $0.unit == 1 })
    }

    func testIntermediateProgressSurvivesProfileRestore() throws {
        let suiteName = "ConverlaxContentTests-\(UUID().uuidString)"
        let suite = UserDefaults(suiteName: suiteName)!
        defer { suite.removePersistentDomain(forName: suiteName) }
        let lessons = BeginnerContent.lessons(for: .english, level: .intermediate)
        let first = try XCTUnwrap(lessons.first)
        let second = try XCTUnwrap(lessons.dropFirst().first)
        var profile = LearningProfile()
        profile.targetLanguage = .english
        profile.currentLevel = .intermediate
        profile.completedLessonIDs = [first.id]
        profile.currentLessonID = first.id
        suite.set(try JSONEncoder().encode(profile), forKey: storageKey)

        let state = LearningState(storage: suite, fileURL: nil)

        XCTAssertTrue(state.profile.completedLessonIDs.contains(first.id))
        XCTAssertEqual(state.currentLesson.id, second.id)
        XCTAssertTrue(state.isUnlocked(second))
    }

    func testProfileDecodeDefaultsCurrentLessonToDecodedLevel() throws {
        let firstIntermediateID = try XCTUnwrap(BeginnerContent.lessons(for: .english, level: .intermediate).first?.id)
        let data = """
        {
          "schemaVersion": 4,
          "targetLanguage": "English",
          "currentLevel": "Intermediate",
          "completedLessonIDs": [],
          "hasCompletedOnboarding": true
        }
        """.data(using: .utf8)!

        let profile = try JSONDecoder().decode(LearningProfile.self, from: data)

        XCTAssertEqual(profile.currentLevel, .intermediate)
        XCTAssertEqual(profile.currentLessonID, firstIntermediateID)
    }

    func testRestoredIntermediateProfileWithoutCurrentLessonOpensFirstUnfinishedLevelLesson() throws {
        let suiteName = "ConverlaxContentTests-\(UUID().uuidString)"
        let suite = UserDefaults(suiteName: suiteName)!
        defer { suite.removePersistentDomain(forName: suiteName) }
        let lessons = BeginnerContent.lessons(for: .english, level: .intermediate)
        let first = try XCTUnwrap(lessons.first)
        let second = try XCTUnwrap(lessons.dropFirst().first)
        let data = """
        {
          "schemaVersion": 4,
          "targetLanguage": "English",
          "currentLevel": "Intermediate",
          "completedLessonIDs": ["\(first.id)"],
          "hasCompletedOnboarding": true
        }
        """.data(using: .utf8)!
        suite.set(data, forKey: storageKey)

        let state = LearningState(storage: suite, fileURL: nil)

        XCTAssertEqual(state.profile.currentLevel, .intermediate)
        XCTAssertEqual(state.currentLesson.id, second.id)
        XCTAssertEqual(state.profile.currentLessonID, second.id)
    }

    func testEnglishLaunchPreservesRestoredIntermediateFirstUnfinishedLesson() throws {
        let lessons = BeginnerContent.lessons(for: .english, level: .intermediate)
        let first = try XCTUnwrap(lessons.first)
        let second = try XCTUnwrap(lessons.dropFirst().first)
        var profile = LearningProfile()
        profile.targetLanguage = .english
        profile.currentLevel = .intermediate
        profile.completedLessonIDs = [first.id]
        profile.currentLessonID = second.id

        let adjusted = LearningState.launchAdjusted(profile, arguments: ["app", "-ConverlaxUseEnglishContent"])

        XCTAssertEqual(adjusted.currentLevel, .intermediate)
        XCTAssertEqual(adjusted.currentLessonID, second.id)
    }

    func testEnglishLaunchInitialLevelStartsThatLevelPath() throws {
        let firstIntermediateID = try XCTUnwrap(BeginnerContent.lessons(for: .english, level: .intermediate).first?.id)
        let adjusted = LearningState.launchAdjusted(LearningProfile(), arguments: [
            "app",
            "-ConverlaxUseEnglishContent",
            "-ConverlaxInitialLevel",
            "Intermediate"
        ])

        XCTAssertEqual(adjusted.currentLevel, .intermediate)
        XCTAssertEqual(adjusted.currentLessonID, firstIntermediateID)
    }

    func testHomeLessonLaunchRouteDefaultsToInitialLevelPath() throws {
        let path = HomeRoute.launchDefaultPath(arguments: [
            "app",
            "-ConverlaxUseEnglishContent",
            "-ConverlaxInitialLevel",
            "Intermediate",
            "-ConverlaxInitialHomeRoute",
            "lesson"
        ])

        guard case .lesson(let lesson) = try XCTUnwrap(path.first) else {
            return XCTFail("Expected lesson launch route.")
        }
        XCTAssertEqual(lesson.id, BeginnerContent.firstLessonID(for: .english, level: .intermediate))
        XCTAssertEqual(lesson.unit, 4)
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

    func testLessonSpeakingTurnCreatesReviewItemAndReviewCompletionClearsDueItem() throws {
        let state = makeState()
        let lesson = try XCTUnwrap(BeginnerContent.lessons(for: .english).first)
        let step = try XCTUnwrap(lesson.steps.first { $0.kind == .speak })
        let transcript = try XCTUnwrap(step.correctAnswer ?? step.prompt.components(separatedBy: ".").first)
        let now = Date()

        let feedback = state.acceptSpeechPractice(
            lesson: lesson,
            step: step,
            transcript: transcript,
            mode: "Speaking practice",
            now: now
        )

        XCTAssertEqual(feedback.attemptedText, transcript)
        XCTAssertFalse(feedback.savedTakeaway.isEmpty)

        let reviewItem = try XCTUnwrap(state.dueReviewItems.first {
            $0.source == "Speaking practice" && $0.prompt == feedback.savedTakeaway
        })
        XCTAssertEqual(reviewItem.kind, .phrase)
        XCTAssertNil(reviewItem.lastReviewedDay)

        state.recordReview(reviewItem, remembered: true, now: now)

        let storedReview = try XCTUnwrap(state.profile.scheduledReviews.first { $0.id == reviewItem.id })
        XCTAssertEqual(storedReview.successCount, 1)
        XCTAssertEqual(storedReview.mistakeCount, 0)
        XCTAssertNotEqual(storedReview.nextDueDay, reviewItem.nextDueDay)
        XCTAssertFalse(state.dueReviewItems.contains { $0.id == reviewItem.id })

        XCTAssertTrue(state.nextRecommendation.title.localizedCaseInsensitiveContains("continue"))
    }

    func testCompletedLessonTurnFeedbackStaysAvailable() throws {
        let state = makeState()
        let lesson = try XCTUnwrap(BeginnerContent.lessons(for: .english).first)
        let step = try XCTUnwrap(lesson.steps.first { $0.kind == .speak })
        let transcript = try XCTUnwrap(step.correctAnswer ?? step.prompt.components(separatedBy: ".").first)

        let feedback = state.acceptSpeechPractice(
            lesson: lesson,
            step: step,
            transcript: transcript,
            mode: "Speaking practice"
        )
        state.completeLesson(lesson)

        XCTAssertEqual(state.feedbackEvents(for: lesson).first?.id, feedback.id)
        XCTAssertEqual(state.latestFeedback(for: step, in: lesson)?.id, feedback.id)
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

    func testLegacyProfileWithoutLanguageRecoversToEnglishCourse() throws {
        let suiteName = "ConverlaxContentTests-\(UUID().uuidString)"
        let suite = UserDefaults(suiteName: suiteName)!
        defer { suite.removePersistentDomain(forName: suiteName) }
        let legacyProfile = """
        {
          "schemaVersion": 1,
          "currentLevel": "Beginner",
          "completedLessonIDs": [],
          "currentLessonID": "removed-lesson-id",
          "hasCompletedOnboarding": true
        }
        """.data(using: .utf8)!
        suite.set(legacyProfile, forKey: storageKey)

        let state = LearningState(storage: suite, fileURL: nil)

        XCTAssertEqual(state.profile.targetLanguage, .english)
        XCTAssertEqual(state.currentLesson.id, BeginnerContent.firstLessonID(for: .english))
    }

    func testTutorMistakePatternRecordingCreatesMemoryAndReview() {
        let state = makeState()

        state.recordTutorCorrection(
            for: "I go to work yesterday",
            tutorResponse: sampleTutorResponse(),
            now: Date(timeIntervalSince1970: 1_700_000_000)
        )

        let pattern = state.profile.mistakePatterns.first
        XCTAssertEqual(pattern?.id, "past-tense")
        XCTAssertEqual(pattern?.count, 1)
        XCTAssertEqual(pattern?.correctedSentence, "I went to work yesterday.")
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
        XCTAssertEqual(state.dueReviewItems.first?.prompt, "I went to work yesterday.")
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

        XCTAssertEqual(response.correction, "I went to work yesterday.")
        XCTAssertEqual(response.naturalAlternative, "Yesterday, I went to work.")
        XCTAssertEqual(response.nextPrompt, "Say it one more time slowly.")
        XCTAssertFalse(response.nextPrompt.lowercased().contains(" then "))
        XCTAssertEqual(response.savedPhrase, "I went to work yesterday.")
        XCTAssertEqual(response.mistakePattern.id, "past-tense")
        XCTAssertEqual(response.mistakePattern.exampleLearnerSentence, "I go to work yesterday.")
        XCTAssertEqual(response.reviewItem.prompt, "Say this in the past: I go to work yesterday.")
        XCTAssertEqual(response.reviewItem.answer, "I went to work yesterday.")
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
          "correction": "I went to work yesterday.",
          "naturalAlternative": "Yesterday, I went to work.",
          "nextPrompt": "Say it again in past tense.",
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
            "improvedPhrase": "Yesterday, I went to work.",
            "mistakePattern": "Past tense",
            "savedReviewItem": "I went to work yesterday.",
            "nextPrompt": "Say it again in past tense."
          }
        }
        """.data(using: .utf8)!

        let response = try JSONDecoder().decode(TutorAIResponse.self, from: json)

        XCTAssertEqual(response.naturalAlternative, "Yesterday, I went to work.")
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
            correction: "I went to work yesterday.",
            naturalAlternative: "Yesterday, I went to work.",
            nextPrompt: "Say it again in past tense.",
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
                improvedPhrase: "Yesterday, I went to work.",
                mistakePattern: "Past tense",
                savedReviewItem: "I went to work yesterday.",
                nextPrompt: "Say it again in past tense."
            )
        )
    }
}

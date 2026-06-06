import XCTest

final class ConverlaxRootTabsUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testHomeRootStartsAtPrimaryLesson() throws {
        let app = launchApp(initialTab: "home")

        XCTAssertTrue(element("screen-home", in: app).waitForExistence(timeout: 5))
        XCTAssertTrue(element("home-primary-lesson-action", in: app).exists)
        XCTAssertTrue(element("home-course-path-action", in: app).exists)
    }

    func testHomeLaunchCanStartIntermediatePath() throws {
        let app = launchApp(initialTab: "home", extraArguments: [
            "-ConverlaxInitialLevel",
            "Intermediate"
        ])

        XCTAssertTrue(element("screen-home", in: app).waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Intermediate English"].exists)
    }

    func testPracticeRootKeepsSpeakingPrimary() throws {
        let app = launchApp(initialTab: "practice")

        XCTAssertTrue(element("screen-practice", in: app).waitForExistence(timeout: 5))
        XCTAssertTrue(element("practice-start-speaking", in: app).exists)
        XCTAssertTrue(element("practice-choose-situation", in: app).exists)

        element("practice-choose-situation", in: app).tap()
        XCTAssertTrue(element("situation-browser", in: app).waitForExistence(timeout: 5))
        XCTAssertTrue(element("situation-row-first-meeting", in: app).exists)
        XCTAssertFalse(element("situation-filter", in: app).exists)
    }

    func testReviewRootShowsCurrentReviewAction() throws {
        let app = launchApp(initialTab: "review")

        XCTAssertTrue(element("screen-review", in: app).waitForExistence(timeout: 5))
        XCTAssertTrue(element("review-primary-action", in: app).exists)
        XCTAssertEqual(app.buttons.matching(identifier: "review-primary-action").count, 1)
    }

    func testProfileRootShowsJourney() throws {
        let app = launchApp(initialTab: "profile")

        XCTAssertTrue(element("screen-profile", in: app).waitForExistence(timeout: 5))
        XCTAssertTrue(element("profile-journey-dashboard", in: app).exists)
    }

    func testSettingsCourseLevelNavigationWorks() throws {
        let app = launchApp(initialTab: "profile")

        XCTAssertTrue(element("screen-profile", in: app).waitForExistence(timeout: 5))
        let settingsRow = button(containing: "Settings", in: app)
        if !settingsRow.waitForExistence(timeout: 2) {
            app.swipeUp()
        }
        XCTAssertTrue(settingsRow.waitForExistence(timeout: 5))
        settingsRow.tap()

        let courseLevelRow = button(containing: "Change course or level", in: app)
        XCTAssertTrue(courseLevelRow.waitForExistence(timeout: 5))
        courseLevelRow.tap()

        XCTAssertTrue(app.navigationBars["Course and level"].waitForExistence(timeout: 5))
    }

    func testSettingsIntermediateLevelUpdatesHomeAndCoursePath() throws {
        let app = launchApp(initialTab: "profile")

        openCourseLevelSettings(in: app)

        button(containing: "Intermediate", in: app).tap()
        XCTAssertTrue(app.buttons["Switch to Intermediate"].waitForExistence(timeout: 5))
        app.buttons["Switch to Intermediate"].tap()

        let homeTab = app.buttons.matching(identifier: "tab-home").firstMatch
        XCTAssertTrue(homeTab.waitForExistence(timeout: 5))
        homeTab.tap()

        XCTAssertTrue(element("screen-home", in: app).waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Intermediate English"].waitForExistence(timeout: 5))
        XCTAssertTrue(anyElement(containing: "Start a work chat", in: app).exists)
        XCTAssertFalse(app.staticTexts["Say how you feel"].exists)

        element("home-course-path-action", in: app).tap()

        XCTAssertTrue(app.navigationBars["Course"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Intermediate English path"].exists)
        XCTAssertTrue(app.staticTexts["Work English"].exists)
        XCTAssertTrue(app.staticTexts["Unit 4"].exists)
        XCTAssertTrue(anyElement(containing: "Start a work chat", in: app).exists)
        XCTAssertFalse(app.staticTexts["Starter English"].exists)
    }

    func testTutorIsVoiceOnly() throws {
        let app = launchTutorApp(extraArguments: [])

        XCTAssertTrue(element("speech-practice-panel", in: app).waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Say one English sentence."].exists)
        XCTAssertTrue(app.staticTexts["Answer the Tutor prompt out loud."].exists)
        XCTAssertTrue(app.buttons["Start speaking"].exists)
        XCTAssertFalse(app.textFields["tutor-text-input"].exists)
        XCTAssertFalse(app.buttons["tutor-send-button"].exists)
    }

    func testLessonVoiceTurnShowsConcreteSpeakingTask() throws {
        let app = launchApp(initialTab: "home", extraArguments: [
            "-ConverlaxInitialHomeRoute",
            "lesson"
        ])

        XCTAssertTrue(element("speech-practice-panel", in: app).waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Say this goal out loud."].exists)
        XCTAssertFalse(app.staticTexts["Record one clear answer."].exists)
    }

    func testLessonModelTurnHasAudioPlaybackControl() throws {
        let app = launchApp(initialTab: "home", extraArguments: [
            "-ConverlaxInitialHomeRoute",
            "lesson",
            "-ConverlaxInitialLessonStepIndex",
            "1"
        ])

        XCTAssertTrue(element("speech-practice-panel", in: app).waitForExistence(timeout: 5))

        XCTAssertTrue(app.staticTexts["Listen and repeat"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.buttons["Play sentence audio"].exists)
        XCTAssertTrue(app.staticTexts["Play the sentence, then say it out loud."].exists)
    }

    func testVoiceTutorUsesAIReplyNotCannedLessonText() throws {
        let app = launchTutorApp(extraArguments: [
            "-ConverlaxUseMockTutorAI",
            "-ConverlaxTutorVoiceState",
            "transcript"
        ])

        XCTAssertTrue(app.buttons["Send to Tutor"].waitForExistence(timeout: 5))
        app.buttons["Send to Tutor"].tap()

        XCTAssertTrue(app.staticTexts["Good. You're talking about yesterday, so use past tense."].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Better"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["I went to work yesterday."].exists)
        XCTAssertFalse(app.staticTexts["Saved phrase"].exists)
        XCTAssertFalse(app.staticTexts["latest project notes"].exists)
        XCTAssertTrue(app.staticTexts["You said"].exists)
        XCTAssertTrue(app.staticTexts["Fix"].exists)
        XCTAssertFalse(app.staticTexts["Try next"].exists)
        XCTAssertTrue(app.staticTexts["Yesterday, I went to work."].exists)
        XCTAssertTrue(app.staticTexts["Say it again in past tense."].waitForExistence(timeout: 3))
        XCTAssertFalse(anyElement(containing: "then", in: app).exists)
        XCTAssertTrue(app.buttons["Answer prompt"].waitForExistence(timeout: 3))
        XCTAssertFalse(app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", "Your next lesson is")).element.exists)
    }

    func testTutorFollowUpTurnUsesVoiceTranscriptAndSameAIPath() throws {
        let app = launchTutorApp(extraArguments: [
            "-ConverlaxUseMockTutorAI",
            "-ConverlaxTutorVoiceState",
            "transcript",
            "-ConverlaxUseUITestVoiceTranscript",
            "-ConverlaxUITestVoiceTranscript",
            "I went to work yesterday"
        ])

        XCTAssertTrue(app.buttons["Send to Tutor"].waitForExistence(timeout: 5))
        app.buttons["Send to Tutor"].tap()

        XCTAssertTrue(app.buttons["Answer prompt"].waitForExistence(timeout: 5))
        app.buttons["Answer prompt"].tap()
        XCTAssertTrue(app.staticTexts["I went to work yesterday"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.buttons["Send to Tutor"].waitForExistence(timeout: 3))
        app.buttons["Send to Tutor"].tap()

        XCTAssertGreaterThanOrEqual(app.staticTexts.matching(identifier: "tutor-reply-message").count, 2)
        XCTAssertFalse(app.textFields["tutor-text-input"].exists)
        XCTAssertFalse(app.buttons["tutor-send-button"].exists)
    }

    func testTutorCompletesAfterMaxTurns() throws {
        let app = launchTutorApp(extraArguments: [
            "-ConverlaxUseMockTutorAI",
            "-ConverlaxTutorVoiceState",
            "finalTranscript"
        ])

        XCTAssertTrue(app.buttons["Send to Tutor"].waitForExistence(timeout: 5))
        app.buttons["Send to Tutor"].tap()

        XCTAssertTrue(element("tutor-session-summary", in: app).waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Practice complete"].exists)
        XCTAssertTrue(app.staticTexts["Pattern noticed"].exists)
        XCTAssertTrue(app.buttons["Finish practice"].exists)
    }

    func testTutorBackendFailureShowsLocalFallback() throws {
        let app = launchTutorApp(extraArguments: [
            "-ConverlaxTutorAIBaseURL",
            "http://127.0.0.1:1",
            "-ConverlaxTutorVoiceState",
            "transcript"
        ])

        XCTAssertTrue(app.buttons["Send to Tutor"].waitForExistence(timeout: 5))
        app.buttons["Send to Tutor"].tap()

        XCTAssertTrue(app.staticTexts["Good idea. Use past tense for yesterday."].waitForExistence(timeout: 8))
        XCTAssertTrue(anyElement(containing: "Showing local guidance", in: app).waitForExistence(timeout: 3))
    }

    func testTutorAIResponseCreatesReviewableLearningObjects() throws {
        let app = launchTutorApp(extraArguments: [
            "-ConverlaxUseMockTutorAI",
            "-ConverlaxTutorVoiceState",
            "transcript",
            "-ConverlaxStartFeedbackExpanded"
        ])

        XCTAssertTrue(app.buttons["Send to Tutor"].waitForExistence(timeout: 5))
        app.buttons["Send to Tutor"].tap()

        XCTAssertTrue(anyElement(containing: "Better", in: app).waitForExistence(timeout: 5))
        XCTAssertTrue(anyElement(containing: "You said", in: app).waitForExistence(timeout: 3))
        XCTAssertFalse(anyElement(containing: "Review later", in: app).exists)
        XCTAssertFalse(app.buttons["More detail"].exists)
        XCTAssertTrue(anyElement(containing: "I went to work yesterday.", in: app).exists)
    }

    func testReviewCanPresentRecentTutorCorrection() throws {
        let app = launchApp(initialTab: "review", extraArguments: ["-ConverlaxSeedTutorReview"])

        XCTAssertTrue(element("review-primary-action", in: app).waitForExistence(timeout: 5))
        element("review-primary-action", in: app).tap()

        XCTAssertTrue(anyElement(containing: "I went to work yesterday.", in: app).waitForExistence(timeout: 5))
    }

    private func launchApp(initialTab: String, extraArguments: [String] = []) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = [
            "-ConverlaxUseEnglishContent",
            "-ConverlaxResetStoredProfile",
            "-ConverlaxInitialTab",
            initialTab
        ] + extraArguments
        app.launch()
        return app
    }

    private func launchTutorApp(extraArguments: [String]) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = [
            "-ConverlaxUseEnglishContent",
            "-ConverlaxResetStoredProfile",
            "-ConverlaxInitialTab",
            "home",
            "-ConverlaxInitialHomeRoute",
            "tutor"
        ] + extraArguments
        app.launch()
        return app
    }

    private func element(_ identifier: String, in app: XCUIApplication) -> XCUIElement {
        app.descendants(matching: .any)[identifier]
    }

    private func openCourseLevelSettings(in app: XCUIApplication) {
        XCTAssertTrue(element("screen-profile", in: app).waitForExistence(timeout: 5))
        let settingsRow = button(containing: "Settings", in: app)
        if !settingsRow.waitForExistence(timeout: 2) {
            app.swipeUp()
        }
        XCTAssertTrue(settingsRow.waitForExistence(timeout: 5))
        settingsRow.tap()

        let courseLevelRow = button(containing: "Change course or level", in: app)
        XCTAssertTrue(courseLevelRow.waitForExistence(timeout: 5))
        courseLevelRow.tap()

        XCTAssertTrue(app.navigationBars["Course and level"].waitForExistence(timeout: 5))
    }

    private func anyElement(containing text: String, in app: XCUIApplication) -> XCUIElement {
        app.descendants(matching: .any)
            .containing(NSPredicate(format: "label CONTAINS %@", text))
            .element
    }

    private func button(containing text: String, in app: XCUIApplication) -> XCUIElement {
        app.buttons
            .containing(NSPredicate(format: "label CONTAINS %@", text))
            .element
    }
}

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

    func testPracticeRootKeepsSpeakingPrimary() throws {
        let app = launchApp(initialTab: "practice")

        XCTAssertTrue(element("screen-practice", in: app).waitForExistence(timeout: 5))
        XCTAssertTrue(element("practice-start-speaking", in: app).exists)
        XCTAssertTrue(element("practice-choose-situation", in: app).exists)
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

    func testTutorIsVoiceOnly() throws {
        let app = launchTutorApp(extraArguments: [])

        XCTAssertTrue(element("speech-practice-panel", in: app).waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Say one English sentence."].exists)
        XCTAssertTrue(app.buttons["Start speaking"].exists)
        XCTAssertFalse(app.textFields["tutor-text-input"].exists)
        XCTAssertFalse(app.buttons["tutor-send-button"].exists)
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
        XCTAssertTrue(app.staticTexts["Correct phrase"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["I went to work yesterday, and I was tired."].exists)
        XCTAssertTrue(app.staticTexts["Natural version"].exists)
        XCTAssertTrue(app.staticTexts["I had a long day at work yesterday."].exists)
        XCTAssertTrue(app.staticTexts["Tell me why you were tired."].waitForExistence(timeout: 3))
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
            "I went to work yesterday and I was tired"
        ])

        XCTAssertTrue(app.buttons["Send to Tutor"].waitForExistence(timeout: 5))
        app.buttons["Send to Tutor"].tap()

        XCTAssertTrue(app.buttons["Answer prompt"].waitForExistence(timeout: 5))
        app.buttons["Answer prompt"].tap()
        XCTAssertTrue(app.staticTexts["I went to work yesterday and I was tired"].waitForExistence(timeout: 3))
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

        XCTAssertTrue(app.staticTexts["I can help with that. Keep it short and clear."].waitForExistence(timeout: 8))
        XCTAssertTrue(anyElement(containing: "Showing local guidance", in: app).waitForExistence(timeout: 3))
    }

    func testTutorAIResponseCreatesReviewableLearningObjects() throws {
        let app = launchTutorApp(extraArguments: [
            "-ConverlaxUseMockTutorAI",
            "-ConverlaxTutorVoiceState",
            "transcript"
        ])

        XCTAssertTrue(app.buttons["Send to Tutor"].waitForExistence(timeout: 5))
        app.buttons["Send to Tutor"].tap()

        XCTAssertTrue(app.buttons["More feedback"].waitForExistence(timeout: 5))
        app.buttons["More feedback"].tap()
        XCTAssertTrue(anyElement(containing: "Review later", in: app).waitForExistence(timeout: 3))
        XCTAssertTrue(anyElement(containing: "Say this in the past: I go to work yesterday.", in: app).waitForExistence(timeout: 3))
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

    private func anyElement(containing text: String, in app: XCUIApplication) -> XCUIElement {
        app.descendants(matching: .any)
            .containing(NSPredicate(format: "label CONTAINS %@", text))
            .element
    }
}

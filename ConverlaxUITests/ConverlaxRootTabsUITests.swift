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
    }

    func testProfileRootShowsJourney() throws {
        let app = launchApp(initialTab: "profile")

        XCTAssertTrue(element("screen-profile", in: app).waitForExistence(timeout: 5))
        XCTAssertTrue(element("profile-journey-dashboard", in: app).exists)
    }

    private func launchApp(initialTab: String) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = [
            "-ConverlaxUseEnglishContent",
            "-ConverlaxInitialTab",
            initialTab
        ]
        app.launch()
        return app
    }

    private func element(_ identifier: String, in app: XCUIApplication) -> XCUIElement {
        app.descendants(matching: .any)[identifier]
    }
}

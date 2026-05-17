import SwiftUI

struct ContentView: View {
    @StateObject private var learningState = LearningState()
    @State private var selectedTab: AppTab
    @State private var isShowingForcedOnboarding: Bool
    @State private var homePath: [HomeRoute]
    @State private var practicePath: [PracticeRoute]
    @State private var reviewPath: [ReviewRoute]
    @State private var profilePath: [ProfileRoute]

    init() {
        _selectedTab = State(initialValue: AppTab.launchDefault)
        _isShowingForcedOnboarding = State(initialValue: Self.forceOnboarding)
        _homePath = State(initialValue: HomeRoute.launchDefaultPath)
        _practicePath = State(initialValue: PracticeRoute.launchDefaultPath)
        _reviewPath = State(initialValue: ReviewRoute.launchDefaultPath)
        _profilePath = State(initialValue: ProfileRoute.launchDefaultPath)
    }

    var body: some View {
        Group {
            if learningState.profile.hasCompletedOnboarding && !isShowingForcedOnboarding {
                MainTabView(
                    state: learningState,
                    selectedTab: $selectedTab,
                    homePath: $homePath,
                    practicePath: $practicePath,
                    reviewPath: $reviewPath,
                    profilePath: $profilePath
                )
            } else {
                OnboardingView(state: learningState) {
                    isShowingForcedOnboarding = false
                }
            }
        }
        .fontDesign(.rounded)
        .foregroundStyle(Color.converlaxInk)
    }

    private static var forceOnboarding: Bool {
        ProcessInfo.processInfo.arguments.contains("-ConverlaxForceOnboarding")
    }
}

private struct MainTabView: View {
    @ObservedObject var state: LearningState
    @Binding var selectedTab: AppTab
    @Binding var homePath: [HomeRoute]
    @Binding var practicePath: [PracticeRoute]
    @Binding var reviewPath: [ReviewRoute]
    @Binding var profilePath: [ProfileRoute]

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack(path: $homePath) {
                CourseHomeView(state: state)
                    .accessibilityIdentifier("screen-home")
                    .navigationDestination(for: HomeRoute.self) { route in
                        switch route {
                        case .courseDetail:
                            CourseDetailView(state: state)
                        case .tutor:
                            TutorView(state: state)
                        case .lesson(let lesson):
                            LessonPlayerView(lesson: lesson, state: state)
                        case .lessonDetail(let lesson):
                            LessonDetailView(lesson: lesson, state: state)
                        case .videoLesson(let lesson):
                            LessonModePlayerView(mode: .video, lesson: lesson, state: state)
                        case .speakingDrill(let lesson):
                            LessonModePlayerView(mode: .speakingDrill, lesson: lesson, state: state)
                        case .qaLesson(let lesson):
                            LessonModePlayerView(mode: .qa, lesson: lesson, state: state)
                        case .vocab:
                            VocabLessonView(lesson: BeginnerContent.vocabPracticeLesson(for: state.profile.targetLanguage), state: state)
                        case .verbs:
                            VerbLessonView(lesson: BeginnerContent.verbPracticeLesson(for: state.profile.targetLanguage), state: state)
                        }
                    }
            }
            .id(AppTab.home)
            .tabItem {
                Label("Home", systemImage: "waveform.path.ecg")
                    .accessibilityIdentifier("tab-home")
            }
            .tag(AppTab.home)

            NavigationStack(path: $practicePath) {
                PracticeHomeView(state: state)
                    .accessibilityIdentifier("screen-practice")
            }
            .id(AppTab.practice)
            .tabItem {
                Label("Practice", systemImage: "mic.circle.fill")
                    .accessibilityIdentifier("tab-practice")
            }
            .tag(AppTab.practice)

            NavigationStack(path: $reviewPath) {
                ReviewHomeView(state: state)
                    .accessibilityIdentifier("screen-review")
            }
            .id(AppTab.review)
            .tabItem {
                Label("Review", systemImage: "bolt.fill")
                    .accessibilityIdentifier("tab-review")
            }
            .tag(AppTab.review)

            NavigationStack(path: $profilePath) {
                SpeakProfileHomeView(state: state)
                    .accessibilityIdentifier("screen-profile")
            }
            .id(AppTab.profile)
            .tabItem {
                Label("Profile", systemImage: "person.fill")
                    .accessibilityIdentifier("tab-profile")
            }
            .tag(AppTab.profile)
        }
        .tint(Color.primaryBlue)
    }
}

#Preview {
    ContentView()
}

import SwiftUI

struct ContentView: View {
    @StateObject private var learningState = LearningState()
    @State private var selectedTab: AppTab
    @State private var activeSheet: ActiveSheet?

    init() {
        _selectedTab = State(initialValue: AppTab.launchDefault)
    }

    var body: some View {
        Group {
            if learningState.profile.hasCompletedOnboarding && !Self.forceOnboarding {
                MainTabView(
                    state: learningState,
                    selectedTab: $selectedTab,
                    activeSheet: $activeSheet
                )
            } else {
                OnboardingView(state: learningState)
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
    @Binding var activeSheet: ActiveSheet?
    @State private var homePath = HomeRoute.launchDefaultPath
    @State private var freeTalkPath = FreeTalkRoute.launchDefaultPath
    @State private var reviewPath = ReviewRoute.launchDefaultPath
    @State private var roleplaysPath = FreeTalkRoute.launchDefaultPath
    @State private var profilePath = ProfileRoute.launchDefaultPath

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack(path: $homePath) {
                CourseHomeView(state: state, activeSheet: $activeSheet)
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
                        case .lessonLines(let lesson):
                            LessonLinesView(lesson: lesson, state: state)
                        case .videoLesson(let lesson):
                            LessonModePlayerView(mode: .video, lesson: lesson, state: state)
                        case .speakingDrill(let lesson):
                            LessonModePlayerView(mode: .speakingDrill, lesson: lesson, state: state)
                        case .qaLesson(let lesson):
                            LessonModePlayerView(mode: .qa, lesson: lesson, state: state)
                        case .customLesson:
                            CreateRoleplayView(state: state)
                        case .vocab:
                            VocabLessonView(lesson: BeginnerContent.vocabPracticeLesson(for: state.profile.targetLanguage), state: state)
                        case .verbs:
                            VerbLessonView(lesson: BeginnerContent.verbPracticeLesson(for: state.profile.targetLanguage), state: state)
                        }
                    }
            }
            .tabItem {
                Label("Home", systemImage: "waveform.path.ecg")
                    .accessibilityIdentifier("tab-home")
            }
            .tag(AppTab.home)

            NavigationStack(path: $freeTalkPath) {
                FreeTalkHomeView(state: state)
                    .accessibilityIdentifier("screen-free-talk")
            }
            .tabItem {
                Label("Free Talk", systemImage: "mic.circle.fill")
                    .accessibilityIdentifier("tab-free-talk")
            }
            .tag(AppTab.freeTalk)

            NavigationStack(path: $reviewPath) {
                ReviewHomeView(state: state)
                    .accessibilityIdentifier("screen-review")
            }
            .tabItem {
                Label("Review", systemImage: "bolt.fill")
                    .accessibilityIdentifier("tab-review")
            }
            .tag(AppTab.review)

            NavigationStack(path: $roleplaysPath) {
                RoleplaysHomeView(state: state)
                    .accessibilityIdentifier("screen-roleplays")
            }
            .tabItem {
                Label("Roleplays", systemImage: "person.2.wave.2.fill")
                    .accessibilityIdentifier("tab-roleplays")
            }
            .tag(AppTab.roleplays)

            NavigationStack(path: $profilePath) {
                SpeakProfileHomeView(state: state)
                    .accessibilityIdentifier("screen-profile")
            }
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                        .accessibilityIdentifier("tab-profile")
                }
                .tag(AppTab.profile)
        }
        .tint(Color.primaryBlue)
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .level:
                LevelSelectionView(state: state)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            case .streak:
                StreakDetailView(state: state)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
        }
    }
}

#Preview {
    ContentView()
}

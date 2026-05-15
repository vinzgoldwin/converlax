import SwiftUI

struct PracticeHomeView: View {
    @ObservedObject var state: LearningState

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    SectionHeader(title: "Start speaking", subtitle: "Open Free Talk or choose a situation.")

                    NavigationLink(value: PracticeRoute.session) {
                        HeroActionCard(title: "Open Free Talk", subtitle: "Answer one prompt now", symbol: "mic.circle.fill", color: .primaryBlue, asset: .freeTalk)
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("practice-start-speaking")

                    practiceActions
                }
                .padding(20)
            }
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 96)
            }
        }
        .navigationTitle("Practice")
        .navigationDestination(for: PracticeRoute.self) { route in
            switch route {
            case .session:
                FreeTalkSessionView(state: state)
            case .tutor:
                TutorView(state: state)
            case .createRoleplay:
                CreateRoleplayView(state: state)
            case .topics:
                SituationBrowserView(state: state)
            case .topic(let topic):
                TopicDetailView(topic: topic, state: state)
            case .roleplay(let roleplay), .communityRoleplay(let roleplay):
                RoleplayDetailView(roleplay: roleplay, state: state)
            case .history:
                HistoryUsageView(state: state)
            case .favorites:
                SituationBrowserView(state: state, initialFilter: .favorites)
            case .community:
                SituationBrowserView(state: state, initialFilter: .community)
            }
        }
    }

    private var practiceActions: some View {
        VStack(spacing: 0) {
            NavigationLink(value: PracticeRoute.topics) {
                SettingsLikeRow(symbol: "person.2.wave.2.fill", title: "Choose a situation", subtitle: "Pick a real-world scenario", asset: .roleplay)
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("practice-choose-situation")

            Divider().padding(.leading, 72)

            NavigationLink(value: PracticeRoute.createRoleplay) {
                SettingsLikeRow(symbol: "plus.bubble.fill", title: "Create a situation", subtitle: "Use your own moment", asset: .customLesson)
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("practice-create-custom")

            Divider().padding(.leading, 72)

            NavigationLink(value: PracticeRoute.tutor) {
                SettingsLikeRow(symbol: "bubble.left.and.bubble.right.fill", title: "Ask tutor", subtitle: "Get help before speaking", asset: .askInfo)
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("practice-tutor")
        }
        .background(Color.claySurface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

struct ReviewHomeView: View {
    @ObservedObject var state: LearningState

    private var reviewCount: Int {
        state.reviewItems.count
    }

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    SectionHeader(
                        title: reviewCount == 0 ? "Nothing due" : "Due today",
                        subtitle: reviewCount == 0 ? state.nextRecommendation.reason : "Keep saved words and lines active."
                    )
                    NavigationLink(value: ReviewRoute.smartReview) {
                        HeroActionCard(
                            title: reviewCount == 0 ? "Review is clear" : "Review due items",
                            subtitle: reviewCount == 0 ? state.nextRecommendation.title : "\(reviewCount) ready from saved content and practice",
                            symbol: "bolt.circle.fill",
                            color: .primaryBlue,
                            asset: .review
                        )
                    }
                    .buttonStyle(.plain)

                    VStack(spacing: 0) {
                        NavigationLink(value: ReviewRoute.savedLinesReview) {
                            SettingsLikeRow(symbol: "bookmark.fill", title: "Practice saved lines", subtitle: "\(state.savedLines.count) lines ready")
                        }
                        .buttonStyle(.plain)

                        Divider().padding(.leading, 62)

                        NavigationLink(value: ReviewRoute.reviewInfo) {
                            SettingsLikeRow(symbol: "info.circle.fill", title: "Review timing", subtitle: "Why items come back")
                        }
                        .buttonStyle(.plain)
                    }
                    .background(Color.claySurface.opacity(0.68), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.clayStroke.opacity(0.66), lineWidth: 1)
                    )
                }
                .padding(20)
            }
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 96)
            }
        }
        .navigationTitle("Review")
        .navigationDestination(for: ReviewRoute.self) { route in
            switch route {
            case .smartReview:
                SmartReviewView(state: state)
            case .savedLinesReview:
                SavedLinesReviewView(state: state)
            case .savedLineSearch:
                SavedLinesView(state: state, searchable: true)
            case .reviewInfo:
                InfoDetailView(title: "Review timing", subtitle: "Saved words, saved lines, and recent mistakes come back when they are ready to practice.")
            }
        }
    }
}

struct SpeakProfileHomeView: View {
    @ObservedObject var state: LearningState

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 18) {
                    profileHeader
                    profileStats
                    profileLinks
                }
                .padding(20)
            }
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 96)
            }
        }
        .navigationTitle("Profile")
        .navigationDestination(for: ProfileRoute.self) { route in
            switch route {
            case .savedLines:
                SavedLinesView(state: state)
            case .activities:
                ActivitiesView(state: state)
            case .practiceHistory:
                HistoryUsageView(state: state)
            case .settings:
                SettingsView(state: state)
            case .membership:
                InfoDetailView(title: "Membership", subtitle: "Plan status is mocked for Phase 1 and will move here when billing and account sync are connected.")
            case .editProfile:
                InfoDetailView(title: "Learner profile", subtitle: "Name, avatar, and account syncing are waiting on backend requirements.")
            case .referrals:
                InfoDetailView(title: "Invite a friend", subtitle: "Share Converlax when referrals are available.")
            case .notifications:
                NotificationPreferencesView(state: state)
            case .support:
                InfoDetailView(title: "Get support", subtitle: "Find help, report an issue, or send lesson feedback.")
            case .appLanguage:
                InfoDetailView(title: "App language", subtitle: "Interface language selection will appear after localization is connected.")
            case .courseLanguage:
                LevelSelectionView(state: state)
            case .voiceRecognition:
                VoiceRecognitionSettingsView(state: state)
            case .login:
                InfoDetailView(title: "Log in", subtitle: "Sign in when account syncing is available.")
            case .resetPassword:
                InfoDetailView(title: "Reset password", subtitle: "Update your password when account syncing is available.")
            }
        }
    }

    private var profileHeader: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .center, spacing: 14) {
                ConverlaxMascotView(state: .avatar, size: 74, isAnimated: false)

                VStack(alignment: .leading, spacing: 5) {
                    Text("Learner")
                        .font(.title2.weight(.bold))
                    Text("\(state.profile.currentLevel.rawValue) \(state.profile.targetLanguage.rawValue)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: 8)

                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(state.profile.streak)")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(Color.warmAmber)
                    Text("day streak")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Course progress")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("\(state.completedLessonCount)/\(state.courseLessons.count) lessons")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color.primaryBlue)
                }
                LessonProgressBar(progress: state.courseProgress)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(18)
        .background(Color.claySurface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var profileStats: some View {
        HStack(spacing: 12) {
            StatCard(value: "\(state.profile.dailyGoal)", label: "Daily goal", color: .mintSuccess)
            StatCard(value: "\(savedContentCount)", label: "Saved", color: .primaryBlue)
            StatCard(value: "\(state.usageSessions.count)", label: "Sessions", color: .warmAmber)
        }
    }

    private var profileLinks: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(spacing: 0) {
                NavigationLink(value: ProfileRoute.savedLines) {
                    SettingsLikeRow(symbol: "bookmark.fill", title: "Practice saved lines", subtitle: "\(state.savedLines.count) ready")
                }

                Divider().padding(.leading, 72)

                NavigationLink(value: ProfileRoute.practiceHistory) {
                    SettingsLikeRow(symbol: "clock.fill", title: "Practice history", subtitle: "\(state.usageSessions.count) sessions")
                }

                Divider().padding(.leading, 72)

                NavigationLink(value: ProfileRoute.activities) {
                    SettingsLikeRow(symbol: "list.bullet.rectangle.fill", title: "Recent activity", subtitle: "\(state.activities.count) updates")
                }
            }
            .background(Color.claySurface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))

            VStack(spacing: 0) {
                NavigationLink(value: ProfileRoute.settings) {
                    SettingsLikeRow(symbol: "gearshape.fill", title: "Adjust settings", subtitle: "Language, voice, reminders")
                }
            }
            .background(Color.claySurface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private var savedContentCount: Int {
        state.savedLines.count + state.savedLearningObjects.count + state.favoriteRoleplays.count
    }
}

struct StreakDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var state: LearningState

    var body: some View {
        VStack(spacing: 22) {
            ConverlaxAssetBadge(kind: .streak, size: 86)
            Text(state.profile.streak == 0 ? "Start your streak" : "\(state.profile.streak)-day streak")
                .font(.largeTitle.weight(.bold))
            Text("Finish one lesson or speaking session each day to keep your record active.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            LessonProgressBar(progress: Double(min(state.completedLessonCount, state.profile.dailyGoal)) / Double(max(state.profile.dailyGoal, 1)))
            Text("Daily goal: \(state.profile.dailyGoal) lessons")
                .font(.headline.weight(.semibold))
            Spacer()
            Button("Done") { dismiss() }
                .buttonStyle(PrimaryButtonStyle())
        }
        .padding(24)
        .background(Color.appBackground.ignoresSafeArea())
    }
}

struct LessonDetailView: View {
    let lesson: BeginnerLesson
    @ObservedObject var state: LearningState

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                LessonDetailHero(lesson: lesson)

                NavigationLink(value: HomeRoute.lesson(lesson)) {
                    Label("Start lesson", systemImage: "play.fill")
                }
                .buttonStyle(PrimaryButtonStyle())
                .accessibilityIdentifier("lesson-detail-start-button")

                LessonPracticePreview(lesson: lesson)

                LessonToolsMenu(lesson: lesson)
            }
            .padding(20)
        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle("Lesson")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct LessonDetailHero: View {
    let lesson: BeginnerLesson

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .center, spacing: 14) {
                ConverlaxAssetBadge(kind: lesson.visualAsset, size: 68)

                VStack(alignment: .leading, spacing: 6) {
                    Text(lesson.title)
                        .font(.title2.weight(.bold))
                    Text("\(lesson.minutes) min")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.primaryBlue)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.primaryBlue.opacity(0.1), in: Capsule())
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            VStack(alignment: .leading, spacing: 5) {
                Text("Learning goal")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.primaryBlue)
                Text(lesson.subtitle)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(18)
        .background(Color.claySurface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

private struct LessonPracticePreview: View {
    let lesson: BeginnerLesson

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("What you will practice")
                .font(.headline.weight(.semibold))

            ForEach(items) { item in
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: item.symbol)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(item.color)
                        .frame(width: 24, height: 24)

                    VStack(alignment: .leading, spacing: 3) {
                        Text(item.title)
                            .font(.subheadline.weight(.semibold))
                        Text(item.detail)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .padding(16)
        .background(Color.claySurface.opacity(0.72), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.clayStroke.opacity(0.8), lineWidth: 1)
        )
    }

    private var items: [LessonPracticePreviewItem] {
        var preview: [LessonPracticePreviewItem] = []

        if !lesson.savedWords.isEmpty {
            let terms = lesson.savedWords.prefix(3).map(\.term).joined(separator: ", ")
            preview.append(
                LessonPracticePreviewItem(
                    id: "words",
                    symbol: "character.book.closed.fill",
                    title: "\(lesson.savedWords.count) useful \(lesson.savedWords.count == 1 ? "word" : "words")",
                    detail: terms,
                    color: .warmAmber
                )
            )
        }

        let choiceCount = lesson.steps.filter { $0.kind == .choice }.count
        if choiceCount > 0 {
            preview.append(
                LessonPracticePreviewItem(
                    id: "checks",
                    symbol: "checkmark.circle.fill",
                    title: "\(choiceCount) quick \(choiceCount == 1 ? "check" : "checks")",
                    detail: "Choose the natural meaning or reply.",
                    color: .primaryBlue
                )
            )
        }

        let speakingCount = lesson.steps.filter { $0.kind == .speak }.count
        if speakingCount > 0 {
            preview.append(
                LessonPracticePreviewItem(
                    id: "speaking",
                    symbol: "mic.fill",
                    title: "\(speakingCount) speaking \(speakingCount == 1 ? "prompt" : "prompts")",
                    detail: "Practice the line out loud when it appears.",
                    color: .mintSuccess
                )
            )
        }

        if preview.isEmpty {
            preview.append(
                LessonPracticePreviewItem(
                    id: "guided",
                    symbol: lesson.icon,
                    title: "Short guided practice",
                    detail: lesson.subtitle,
                    color: lesson.accent.color
                )
            )
        }

        return Array(preview.prefix(3))
    }
}

private struct LessonPracticePreviewItem: Identifiable {
    let id: String
    let symbol: String
    let title: String
    let detail: String
    let color: Color
}

struct LessonToolsMenu: View {
    let lesson: BeginnerLesson
    var title = "More lesson tools"
    var includesCourseModes = false

    var body: some View {
        Menu {
            NavigationLink(value: HomeRoute.lessonLines(lesson)) {
                Label("Practice lesson lines", systemImage: "text.quote")
            }
            NavigationLink(value: HomeRoute.speakingDrill(lesson)) {
                Label("Practice speaking", systemImage: "mic.fill")
            }

            if includesCourseModes {
                NavigationLink(value: HomeRoute.videoLesson(lesson)) {
                    Label("Watch and repeat", systemImage: "play.rectangle.fill")
                }
                NavigationLink(value: HomeRoute.qaLesson(lesson)) {
                    Label("Answer prompts", systemImage: "questionmark.bubble.fill")
                }
                NavigationLink(value: HomeRoute.customLesson) {
                    Label("Create a situation", systemImage: "plus.bubble.fill")
                }
            }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "ellipsis.circle")
                    .font(.headline.weight(.semibold))
                Text(title)
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Image(systemName: "chevron.down")
                    .font(.caption.weight(.bold))
            }
            .foregroundStyle(Color.primaryBlue)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 48)
            .padding(.horizontal, 16)
            .background(Color.claySurface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.clayStroke, lineWidth: 1)
            )
        }
        .accessibilityIdentifier("lesson-tools-menu")
    }
}

struct LessonLinesView: View {
    let lesson: BeginnerLesson
    @ObservedObject var state: LearningState

    var body: some View {
        List {
            ForEach(lesson.savedWords) { word in
                VStack(alignment: .leading, spacing: 6) {
                    Text(word.term).font(.headline)
                    Text(word.translation).foregroundStyle(.secondary)
                    Text(word.example).font(.caption).foregroundStyle(.secondary)
                }
                .padding(.vertical, 6)
            }
        }
        .navigationTitle("Practice lines")
    }
}

private struct FreeTalkSessionView: View {
    @ObservedObject var state: LearningState
    @State private var finished = false
    @State private var summary: LearningSessionSummary?
    @State private var feedback: LearningFeedback?

    private let prompt = "Tell me about your day using one sentence. Then ask me a question back."
    private let mockTranscript = "I usually study English at night. How about you?"

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    LessonProgressBar(progress: finished ? 1 : 0.45)
                    SectionHeader(title: finished ? "Session saved" : "Answer one prompt", subtitle: finished ? "Saved in Profile > Practice history." : "Speak naturally, then save the session.")
                    ConverlaxMascotView(state: finished ? .success : .listening, size: 116)
                        .frame(maxWidth: .infinity)
                    Text(finished ? "You practiced open conversation. Your history and saved material are under Profile." : prompt)
                        .font(.title3.weight(.semibold))
                        .padding(18)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.claySurface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))

                    if let feedback {
                        LearningFeedbackCard(feedback: feedback)
                    }

                    if let summary {
                        SessionSummaryPanel(summary: summary)
                    }

                    if finished {
                        PracticeSavedHint()
                    }
                }
                .padding(.bottom, 4)
            }

            Button(finished ? "Practice again" : "Save session") {
                handlePrimaryAction()
            }
            .buttonStyle(PrimaryButtonStyle())
            .accessibilityIdentifier("free-talk-primary-action")
        }
        .padding(20)
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle("Free Talk")
        .toolbar(.hidden, for: .tabBar)
        .accessibilityIdentifier("free-talk-session")
    }

    private func handlePrimaryAction() {
        if finished {
            finished = false
            summary = nil
            feedback = nil
        } else {
            let result = state.recordConversationSession(
                title: "Free Talk",
                detail: "Open speaking session",
                minutes: 5,
                transcript: mockTranscript,
                strongPhrases: ["How about you?", "I usually study English at night."],
                weakPhrases: ["I study English in night."],
                prompt: prompt
            )
            summary = result.summary
            feedback = result.feedback
            finished = true
        }
    }
}

private struct PracticeSavedHint: View {
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "person.crop.circle.fill")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.primaryBlue)
                .frame(width: 24, height: 24)

            Text("Find this later in Profile under Practice history. Saved lines and situations live in Saved content.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.claySurface.opacity(0.72), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.clayStroke.opacity(0.8), lineWidth: 1)
        )
    }
}

struct CreateRoleplayView: View {
    @ObservedObject var state: LearningState
    @State private var prompt = "Ordering coffee before a meeting"
    @State private var generated = false

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            SectionHeader(title: "Create a situation", subtitle: "Describe what you want to practice.")
            ConverlaxAssetBadge(kind: generated ? .roleplay : .customLesson, size: 112)
                .frame(maxWidth: .infinity)
            TextField("Situation to practice", text: $prompt, axis: .vertical)
                .padding(16)
                .background(Color.claySurface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            if generated, let roleplay = state.roleplays.first {
                RoleplayRow(roleplay: roleplay, favorite: state.isFavorite(roleplay))
            }
            Spacer()
            Button(generated ? "Regenerate" : "Generate situation") {
                generated = true
            }
            .buttonStyle(PrimaryButtonStyle())
        }
        .padding(20)
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle("Create")
    }
}

private enum SituationFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case topics = "Topics"
    case favorites = "Favorites"
    case community = "Community"

    var id: String { rawValue }

    var emptyTitle: String {
        switch self {
        case .all, .topics:
            "No situations"
        case .favorites:
            "No favorites yet"
        case .community:
            "No community situations"
        }
    }

    var emptyDescription: String {
        switch self {
        case .all, .topics:
            "New situations will appear here."
        case .favorites:
            "Save a situation to keep it here."
        case .community:
            "Community situations will appear here."
        }
    }
}

private struct SituationBrowserView: View {
    @ObservedObject var state: LearningState
    @State private var filter: SituationFilter

    init(state: LearningState, initialFilter: SituationFilter = .all) {
        self.state = state
        _filter = State(initialValue: initialFilter)
    }

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    SectionHeader(title: "Choose a situation", subtitle: "Pick a scenario, browse topics, or filter saved situations.")

                    Picker("Situation filter", selection: $filter) {
                        ForEach(SituationFilter.allCases) { filter in
                            Text(filter.rawValue).tag(filter)
                        }
                    }
                    .pickerStyle(.segmented)
                    .accessibilityIdentifier("situation-filter")

                    situationContent
                }
                .padding(20)
            }
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 96)
            }
        }
        .navigationTitle("Situations")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink(value: PracticeRoute.createRoleplay) {
                    Image(systemName: "plus.bubble.fill")
                }
                .accessibilityIdentifier("situation-create-custom")
            }
        }
    }

    @ViewBuilder
    private var situationContent: some View {
        switch filter {
        case .all:
            roleplayList(state.roleplays, emptyTitle: filter.emptyTitle, emptyDescription: filter.emptyDescription)
        case .topics:
            topicList
        case .favorites:
            roleplayList(state.favoriteRoleplays, emptyTitle: filter.emptyTitle, emptyDescription: filter.emptyDescription)
        case .community:
            roleplayList(state.communityRoleplays, emptyTitle: filter.emptyTitle, emptyDescription: filter.emptyDescription)
        }
    }

    private var topicList: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(state.roleplayTopics) { topic in
                NavigationLink(value: PracticeRoute.topic(topic)) {
                    TopicRow(topic: topic)
                }
                .buttonStyle(.plain)
            }
        }
    }

    @ViewBuilder
    private func roleplayList(_ roleplays: [RoleplayScenario], emptyTitle: String, emptyDescription: String) -> some View {
        if roleplays.isEmpty {
            ContentUnavailableView(emptyTitle, systemImage: "person.2.wave.2.fill", description: Text(emptyDescription))
                .frame(maxWidth: .infinity)
                .padding(.top, 28)
        } else {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(roleplays) { roleplay in
                    NavigationLink(value: PracticeRoute.roleplay(roleplay)) {
                        RoleplayRow(roleplay: roleplay, favorite: state.isFavorite(roleplay))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

private struct TopicDetailView: View {
    let topic: RoleplayTopic
    @ObservedObject var state: LearningState

    var body: some View {
        List {
            Section(topic.subtitle) {
                ForEach(state.roleplays.filter { topic.scenarioIDs.contains($0.id) }) { roleplay in
                    NavigationLink(value: PracticeRoute.roleplay(roleplay)) {
                        RoleplayRow(roleplay: roleplay, favorite: state.isFavorite(roleplay))
                    }
                }
            }
        }
        .navigationTitle(topic.title)
    }
}

private struct RoleplayDetailView: View {
    let roleplay: RoleplayScenario
    @ObservedObject var state: LearningState
    @State private var completed = false
    @State private var summary: LearningSessionSummary?
    @State private var feedback: LearningFeedback?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                HeroActionCard(title: roleplay.title, subtitle: roleplay.subtitle, symbol: roleplay.isCommunity ? "person.3.fill" : "person.2.wave.2.fill", color: roleplay.isCommunity ? .violetAccent : .primaryBlue, asset: roleplay.isCommunity ? .community : .roleplay)
                HStack(spacing: 12) {
                    StatCard(value: "\(roleplay.minutes)", label: "Minutes", color: .primaryBlue)
                    StatCard(value: roleplay.difficulty.code, label: "Level", color: .warmAmber)
                }
                ForEach(roleplay.lines) { line in
                    SavedLineRow(line: line) {
                        state.saveLine(line)
                    }
                }
                Button(state.isFavorite(roleplay) ? "Remove saved situation" : "Save situation") {
                    state.toggleFavorite(roleplay)
                }
                .buttonStyle(SecondaryButtonStyle())
                Button(completed ? "Practice again" : "Start situation") {
                    handlePrimaryAction()
                }
                .buttonStyle(PrimaryButtonStyle())
                .accessibilityIdentifier("roleplay-primary-action")
                if let feedback {
                    LearningFeedbackCard(feedback: feedback)
                }
                if let summary {
                    SessionSummaryPanel(summary: summary)
                }
                if completed {
                    PracticeSavedHint()
                }
            }
            .padding(20)
        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle("Situation")
        .toolbar(.hidden, for: .tabBar)
        .accessibilityIdentifier("roleplay-detail")
    }

    private func handlePrimaryAction() {
        if completed {
            completed = false
            summary = nil
            feedback = nil
        } else {
            let result = state.recordConversationSession(
                title: roleplay.title,
                detail: roleplay.setting,
                minutes: roleplay.minutes,
                transcript: roleplay.lines.map(\.text).joined(separator: " "),
                strongPhrases: roleplay.lines.prefix(1).map(\.text),
                weakPhrases: roleplay.lines.dropFirst().prefix(1).map(\.text),
                prompt: "Roleplay at \(roleplay.setting): \(roleplay.subtitle)"
            )
            summary = result.summary
            feedback = result.feedback
            completed = true
        }
    }
}

private struct HistoryUsageView: View {
    @ObservedObject var state: LearningState

    var body: some View {
        List {
            Section {
                ProfileRecordSummaryRow(
                    symbol: "clock.fill",
                    title: "\(state.usageSessions.count) practice sessions",
                    detail: "Completed conversations, reviews, tutor chats, and usage records live here."
                )
            }
            .listRowBackground(Color.clear)

            Section("Recent sessions") {
                if state.usageSessions.isEmpty {
                    Text("Finished practice sessions will appear here.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(state.usageSessions) { session in
                        UsageRow(session: session)
                            .listRowInsets(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 0))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle("Practice history")
    }
}

private struct FavoritesView: View {
    @ObservedObject var state: LearningState

    var body: some View {
        List {
            Section {
                Text("Saved situations are also available from Saved content in Profile.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Section("Saved situations") {
                if state.favoriteRoleplays.isEmpty {
                    Text("Saved situations will appear here.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(state.favoriteRoleplays) { roleplay in
                        NavigationLink(value: PracticeRoute.roleplay(roleplay)) {
                            RoleplayRow(roleplay: roleplay, favorite: true)
                        }
                        .listRowInsets(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 0))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle("Saved situations")
    }
}

private struct CommunityView: View {
    @ObservedObject var state: LearningState
    @State private var sortPopularFirst = true

    var body: some View {
        List {
            Toggle("Popular first", isOn: $sortPopularFirst)
            ForEach(state.communityRoleplays) { roleplay in
                NavigationLink(value: PracticeRoute.communityRoleplay(roleplay)) {
                    RoleplayRow(roleplay: roleplay, favorite: state.isFavorite(roleplay))
                }
            }
        }
        .navigationTitle("Community")
    }
}

private struct SmartReviewView: View {
    @ObservedObject var state: LearningState
    @State private var index = 0
    @State private var showAnswer = false

    var items: [ScheduledReviewItem] {
        state.dueReviewItems
    }

    var item: ScheduledReviewItem {
        items[index % max(items.count, 1)]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            if items.isEmpty {
                ContentUnavailableView("No review due", systemImage: "checkmark.seal.fill", description: Text("Saved phrases and mistakes will appear here."))
            } else {
                LessonProgressBar(progress: Double(index + 1) / Double(max(items.count, 1)))
                HStack {
                    Text(item.kind.rawValue)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color.primaryBlue)
                    Spacer()
                    Text("Confidence \(Int(item.ease * 100))%")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
            ConverlaxMascotView(state: showAnswer ? .success : .thinking, size: 104)
                .frame(maxWidth: .infinity)
            Text(item.prompt)
                .font(.title3.weight(.semibold))
                .padding(18)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.claySurface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            if showAnswer {
                Text(item.answer)
                    .font(.headline)
                    .foregroundStyle(Color.mintSuccess)
            }
            Spacer()
                if showAnswer {
                    HStack(spacing: 12) {
                        Button("Need practice") {
                            state.recordReview(item, remembered: false)
                            advanceReview()
                        }
                        .buttonStyle(SecondaryButtonStyle())
                        Button("Remembered") {
                            state.recordReview(item, remembered: true)
                            advanceReview()
                        }
                        .buttonStyle(PrimaryButtonStyle())
                    }
                } else {
                    Button("Show answer") {
                        showAnswer = true
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }
            }
        }
        .padding(20)
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle("Review due items")
    }

    private func advanceReview() {
        index = min(index, max(items.count - 1, 0))
        showAnswer = false
    }
}

private struct SavedLinesReviewView: View {
    @ObservedObject var state: LearningState
    @State private var listeningMode = false

    var body: some View {
        List {
            Toggle("Listening mode", isOn: $listeningMode)
            ForEach(state.savedLines) { line in
                VStack(alignment: .leading, spacing: 6) {
                    Text(listeningMode ? "Tap to reveal line" : line.text)
                        .font(.headline)
                    Text(line.translation)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 6)
            }
            NavigationLink(value: ReviewRoute.savedLineSearch) {
                Label("Search a line", systemImage: "magnifyingglass")
            }
        }
        .navigationTitle("Practice saved lines")
    }
}

private enum SavedContentFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case lines = "Lines"
    case situations = "Situations"
    case items = "Items"

    var id: String { rawValue }
}

private struct SavedLinesView: View {
    @ObservedObject var state: LearningState
    var searchable = false
    @State private var filter: SavedContentFilter = .all
    @State private var query = ""

    var filteredLines: [SavedLine] {
        guard !query.isEmpty else { return state.savedLines }
        return state.savedLines.filter {
            $0.text.localizedCaseInsensitiveContains(query)
                || $0.translation.localizedCaseInsensitiveContains(query)
                || $0.source.localizedCaseInsensitiveContains(query)
                || $0.note.localizedCaseInsensitiveContains(query)
        }
    }

    var filteredRoleplays: [RoleplayScenario] {
        guard !query.isEmpty else { return state.favoriteRoleplays }
        return state.favoriteRoleplays.filter {
            $0.title.localizedCaseInsensitiveContains(query)
                || $0.subtitle.localizedCaseInsensitiveContains(query)
                || $0.setting.localizedCaseInsensitiveContains(query)
        }
    }

    var filteredObjects: [SavedLearningObject] {
        guard !query.isEmpty else { return state.savedLearningObjects }
        return state.savedLearningObjects.filter {
            $0.text.localizedCaseInsensitiveContains(query)
                || $0.translation.localizedCaseInsensitiveContains(query)
                || $0.source.localizedCaseInsensitiveContains(query)
                || $0.note.localizedCaseInsensitiveContains(query)
                || $0.kind.rawValue.localizedCaseInsensitiveContains(query)
        }
    }

    var body: some View {
        List {
            Section {
                Picker("Saved content filter", selection: $filter) {
                    ForEach(SavedContentFilter.allCases) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
                .pickerStyle(.segmented)
            }

            if hasNoSearchResults {
                ContentUnavailableView("No saved content", systemImage: "magnifyingglass", description: Text("Try a different search."))
            }

            if showsLines {
                Section("Lines to practice") {
                    ForEach(filteredLines) { line in
                        SavedLineRow(line: line) {
                            state.removeLine(line)
                        }
                    }
                }
            }

            if showsSituations {
                Section("Saved situations") {
                    if filteredRoleplays.isEmpty {
                        Text("Saved situations will appear here.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(filteredRoleplays) { roleplay in
                            NavigationLink {
                                RoleplayDetailView(roleplay: roleplay, state: state)
                            } label: {
                                RoleplayRow(roleplay: roleplay, favorite: true)
                            }
                            .listRowInsets(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 0))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                        }
                    }
                }
            }

            if showsObjects {
                Section("Words and phrases") {
                    ForEach(filteredObjects) { object in
                        LearningObjectRow(object: object) {}
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color.appBackground.ignoresSafeArea())
        .searchable(text: $query, prompt: "Search saved content")
        .navigationTitle(searchable ? "Find saved content" : "Saved content")
    }

    private var showsLines: Bool {
        filter == .all || filter == .lines
    }

    private var showsSituations: Bool {
        filter == .all || filter == .situations
    }

    private var showsObjects: Bool {
        filter == .all || filter == .items
    }

    private var hasNoSearchResults: Bool {
        guard !query.isEmpty else { return false }

        let linesEmpty = !showsLines || filteredLines.isEmpty
        let situationsEmpty = !showsSituations || filteredRoleplays.isEmpty
        let objectsEmpty = !showsObjects || filteredObjects.isEmpty
        return linesEmpty && situationsEmpty && objectsEmpty
    }
}

private struct ActivitiesView: View {
    @ObservedObject var state: LearningState

    var body: some View {
        List {
            Section {
                ProfileRecordSummaryRow(
                    symbol: "list.bullet.rectangle.fill",
                    title: "\(state.activities.count) recent events",
                    detail: "Lessons, saved lines, reviews, and speaking sessions."
                )
            }
            .listRowBackground(Color.clear)

            Section("Recent activity") {
                if state.activities.isEmpty {
                    Text("Recent activity will appear here.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(state.activities) { activity in
                        HStack(spacing: 12) {
                            AvatarBadge(symbol: activity.symbol, color: .primaryBlue)
                                .frame(width: 42, height: 42)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(activity.title).font(.headline)
                                Text(activity.detail).font(.caption).foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text(activity.dateLabel).font(.caption).foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 5)
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle("Recent activity")
    }
}

private struct SettingsView: View {
    @ObservedObject var state: LearningState

    var body: some View {
        List {
            Section("Learning") {
                Stepper("Daily goal: \(state.profile.dailyGoal) lessons", value: Binding(get: { state.profile.dailyGoal }, set: state.setDailyGoal), in: 1...6)
                NavigationLink(value: ProfileRoute.courseLanguage) {
                    SettingsNavigationRow(
                        symbol: "globe",
                        title: "Change course or level",
                        detail: "\(state.profile.targetLanguage.rawValue) · \(state.profile.currentLevel.rawValue)"
                    )
                }
                SettingsStatusRow(
                    symbol: "textformat",
                    title: "Change app language",
                    detail: "Use Converlax in another language.",
                    status: "Later"
                )
            }
            Section("Preferences") {
                Toggle("Sound effects", isOn: Binding(get: { state.profile.soundEnabled }, set: state.setSoundEnabled))
                Toggle("Haptics", isOn: Binding(get: { state.profile.hapticsEnabled }, set: state.setHapticsEnabled))
                SettingsToggleNoteRow(
                    symbol: "bell.fill",
                    title: "Set reminders",
                    note: "Get a nudge to practice.",
                    isOn: Binding(get: { state.profile.notificationsEnabled }, set: state.setNotificationsEnabled)
                )
                SettingsToggleNoteRow(
                    symbol: "waveform",
                    title: "Speak by voice",
                    note: "Use voice input during speaking practice.",
                    isOn: Binding(get: { state.profile.voiceRecognitionEnabled }, set: state.setVoiceRecognitionEnabled)
                )
            }
            Section("Account") {
                SettingsStatusRow(
                    symbol: "creditcard.fill",
                    title: "Manage membership",
                    detail: "Choose a plan when accounts are available.",
                    status: "Preview"
                )
                SettingsStatusRow(
                    symbol: "person.crop.circle.fill",
                    title: "Edit profile",
                    detail: "Update your learner name and avatar.",
                    status: "Local"
                )
                SettingsStatusRow(
                    symbol: "person.badge.key.fill",
                    title: "Sign in",
                    detail: "Sync your practice when accounts are available.",
                    status: "Backend"
                )
            }
            Section("Sharing") {
                SettingsStatusRow(
                    symbol: "gift.fill",
                    title: "Invite a friend",
                    detail: "Share Converlax when referrals are available.",
                    status: "Later"
                )
            }
            Section("Support") {
                SettingsStatusRow(
                    symbol: "questionmark.circle.fill",
                    title: "Get support",
                    detail: "Find help, report an issue, or send lesson feedback.",
                    status: "Later"
                )
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle("Settings")
    }
}

private struct ProfileRecordSummaryRow: View {
    let symbol: String
    let title: String
    let detail: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            AvatarBadge(symbol: symbol, color: .primaryBlue)
                .frame(width: 42, height: 42)

            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.headline.weight(.semibold))
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.claySurface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

private struct SettingsNavigationRow: View {
    let symbol: String
    let title: String
    let detail: String

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            AvatarBadge(symbol: symbol, color: .primaryBlue)
                .frame(width: 34, height: 34)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

private struct SettingsStatusRow: View {
    let symbol: String
    let title: String
    let detail: String
    let status: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            AvatarBadge(symbol: symbol, color: .primaryBlue)
                .frame(width: 34, height: 34)

            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                    Spacer()
                    Text(status)
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(Color.primaryBlue)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.primaryBlue.opacity(0.1), in: Capsule())
                }

                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.vertical, 2)
    }
}

private struct SettingsToggleNoteRow: View {
    let symbol: String
    let title: String
    let note: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            AvatarBadge(symbol: symbol, color: .primaryBlue)
                .frame(width: 34, height: 34)

            VStack(alignment: .leading, spacing: 5) {
                Toggle(isOn: $isOn) {
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                }
                Text(note)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.vertical, 2)
    }
}

private struct NotificationPreferencesView: View {
    @ObservedObject var state: LearningState

    var body: some View {
        Form {
            Toggle("Set reminders", isOn: Binding(get: { state.profile.notificationsEnabled }, set: state.setNotificationsEnabled))
            Text("Reminder scheduling is mocked in Phase 1, so this only saves your preference.")
                .foregroundStyle(.secondary)
        }
        .navigationTitle("Notifications")
    }
}

private struct VoiceRecognitionSettingsView: View {
    @ObservedObject var state: LearningState

    var body: some View {
        Form {
            Toggle("Speak by voice", isOn: Binding(get: { state.profile.voiceRecognitionEnabled }, set: state.setVoiceRecognitionEnabled))
            Text("Speech recognition is a local placeholder until speech services are connected.")
                .foregroundStyle(.secondary)
        }
        .navigationTitle("Voice")
    }
}

private struct InfoDetailView: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.largeTitle.weight(.bold))
            Text(subtitle)
                .font(.body)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .padding(20)
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle(title)
    }
}

struct SectionHeader: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.headline.weight(.bold))
                .foregroundStyle(Color.converlaxInk)
            Text(subtitle)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct HeroActionCard: View {
    let title: String
    let subtitle: String
    let symbol: String
    let color: Color
    var asset: ConverlaxAssetKind? = nil

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            if let asset {
                ConverlaxAssetBadge(kind: asset, size: 70)
            } else {
                AvatarBadge(symbol: symbol, color: color)
                    .frame(width: 58, height: 58)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity, minHeight: 104, alignment: .leading)
        .padding(18)
        .background(color.opacity(0.09), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(color.opacity(0.2), lineWidth: 1)
        )
        .contentShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

private struct MiniFlowCard: View {
    let title: String
    let symbol: String
    let color: Color
    var asset: ConverlaxAssetKind? = nil

    var body: some View {
        HStack(spacing: 12) {
            AvatarBadge(symbol: symbol, color: color)
                .frame(width: 36, height: 36)
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
            if asset != nil {
                Image(systemName: "sparkle")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(color.opacity(0.8))
                    .accessibilityHidden(true)
            }
        }
        .padding(.horizontal, 14)
        .frame(minHeight: 54)
        .background(Color.claySurface.opacity(0.62), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

private struct TopicRow: View {
    let topic: RoleplayTopic

    var body: some View {
        HeroActionCard(title: topic.title, subtitle: topic.subtitle, symbol: topic.symbol, color: topic.colorName.color, asset: topic.visualAsset)
    }
}

private struct RoleplayRow: View {
    let roleplay: RoleplayScenario
    let favorite: Bool

    var body: some View {
        HStack(spacing: 12) {
            AvatarBadge(symbol: roleplay.isCommunity ? "person.3.fill" : "person.2.wave.2.fill", color: roleplay.isCommunity ? .violetAccent : .primaryBlue)
                .frame(width: 38, height: 38)
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(roleplay.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                    if favorite {
                        Image(systemName: "star.fill")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color.warmAmber)
                    }
                }
                Text(roleplay.subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            Spacer()
            Text(roleplay.difficulty.code)
                .font(.caption.weight(.bold))
                .foregroundStyle(.secondary)
        }
        .frame(minHeight: 58)
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color.claySurface.opacity(0.62), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.clayStroke.opacity(0.65), lineWidth: 1)
        )
        .contentShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

private struct UsageRow: View {
    let session: UsageSession

    var body: some View {
        HStack(spacing: 12) {
            ConverlaxAssetBadge(kind: .historyUsage, size: 46)
            VStack(alignment: .leading, spacing: 4) {
                Text(session.title)
                    .font(.headline.weight(.semibold))
                Text(session.detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(session.minutes)m")
                    .font(.caption.weight(.bold))
                Text(session.dateLabel)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .background(Color.claySurface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

private struct SavedLineRow: View {
    let line: SavedLine
    let action: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 5) {
                Text(line.text)
                    .font(.headline)
                Text(line.translation)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(line.source)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(Color.primaryBlue)
            }
            Spacer()
            Button(action: action) {
                Image(systemName: "bookmark.fill")
                    .foregroundStyle(Color.primaryBlue)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 6)
    }
}

private struct SettingsLikeRow: View {
    let symbol: String
    let title: String
    let subtitle: String
    var asset: ConverlaxAssetKind? = nil

    var body: some View {
        HStack(spacing: 12) {
            AvatarBadge(symbol: symbol, color: .primaryBlue)
                .frame(width: 36, height: 36)
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundStyle(.secondary)
        }
        .frame(minHeight: 56)
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }
}

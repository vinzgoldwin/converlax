import SwiftUI

struct FreeTalkHomeView: View {
    @ObservedObject var state: LearningState

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    SectionHeader(title: "Free Talk", subtitle: "Practice open conversation or start a roleplay.")

                    NavigationLink(value: FreeTalkRoute.session) {
                        HeroActionCard(title: "Start Free Talk", subtitle: "A flexible speaking session with live prompts", symbol: "mic.circle.fill", color: .primaryBlue, asset: .freeTalk)
                    }
                    .buttonStyle(.plain)

                    quickActions

                    SectionHeader(title: "Topics", subtitle: "Choose a scenario and rehearse useful lines.")
                    ForEach(state.roleplayTopics) { topic in
                        NavigationLink(value: FreeTalkRoute.topic(topic)) {
                            TopicRow(topic: topic)
                        }
                        .buttonStyle(.plain)
                    }

                    SectionHeader(title: "Recent usage", subtitle: "Your last practice sessions.")
                    ForEach(state.usageSessions.prefix(3)) { session in
                        UsageRow(session: session)
                    }
                }
                .padding(20)
            }
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 96)
            }
        }
        .navigationTitle("Free Talk")
        .navigationDestination(for: FreeTalkRoute.self) { route in
            switch route {
            case .session:
                FreeTalkSessionView(state: state)
            case .createRoleplay:
                CreateRoleplayView(state: state)
            case .topics:
                TopicsBrowserView(state: state)
            case .topic(let topic):
                TopicDetailView(topic: topic, state: state)
            case .roleplay(let roleplay), .communityRoleplay(let roleplay):
                RoleplayDetailView(roleplay: roleplay, state: state)
            case .history:
                HistoryUsageView(state: state)
            case .favorites:
                FavoritesView(state: state)
            case .community:
                CommunityView(state: state)
            }
        }
    }

    private var quickActions: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            NavigationLink(value: FreeTalkRoute.createRoleplay) {
                MiniFlowCard(title: "Create roleplay", symbol: "plus.bubble.fill", color: .mintSuccess, asset: .customLesson)
            }
            NavigationLink(value: FreeTalkRoute.topics) {
                MiniFlowCard(title: "Topics", symbol: "square.grid.2x2.fill", color: .warmAmber, asset: .askInfo)
            }
            NavigationLink(value: FreeTalkRoute.history) {
                MiniFlowCard(title: "History", symbol: "clock.fill", color: .violetAccent, asset: .historyUsage)
            }
            NavigationLink(value: FreeTalkRoute.community) {
                MiniFlowCard(title: "Community", symbol: "person.3.fill", color: .primaryBlue, asset: .community)
            }
        }
        .buttonStyle(.plain)
    }
}

struct ReviewHomeView: View {
    @ObservedObject var state: LearningState

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    SectionHeader(title: "Review", subtitle: "Keep saved words and lines active.")
                    NavigationLink(value: ReviewRoute.smartReview) {
                        HeroActionCard(title: "Smart review", subtitle: "\(state.reviewItems.count) items ready", symbol: "bolt.circle.fill", color: .primaryBlue, asset: .review)
                    }
                    .buttonStyle(.plain)

                    NavigationLink(value: ReviewRoute.savedLinesReview) {
                        HeroActionCard(title: "Saved lines review", subtitle: "\(state.savedLines.count) lines from lessons and roleplays", symbol: "bookmark.circle.fill", color: .mintSuccess, asset: .savedLines)
                    }
                    .buttonStyle(.plain)

                    NavigationLink(value: ReviewRoute.reviewInfo) {
                        SettingsLikeRow(symbol: "info.circle.fill", title: "How review works", subtitle: "Listening mode, saved lines, and spaced practice", asset: .askInfo)
                    }
                    .buttonStyle(.plain)
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
                InfoDetailView(title: "Review information", subtitle: "Review mixes saved words, saved lines, and recent lesson mistakes. Listening mode hides the text first so you can train recognition before speaking.")
            }
        }
    }
}

struct RoleplaysHomeView: View {
    @ObservedObject var state: LearningState
    @State private var communityFirst = false

    var sortedRoleplays: [RoleplayScenario] {
        communityFirst ? state.roleplays.sorted { $0.isCommunity && !$1.isCommunity } : state.roleplays
    }

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    SectionHeader(title: "Roleplays", subtitle: "Generated lessons and community practice.")

                    Toggle("Community first", isOn: $communityFirst)
                        .padding(16)
                        .background(Color.claySurface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))

                    ForEach(sortedRoleplays) { roleplay in
                        NavigationLink(value: FreeTalkRoute.roleplay(roleplay)) {
                            RoleplayRow(roleplay: roleplay, favorite: state.isFavorite(roleplay))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(20)
            }
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 96)
            }
        }
        .navigationTitle("Roleplays")
        .navigationDestination(for: FreeTalkRoute.self) { route in
            switch route {
            case .roleplay(let roleplay), .communityRoleplay(let roleplay):
                RoleplayDetailView(roleplay: roleplay, state: state)
            case .community:
                CommunityView(state: state)
            case .favorites:
                FavoritesView(state: state)
            case .history:
                HistoryUsageView(state: state)
            case .topic(let topic):
                TopicDetailView(topic: topic, state: state)
            case .session:
                FreeTalkSessionView(state: state)
            case .createRoleplay:
                CreateRoleplayView(state: state)
            case .topics:
                TopicsBrowserView(state: state)
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
            case .settings:
                SettingsView(state: state)
            case .membership:
                InfoDetailView(title: "Manage membership", subtitle: "Membership is mocked for Phase 1. This screen is ready for server-backed plan status later.")
            case .editProfile:
                InfoDetailView(title: "Edit profile", subtitle: "Learner name, avatar, and language preferences will live here.")
            case .referrals:
                InfoDetailView(title: "Copy referral link", subtitle: "Share Converlax with a friend. Referral tracking is a placeholder in Phase 1.")
            case .notifications:
                NotificationPreferencesView(state: state)
            case .support:
                InfoDetailView(title: "Support center", subtitle: "Help, contact, issue reporting, and lesson feedback entry points.")
            case .appLanguage:
                InfoDetailView(title: "App language", subtitle: "Choose the language used by the app interface.")
            case .courseLanguage:
                LevelSelectionView(state: state)
            case .voiceRecognition:
                VoiceRecognitionSettingsView(state: state)
            case .login:
                InfoDetailView(title: "Log in", subtitle: "Authentication is mocked locally until backend requirements are defined.")
            case .resetPassword:
                InfoDetailView(title: "Reset password", subtitle: "Password reset will be connected when auth is added.")
            }
        }
    }

    private var profileHeader: some View {
        VStack(spacing: 12) {
            ConverlaxMascotView(state: .avatar, size: 92, isAnimated: false)
            Text("Learner")
                .font(.title2.weight(.bold))
            Text("\(state.profile.currentLevel.rawValue) \(state.profile.targetLanguage.rawValue)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    private var profileStats: some View {
        HStack(spacing: 12) {
            StatCard(value: "\(state.completedLessonCount)", label: "Lessons", color: .mintSuccess)
            StatCard(value: "\(state.savedLines.count)", label: "Saved lines", color: .primaryBlue)
            StatCard(value: "\(state.profile.streak)", label: "Streak", color: .warmAmber)
        }
    }

    private var profileLinks: some View {
        VStack(spacing: 0) {
            NavigationLink(value: ProfileRoute.savedLines) {
                SettingsLikeRow(symbol: "bookmark.fill", title: "Saved lines", subtitle: "\(state.savedLines.count) lines", asset: .savedLines)
            }
            Divider().padding(.leading, 56)
            NavigationLink(value: ProfileRoute.activities) {
                SettingsLikeRow(symbol: "list.bullet.rectangle.fill", title: "Activities", subtitle: "Recent learning events", asset: .activities)
            }
            Divider().padding(.leading, 56)
            NavigationLink(value: ProfileRoute.referrals) {
                SettingsLikeRow(symbol: "gift.fill", title: "Copy referral link", subtitle: "Invite friends", asset: .community)
            }
            Divider().padding(.leading, 56)
            NavigationLink(value: ProfileRoute.settings) {
                SettingsLikeRow(symbol: "gearshape.fill", title: "Settings", subtitle: "Membership, language, voice, support", asset: .settings)
            }
        }
        .buttonStyle(.plain)
        .background(Color.claySurface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
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
            Text("Finish one lesson or roleplay each day to keep your record active.")
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
            VStack(alignment: .leading, spacing: 18) {
                HeroActionCard(title: lesson.title, subtitle: lesson.subtitle, symbol: lesson.icon, color: lesson.accent.color, asset: lesson.visualAsset)
                NavigationLink(value: HomeRoute.lesson(lesson)) {
                    SettingsLikeRow(symbol: "play.fill", title: "Start lesson", subtitle: "\(lesson.minutes) minutes", asset: .freeTalk)
                }
                .buttonStyle(.plain)
                NavigationLink(value: HomeRoute.lessonLines(lesson)) {
                    SettingsLikeRow(symbol: "text.quote", title: "Lesson lines", subtitle: "\(lesson.savedWords.count) words and phrases", asset: .savedLines)
                }
                .buttonStyle(.plain)
                NavigationLink(value: HomeRoute.speakingDrill(lesson)) {
                    SettingsLikeRow(symbol: "mic.fill", title: "Speaking drill", subtitle: "Practice the core phrase", asset: .freeTalk)
                }
                .buttonStyle(.plain)
            }
            .padding(20)
        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle("Lesson detail")
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
        .navigationTitle("Lesson lines")
    }
}

private struct FreeTalkSessionView: View {
    @ObservedObject var state: LearningState
    @State private var finished = false
    @State private var summary: LearningSessionSummary?

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            LessonProgressBar(progress: finished ? 1 : 0.45)
            SectionHeader(title: finished ? "Session complete" : "Free Talk", subtitle: finished ? "Usage has been recorded." : "Answer the prompt naturally, then continue.")
            ConverlaxMascotView(state: finished ? .success : .listening, size: 116)
                .frame(maxWidth: .infinity)
            Text(finished ? "You practiced open conversation and saved a usage session." : "Tell me about your day using one sentence. Then ask me a question back.")
                .font(.title3.weight(.semibold))
                .padding(18)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.claySurface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            if let summary {
                SessionSummaryPanel(summary: summary)
            }
            Spacer()
            Button(finished ? "Practice again" : "End session") {
                if finished {
                    finished = false
                    summary = nil
                } else {
                    state.recordConversationSession(
                        title: "Free Talk",
                        detail: "Open speaking session",
                        minutes: 5,
                        transcript: "I usually study English at night. How about you?",
                        strongPhrases: ["How about you?", "I usually study English at night."],
                        weakPhrases: ["I study English in night."]
                    )
                    summary = state.sessionSummaries.first
                    finished = true
                }
            }
            .buttonStyle(PrimaryButtonStyle())
        }
        .padding(20)
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle("Free Talk")
    }
}

struct CreateRoleplayView: View {
    @ObservedObject var state: LearningState
    @State private var prompt = "Ordering coffee before a meeting"
    @State private var generated = false

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            SectionHeader(title: "Create roleplay", subtitle: "Describe the situation you want to practice.")
            ConverlaxAssetBadge(kind: generated ? .roleplay : .customLesson, size: 112)
                .frame(maxWidth: .infinity)
            TextField("Roleplay idea", text: $prompt, axis: .vertical)
                .padding(16)
                .background(Color.claySurface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            if generated, let roleplay = state.roleplays.first {
                RoleplayRow(roleplay: roleplay, favorite: state.isFavorite(roleplay))
            }
            Spacer()
            Button(generated ? "Regenerate" : "Generate roleplay") {
                generated = true
            }
            .buttonStyle(PrimaryButtonStyle())
        }
        .padding(20)
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle("Create")
    }
}

private struct TopicsBrowserView: View {
    @ObservedObject var state: LearningState

    var body: some View {
        List(state.roleplayTopics) { topic in
            NavigationLink(value: FreeTalkRoute.topic(topic)) {
                TopicRow(topic: topic)
            }
        }
        .navigationTitle("Topics")
    }
}

private struct TopicDetailView: View {
    let topic: RoleplayTopic
    @ObservedObject var state: LearningState

    var body: some View {
        List {
            Section(topic.subtitle) {
                ForEach(state.roleplays.filter { topic.scenarioIDs.contains($0.id) }) { roleplay in
                    NavigationLink(value: FreeTalkRoute.roleplay(roleplay)) {
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
                Button(state.isFavorite(roleplay) ? "Remove favorite" : "Add to favorites") {
                    state.toggleFavorite(roleplay)
                }
                .buttonStyle(SecondaryButtonStyle())
                Button(completed ? "Session recorded" : "Start roleplay") {
                    state.recordConversationSession(
                        title: roleplay.title,
                        detail: roleplay.setting,
                        minutes: roleplay.minutes,
                        transcript: roleplay.lines.map(\.text).joined(separator: " "),
                        strongPhrases: roleplay.lines.prefix(1).map(\.text),
                        weakPhrases: roleplay.lines.dropFirst().prefix(1).map(\.text)
                    )
                    summary = state.sessionSummaries.first
                    completed = true
                }
                .buttonStyle(PrimaryButtonStyle())
                if let summary {
                    SessionSummaryPanel(summary: summary)
                }
            }
            .padding(20)
        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle("Roleplay detail")
    }
}

private struct HistoryUsageView: View {
    @ObservedObject var state: LearningState

    var body: some View {
        List(state.usageSessions) { session in
            UsageRow(session: session)
        }
        .navigationTitle("History & usage")
    }
}

private struct FavoritesView: View {
    @ObservedObject var state: LearningState

    var body: some View {
        List {
            if state.favoriteRoleplays.isEmpty {
                Text("Favorite roleplays will appear here.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(state.favoriteRoleplays) { roleplay in
                    NavigationLink(value: FreeTalkRoute.roleplay(roleplay)) {
                        RoleplayRow(roleplay: roleplay, favorite: true)
                    }
                }
            }
        }
        .navigationTitle("Favorites")
    }
}

private struct CommunityView: View {
    @ObservedObject var state: LearningState
    @State private var sortPopularFirst = true

    var body: some View {
        List {
            Toggle("Popular first", isOn: $sortPopularFirst)
            ForEach(state.communityRoleplays) { roleplay in
                NavigationLink(value: FreeTalkRoute.communityRoleplay(roleplay)) {
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
        .navigationTitle("Smart review")
    }

    private func advanceReview() {
        index = min(index + 1, max(items.count - 1, 0))
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
        .navigationTitle("Saved lines review")
    }
}

private struct SavedLinesView: View {
    @ObservedObject var state: LearningState
    var searchable = false
    @State private var query = ""

    var filteredLines: [SavedLine] {
        guard !query.isEmpty else { return state.savedLines }
        return state.savedLines.filter { $0.text.localizedCaseInsensitiveContains(query) || $0.translation.localizedCaseInsensitiveContains(query) }
    }

    var body: some View {
        List {
            Section("Saved lines") {
                ForEach(filteredLines) { line in
                    SavedLineRow(line: line) {
                        state.removeLine(line)
                    }
                }
            }
            Section("Learning objects") {
                ForEach(state.savedLearningObjects) { object in
                    LearningObjectRow(object: object) {}
                }
            }
        }
        .searchable(text: $query)
        .navigationTitle(searchable ? "Search lines" : "Saved lines")
    }
}

private struct ActivitiesView: View {
    @ObservedObject var state: LearningState

    var body: some View {
        List(state.activities) { activity in
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
        .navigationTitle("Activities")
    }
}

private struct SettingsView: View {
    @ObservedObject var state: LearningState

    var body: some View {
        List {
            Section("Account") {
                NavigationLink(value: ProfileRoute.membership) { Label("Manage membership", systemImage: "creditcard.fill") }
                NavigationLink(value: ProfileRoute.editProfile) { Label("Edit profile", systemImage: "person.crop.circle.fill") }
                NavigationLink(value: ProfileRoute.login) { Label("Log in", systemImage: "person.badge.key.fill") }
                NavigationLink(value: ProfileRoute.resetPassword) { Label("Reset password", systemImage: "key.fill") }
            }
            Section("Learning") {
                Stepper("Daily goal: \(state.profile.dailyGoal) lessons", value: Binding(get: { state.profile.dailyGoal }, set: state.setDailyGoal), in: 1...6)
                NavigationLink(value: ProfileRoute.courseLanguage) { Label("Changing language course", systemImage: "globe") }
                NavigationLink(value: ProfileRoute.appLanguage) { Label("Changing app language", systemImage: "textformat") }
            }
            Section("Preferences") {
                Toggle("Sound effects", isOn: Binding(get: { state.profile.soundEnabled }, set: state.setSoundEnabled))
                Toggle("Haptics", isOn: Binding(get: { state.profile.hapticsEnabled }, set: state.setHapticsEnabled))
                NavigationLink(value: ProfileRoute.notifications) { Label("Notification preferences", systemImage: "bell.fill") }
                NavigationLink(value: ProfileRoute.voiceRecognition) { Label("Voice recognition", systemImage: "waveform") }
                NavigationLink(value: ProfileRoute.support) { Label("Support center", systemImage: "questionmark.circle.fill") }
            }
        }
        .navigationTitle("Settings")
    }
}

private struct NotificationPreferencesView: View {
    @ObservedObject var state: LearningState

    var body: some View {
        Form {
            Toggle("Practice reminders", isOn: Binding(get: { state.profile.notificationsEnabled }, set: state.setNotificationsEnabled))
            Text("Reminder scheduling is mocked for Phase 1.")
                .foregroundStyle(.secondary)
        }
        .navigationTitle("Notifications")
    }
}

private struct VoiceRecognitionSettingsView: View {
    @ObservedObject var state: LearningState

    var body: some View {
        Form {
            Toggle("Voice recognition", isOn: Binding(get: { state.profile.voiceRecognitionEnabled }, set: state.setVoiceRecognitionEnabled))
            Text("Voice recognition is a local placeholder until speech services are connected.")
                .foregroundStyle(.secondary)
        }
        .navigationTitle("Voice recognition")
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
                .font(.title2.weight(.bold))
            Text(subtitle)
                .font(.subheadline)
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
        HStack(spacing: 14) {
            if let asset {
                ConverlaxAssetBadge(kind: asset, size: 62)
            } else {
                AvatarBadge(symbol: symbol, color: color)
                    .frame(width: 54, height: 54)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.primary)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundStyle(.secondary)
        }
        .padding(18)
        .background(Color.claySurface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

private struct MiniFlowCard: View {
    let title: String
    let symbol: String
    let color: Color
    var asset: ConverlaxAssetKind? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let asset {
                ConverlaxAssetBadge(kind: asset, size: 52)
            } else {
                AvatarBadge(symbol: symbol, color: color)
                    .frame(width: 42, height: 42)
            }
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .frame(minHeight: 116)
        .background(Color.claySurface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
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
        HStack(spacing: 14) {
            ConverlaxAssetBadge(kind: roleplay.isCommunity ? .community : .roleplay, size: 52)
                .frame(width: 46, height: 46)
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(roleplay.title)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.primary)
                    if favorite {
                        Image(systemName: "star.fill")
                            .foregroundStyle(Color.warmAmber)
                    }
                }
                Text(roleplay.subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(roleplay.difficulty.code)
                .font(.caption.weight(.bold))
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .background(Color.claySurface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
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
        HStack(spacing: 14) {
            if let asset {
                ConverlaxAssetBadge(kind: asset, size: 48)
            } else {
                AvatarBadge(symbol: symbol, color: .primaryBlue)
                    .frame(width: 40, height: 40)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundStyle(.secondary)
        }
        .padding(14)
    }
}

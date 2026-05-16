import SwiftUI

struct PracticeHomeView: View {
    @ObservedObject var state: LearningState

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    SectionHeader(
                        title: "Start speaking",
                        subtitle: "Pick the shortest route into a spoken turn."
                    )

                    NavigationLink(value: PracticeRoute.session) {
                        HeroActionCard(title: "Start speaking", subtitle: "Speak once, get feedback, save what matters", symbol: "mic.circle.fill", color: .primaryBlue, asset: .freeTalk)
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("practice-start-speaking")

                    chooseSituationAction
                    practiceTools
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

    private var chooseSituationAction: some View {
        NavigationLink(value: PracticeRoute.topics) {
            PracticeSecondaryRow(symbol: "person.2.wave.2.fill", title: "Choose a situation", subtitle: "Roleplay a real-world moment")
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("practice-choose-situation")
    }

    private var practiceTools: some View {
        HStack(spacing: 12) {
            NavigationLink(value: PracticeRoute.createRoleplay) {
                PracticeToolButton(title: "Custom practice", symbol: "plus.bubble.fill", color: .warmAmber)
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("practice-create-custom")

            NavigationLink(value: PracticeRoute.tutor) {
                PracticeToolButton(title: "Get a line to say", symbol: "bubble.left.and.bubble.right.fill", color: .primaryBlue)
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("practice-tutor")
        }
    }
}

struct ReviewHomeView: View {
    @ObservedObject var state: LearningState

    private var reviewCount: Int {
        state.reviewItems.count
    }

    private var personalSavedLineCount: Int {
        state.profile.savedLines.count
    }

    private var primaryReviewRoute: ReviewRoute {
        if reviewCount > 0 {
            return .smartReview
        }

        return personalSavedLineCount > 0 ? .savedLinesReview : .startLesson
    }

    private var primaryReviewTitle: String {
        if reviewCount > 0 {
            return "Review due items"
        }

        return personalSavedLineCount > 0 ? "Practice saved lines" : "Start a lesson"
    }

    private var primaryReviewSubtitle: String {
        if reviewCount > 0 {
            return "\(reviewCount) ready from saved content and practice"
        }

        return personalSavedLineCount > 0 ? "No review due right now" : "Create something to review later"
    }

    private var savedLinesSubtitle: String {
        "\(personalSavedLineCount) saved \(personalSavedLineCount == 1 ? "line" : "lines")"
    }

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    SectionHeader(
                        title: reviewCount == 0 ? "Review is clear" : "Due today",
                        subtitle: nil
                    )
                    NavigationLink(value: primaryReviewRoute) {
                        HeroActionCard(
                            title: primaryReviewTitle,
                            subtitle: primaryReviewSubtitle,
                            symbol: "bolt.circle.fill",
                            color: .primaryBlue,
                            asset: .review
                        )
                    }
                    .buttonStyle(.plain)

                    if reviewCount > 0 && personalSavedLineCount > 0 {
                        NavigationLink(value: ReviewRoute.savedLinesReview) {
                            SettingsLikeRow(symbol: "bookmark.fill", title: "Review saved lines", subtitle: savedLinesSubtitle)
                        }
                        .buttonStyle(.plain)
                        .background(Color.claySurface.opacity(0.68), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(Color.clayStroke.opacity(0.66), lineWidth: 1)
                        )
                    }
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
                InfoDetailView(title: "How review works", subtitle: "Saved words, saved lines, and recent mistakes come back when they are ready to practice.")
            case .startLesson:
                LessonPlayerView(lesson: state.currentLesson, state: state)
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
                VStack {
                    journeyDashboard
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
                InfoDetailView(title: "Membership", subtitle: "Review plan, billing, and renewal details.")
            case .editProfile:
                InfoDetailView(title: "Learner profile", subtitle: "Manage your learner name, avatar, and course identity.")
            case .referrals:
                InfoDetailView(title: "Invite a friend", subtitle: "Share Converlax with someone who wants speaking practice.")
            case .notifications:
                NotificationPreferencesView(state: state)
            case .support:
                InfoDetailView(title: "Get support", subtitle: "Find help, report an issue, or send lesson feedback.")
            case .appLanguage:
                InfoDetailView(title: "App language", subtitle: "Choose the interface language for menus and settings.")
            case .courseLanguage:
                LevelSelectionView(state: state)
            case .voiceRecognition:
                VoiceRecognitionSettingsView(state: state)
            case .login:
                InfoDetailView(title: "Log in", subtitle: "Sign in to sync lessons, saved lines, and practice history.")
            case .resetPassword:
                InfoDetailView(title: "Reset password", subtitle: "Update the password for your Converlax account.")
            }
        }
    }

    private var journeyDashboard: some View {
        VStack(alignment: .leading, spacing: 18) {
            SectionHeader(
                title: "Your journey"
            )
            journeyProgressPanel
            recentJourneyPanel
            journeyNavigation
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var journeyProgressPanel: some View {
        let progress = state.journeyProgress

        return VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .center, spacing: 14) {
                ConverlaxMascotView(state: .avatar, size: 66, isAnimated: false)

                VStack(alignment: .leading, spacing: 5) {
                    Text("Level \(progress.levelNumber) · \(progress.currentTitle)")
                        .font(.title3.weight(.bold))
                        .lineLimit(2)
                        .minimumScaleFactor(0.82)
                    Text("\(state.profile.currentLevel.rawValue) \(state.profile.targetLanguage.rawValue) learner")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: 0)
            }

            VStack(alignment: .leading, spacing: 9) {
                LessonProgressBar(progress: progress.levelProgress)

                Text("\(progress.xpInCurrentLevel) XP earned in this level")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.primaryBlue)
            }
        }
        .padding(16)
        .background(Color.claySurface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.clayStroke.opacity(0.75), lineWidth: 1)
        )
    }

    private var recentJourneyPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent journey")
                .font(.headline.weight(.semibold))

            if recentJourneyItems.isEmpty {
                Text("No accomplishments yet.")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 54, alignment: .leading)
                    .padding(.horizontal, 14)
                    .background(Color.claySurface.opacity(0.74), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(Color.clayStroke.opacity(0.66), lineWidth: 1)
                    )
            } else {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(recentJourneyItems) { item in
                        JourneyRecentRow(item: item)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 4)
                .background(Color.claySurface.opacity(0.74), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.clayStroke.opacity(0.66), lineWidth: 1)
                )
            }
        }
        .padding(.top, 0)
    }

    private var journeyNavigation: some View {
        VStack(spacing: 0) {
            NavigationLink(value: ProfileRoute.savedLines) {
                JourneyNavigationRow(asset: .savedLines, title: "Saved content", detail: "\(personalSavedContentCount) personal items")
            }

            Divider().padding(.leading, 58)

            NavigationLink(value: ProfileRoute.practiceHistory) {
                JourneyNavigationRow(asset: .historyUsage, title: "Practice history", detail: "\(state.profile.usageSessions.count) sessions")
            }

            Divider().padding(.leading, 58)

            NavigationLink(value: ProfileRoute.settings) {
                JourneyNavigationRow(asset: .settings, title: "Settings", detail: "Goal, voice, course")
            }
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 14)
        .background(Color.claySurface.opacity(0.72), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.clayStroke.opacity(0.62), lineWidth: 1)
        )
    }

    private var personalSavedContentCount: Int {
        state.profile.savedWords.count + state.profile.savedLines.count + state.profile.savedLearningObjects.count + state.profile.favoriteRoleplayIDs.count
    }

    private var recentJourneyItems: [AchievementTimelineItem] {
        let completedLessonActivity = state.profile.activities.first { activity in
            activity.id.hasPrefix("lesson-") || activity.symbol == "checkmark.seal.fill"
        }
        let savedPhrase = state.profile.savedLearningObjects.first { object in
            object.kind == .line || object.kind == .phrase || object.kind == .roleplayPhrase || object.kind == .tutorMessage
        }
        let savedLine = state.profile.savedLines.first
        let savedWord = state.profile.savedWords.first
        let speakingSummary = state.profile.sessionSummaries.first { summary in
            summary.id.hasPrefix("summary-usage-session-") || summary.title.localizedCaseInsensitiveContains("Free Talk")
        }
        let speakingSession = state.profile.usageSessions.first

        var items: [AchievementTimelineItem] = []

        if state.completedLessonCount > 0 {
            items.append(AchievementTimelineItem(
                id: "completed-lesson",
                title: "Completed lesson",
                detail: completedLessonActivity?.title ?? completedLessonFallbackDetail,
                dateLabel: completedLessonActivity?.dateLabel ?? "Done",
                symbol: "checkmark.seal.fill",
                color: .mintSuccess,
                isComplete: true
            ))
        }

        if let savedPhrase {
            items.append(AchievementTimelineItem(
                id: "saved-phrase",
                title: "Saved phrase",
                detail: savedPhrase.text,
                dateLabel: "Saved",
                symbol: "bookmark.fill",
                color: .warmAmber,
                isComplete: true
            ))
        } else if let savedLine {
            items.append(AchievementTimelineItem(
                id: "saved-phrase",
                title: "Saved phrase",
                detail: savedLine.text,
                dateLabel: "Saved",
                symbol: "bookmark.fill",
                color: .warmAmber,
                isComplete: true
            ))
        } else if let savedWord {
            items.append(AchievementTimelineItem(
                id: "saved-phrase",
                title: "Saved phrase",
                detail: savedWord.term,
                dateLabel: "Saved",
                symbol: "bookmark.fill",
                color: .warmAmber,
                isComplete: true
            ))
        }

        if let speakingSummary {
            items.append(AchievementTimelineItem(
                id: "practiced-speaking",
                title: "Practiced speaking",
                detail: speakingSummary.title,
                dateLabel: speakingSummary.dateLabel,
                symbol: "mic.fill",
                color: .primaryBlue,
                isComplete: true
            ))
        } else if let speakingSession {
            items.append(AchievementTimelineItem(
                id: "practiced-speaking",
                title: "Practiced speaking",
                detail: speakingSession.title,
                dateLabel: speakingSession.dateLabel,
                symbol: "mic.fill",
                color: .primaryBlue,
                isComplete: true
            ))
        }

        return Array(items.prefix(3))
    }

    private var completedLessonFallbackDetail: String {
        guard state.completedLessonCount > 0 else {
            return "Finish a course lesson to mark this step."
        }

        return "\(state.completedLessonCount) completed \(state.completedLessonCount == 1 ? "lesson" : "lessons")"
    }
}

private struct AchievementTimelineItem: Identifiable {
    let id: String
    let title: String
    let detail: String
    let dateLabel: String
    let symbol: String
    let color: Color
    let isComplete: Bool
}

private struct JourneyRecentRow: View {
    let item: AchievementTimelineItem

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: item.symbol)
                .font(.caption.weight(.bold))
                .foregroundStyle(iconColor)
                .frame(width: 28, height: 28)
                .background(iconColor.opacity(item.isComplete ? 0.12 : 0.08), in: Circle())
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 3) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(item.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.converlaxInk)

                    Spacer(minLength: 6)

                    Text(item.dateLabel)
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(iconColor)
                }

                Text(item.detail)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.vertical, 5)
        .accessibilityElement(children: .combine)
    }

    private var iconColor: Color {
        item.isComplete ? item.color : .secondary
    }
}

private struct JourneyNavigationRow: View {
    let asset: ConverlaxAssetKind
    let title: String
    let detail: String

    var body: some View {
        HStack(spacing: 12) {
            ConverlaxAssetBadge(kind: asset, size: 42)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)
        }
        .padding(.vertical, 10)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
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
        .padding(16)
        .background(Color.claySurface, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
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
        .padding(14)
        .background(Color.claySurface.opacity(0.72), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
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
            .background(Color.claySurface, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
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
    @State private var speechPhase: SpeechPracticePhase = .ready
    @State private var transcript = ""
    @State private var speechErrorMessage: String?
    @StateObject private var speechRecognizer = SpeechRecognitionService()
    @State private var completionResult: CompletionCelebrationResult?

    private let prompt = "Tell me about your day using one sentence. Then ask me a question back."

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    if finished, let completionResult {
                        CompletionCelebrationView(result: completionResult)
                    } else {
                        LessonProgressBar(progress: 0.45)
                        SectionHeader(title: "Answer one prompt", subtitle: "Speak naturally, then save the session.")
                        Text(prompt)
                            .font(.title3.weight(.semibold))
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.claySurface, in: RoundedRectangle(cornerRadius: 14, style: .continuous))

                        SpeechPracticePanel(
                            phase: speechPhase,
                            transcript: transcript,
                            feedback: nil,
                            accent: .primaryBlue,
                            errorMessage: speechErrorMessage,
                            onPrimary: handlePrimaryAction,
                            onCancel: cancelSpeech
                        )
                    }

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

            if finished {
                Button("Practice again") {
                    resetSession()
                }
                .buttonStyle(PrimaryButtonStyle())
                .accessibilityIdentifier("free-talk-primary-action")
            }
        }
        .padding(20)
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle("Free Talk")
        .toolbar(.hidden, for: .tabBar)
        .accessibilityIdentifier("free-talk-session")
        .onChange(of: speechRecognizer.transcript) { _, newValue in
            transcript = newValue
        }
        .onDisappear {
            speechRecognizer.cancelRecording()
        }
    }

    private func handlePrimaryAction() {
        switch speechPhase {
        case .permissionNeeded, .permissionDenied, .ready, .paused, .noSpeech, .error:
            startSpeechRecording()
        case .recording:
            finishSpeechRecording()
        case .requestingPermission, .processing, .transcribing:
            break
        case .transcript:
            saveSession()
        case .feedback, .accepted:
            resetSession()
        }
    }

    private func startSpeechRecording() {
        speechPhase = .requestingPermission
        transcript = ""
        feedback = nil
        summary = nil
        speechErrorMessage = nil

        Task {
            let started = await speechRecognizer.startRecording()
            if started {
                speechPhase = .recording
            } else {
                speechErrorMessage = speechRecognizer.errorMessage
                speechPhase = speechRecognizer.errorMessage?.localizedCaseInsensitiveContains("permission") == true ? .permissionDenied : .error
            }
        }
    }

    private func finishSpeechRecording() {
        speechPhase = .transcribing
        let capturedTranscript = speechRecognizer.stopRecording()
        transcript = capturedTranscript

        guard !capturedTranscript.isEmpty else {
            speechErrorMessage = "No clear speech was captured. Try again a little slower and closer to the mic."
            speechPhase = .noSpeech
            return
        }

        speechPhase = .transcript
    }

    private func saveSession() {
        let previousProfile = state.profile
        let result = state.recordConversationSession(
            title: "Free Talk",
            detail: "Open speaking session",
            minutes: 5,
            transcript: transcript,
            strongPhrases: strongPhrases(from: transcript),
            weakPhrases: weakPhrases(from: transcript),
            prompt: prompt
        )
        summary = result.summary
        feedback = result.feedback
        completionResult = state.completionCelebration(
            from: previousProfile,
            title: "Free Talk complete",
            subtitle: "You finished an open speaking session.",
            nextActionTitle: result.summary.nextRecommendation,
            nextActionDetail: "Saved under Practice history."
        )
        speechPhase = .accepted
        finished = true
    }

    private func cancelSpeech() {
        speechRecognizer.cancelRecording()
        speechPhase = .ready
        transcript = ""
        speechErrorMessage = nil
    }

    private func resetSession() {
        speechRecognizer.cancelRecording()
        finished = false
        summary = nil
        feedback = nil
        completionResult = nil
        speechPhase = .ready
        transcript = ""
        speechErrorMessage = nil
    }

    private func strongPhrases(from transcript: String) -> [String] {
        let sentences = transcript.split(whereSeparator: { ".?!".contains($0) }).map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
        return Array(sentences.filter { !$0.isEmpty }.prefix(2))
    }

    private func weakPhrases(from transcript: String) -> [String] {
        transcript.split(separator: " ").count < 5 ? [transcript] : []
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
        .background(Color.claySurface.opacity(0.72), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
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
            ConverlaxAssetBadge(kind: generated ? .roleplay : .customLesson, size: 82)
                .frame(maxWidth: .infinity)
            TextField("Situation to practice", text: $prompt, axis: .vertical)
                .padding(16)
                .background(Color.claySurface, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
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
    case all = "Recommended"
    case topics = "Topics"
    case favorites = "Saved"
    case community = "Community"

    var id: String { rawValue }

    var emptyTitle: String {
        switch self {
        case .all:
            "No recommended situations"
        case .topics:
            "No topics"
        case .favorites:
            "No saved situations yet"
        case .community:
            "No community situations"
        }
    }

    var emptyDescription: String {
        switch self {
        case .all:
            "New situations will appear here."
        case .topics:
            "Situation topics will appear here."
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
                    SectionHeader(title: "Choose a situation", subtitle: "Pick a recommended scenario or browse by topic.")

                    SituationFilterBar(selection: $filter)
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

private struct SituationFilterBar: View {
    @Binding var selection: SituationFilter

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(SituationFilter.allCases) { filter in
                    Button {
                        selection = filter
                    } label: {
                        Text(filter.rawValue)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(selection == filter ? Color.primaryBlue : Color.converlaxInk.opacity(0.72))
                            .padding(.horizontal, 11)
                            .frame(height: 32)
                            .background(selection == filter ? Color.primaryBlue.opacity(0.1) : Color.claySurface.opacity(0.48), in: Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(selection == filter ? Color.primaryBlue.opacity(0.26) : Color.clayStroke.opacity(0.52), lineWidth: 1)
                            )
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
    @State private var speechPhase: SpeechPracticePhase = .ready
    @State private var transcript = ""
    @State private var speechErrorMessage: String?
    @StateObject private var speechRecognizer = SpeechRecognitionService()
    @State private var completionResult: CompletionCelebrationResult?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                HeroActionCard(title: roleplay.title, subtitle: roleplay.subtitle, symbol: roleplay.isCommunity ? "person.3.fill" : "person.2.wave.2.fill", color: roleplay.isCommunity ? .violetAccent : .primaryBlue, asset: roleplay.isCommunity ? .community : .roleplay)

                if completed, let completionResult {
                    CompletionCelebrationView(result: completionResult)

                    Button("Practice again") {
                        resetSession()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .accessibilityIdentifier("roleplay-primary-action")
                } else {
                    RoleplayConversationPrompt(roleplay: roleplay)

                    SpeechPracticePanel(
                        phase: speechPhase,
                        transcript: transcript,
                        feedback: nil,
                        accent: .primaryBlue,
                        errorMessage: speechErrorMessage,
                        onPrimary: handlePrimaryAction,
                        onCancel: cancelSpeech
                    )
                    .accessibilityIdentifier("roleplay-primary-action")
                }

                HStack(spacing: 12) {
                    StatCard(value: "\(roleplay.minutes)", label: "Minutes", color: .primaryBlue)
                    StatCard(value: roleplay.difficulty.code, label: "Level", color: .warmAmber)
                }

                if let feedback {
                    LearningFeedbackCard(feedback: feedback)
                }
                if let summary {
                    SessionSummaryPanel(summary: summary)
                }
                if completed {
                    PracticeSavedHint()
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Useful lines")
                        .font(.headline.weight(.semibold))

                    ForEach(roleplay.lines) { line in
                        SavedLineRow(line: line) {
                            state.saveLine(line)
                        }
                    }

                    Button(state.isFavorite(roleplay) ? "Remove saved situation" : "Save situation") {
                        state.toggleFavorite(roleplay)
                    }
                    .buttonStyle(SecondaryButtonStyle())
                }
            }
            .padding(20)
        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle("Situation")
        .toolbar(.hidden, for: .tabBar)
        .accessibilityIdentifier("roleplay-detail")
        .onChange(of: speechRecognizer.transcript) { _, newValue in
            transcript = newValue
        }
        .onDisappear {
            speechRecognizer.cancelRecording()
        }
    }

    private func handlePrimaryAction() {
        switch speechPhase {
        case .permissionNeeded, .permissionDenied, .ready, .paused, .noSpeech, .error:
            startSpeechRecording()
        case .recording:
            finishSpeechRecording()
        case .requestingPermission, .processing, .transcribing:
            break
        case .transcript:
            saveSession()
        case .feedback, .accepted:
            resetSession()
        }
    }

    private func startSpeechRecording() {
        speechPhase = .requestingPermission
        transcript = ""
        feedback = nil
        summary = nil
        speechErrorMessage = nil

        Task {
            let started = await speechRecognizer.startRecording()
            if started {
                speechPhase = .recording
            } else {
                speechErrorMessage = speechRecognizer.errorMessage
                speechPhase = speechRecognizer.errorMessage?.localizedCaseInsensitiveContains("permission") == true ? .permissionDenied : .error
            }
        }
    }

    private func finishSpeechRecording() {
        speechPhase = .transcribing
        let capturedTranscript = speechRecognizer.stopRecording()
        transcript = capturedTranscript

        guard !capturedTranscript.isEmpty else {
            speechErrorMessage = "No clear speech was captured. Try again a little slower and closer to the mic."
            speechPhase = .noSpeech
            return
        }

        speechPhase = .transcript
    }

    private func saveSession() {
        let previousProfile = state.profile
        let result = state.recordConversationSession(
            title: roleplay.title,
            detail: roleplay.setting,
            minutes: roleplay.minutes,
            transcript: transcript,
            strongPhrases: matchingRoleplayLines(in: transcript),
            weakPhrases: [],
            prompt: "Roleplay at \(roleplay.setting): \(roleplay.subtitle)"
        )
        summary = result.summary
        feedback = result.feedback
        completionResult = state.completionCelebration(
            from: previousProfile,
            title: "Situation complete",
            subtitle: "You finished \(roleplay.title.lowercased()).",
            nextActionTitle: result.summary.nextRecommendation,
            nextActionDetail: "Saved under Practice history."
        )
        speechPhase = .accepted
        completed = true
    }

    private func cancelSpeech() {
        speechRecognizer.cancelRecording()
        speechPhase = .ready
        transcript = ""
        speechErrorMessage = nil
    }

    private func resetSession() {
        speechRecognizer.cancelRecording()
        completed = false
        summary = nil
        feedback = nil
        completionResult = nil
        speechPhase = .ready
        transcript = ""
        speechErrorMessage = nil
    }

    private func matchingRoleplayLines(in transcript: String) -> [String] {
        let lowercasedTranscript = transcript.lowercased()
        let matches = roleplay.lines.map(\.text).filter { line in
            lowercasedTranscript.contains(line.lowercased())
        }
        return matches.isEmpty ? Array(roleplay.lines.prefix(1).map(\.text)) : Array(matches.prefix(2))
    }
}

private struct RoleplayConversationPrompt: View {
    let roleplay: RoleplayScenario

    private var starterLine: SavedLine? {
        roleplay.lines.first
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                ConverlaxMascotView(state: .avatar, size: 42, isAnimated: false)

                VStack(alignment: .leading, spacing: 3) {
                    Text(roleplay.setting)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color.primaryBlue)
                    Text(roleplay.subtitle)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            RoleplayBubble(
                title: "Prompt",
                text: "You are at \(roleplay.setting.lowercased()). \(roleplay.subtitle).",
                color: .claySurface
            )

            if let starterLine {
                RoleplayBubble(title: "Your turn", text: starterLine.text, color: Color.primaryBlue.opacity(0.1))
            }
        }
        .padding(16)
        .background(Color.claySurface.opacity(0.72), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.clayStroke.opacity(0.82), lineWidth: 1)
        )
    }
}

private struct RoleplayBubble: View {
    let title: String
    let text: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.caption.weight(.bold))
                .foregroundStyle(.secondary)
            Text(text)
                .font(.subheadline.weight(.semibold))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(color, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
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
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var state: LearningState
    @State private var index = 0
    @State private var showAnswer = false
    @State private var didCompleteReview = false

    var items: [ScheduledReviewItem] {
        state.dueReviewItems
    }

    var item: ScheduledReviewItem {
        items[index % max(items.count, 1)]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            if didCompleteReview {
                ReviewCompletionResultView {
                    dismiss()
                }
            } else if items.isEmpty {
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
                Text(item.prompt)
                    .font(.title3.weight(.semibold))
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.claySurface, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                if showAnswer {
                    Text(item.answer)
                        .font(.headline)
                        .foregroundStyle(Color.mintSuccess)
                }
                Spacer()
                if showAnswer {
                    HStack(spacing: 12) {
                        Button("Need practice") {
                            recordCurrentReview(remembered: false)
                        }
                        .buttonStyle(SecondaryButtonStyle())
                        Button("Remembered") {
                            recordCurrentReview(remembered: true)
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

    private func recordCurrentReview(remembered: Bool) {
        state.recordReview(item, remembered: remembered)

        if state.dueReviewItems.isEmpty {
            didCompleteReview = true
            showAnswer = false
        } else {
            advanceReview()
        }
    }

    private func advanceReview() {
        index = min(index, max(items.count - 1, 0))
        showAnswer = false
    }
}

private struct ReviewCompletionResultView: View {
    let onDone: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Spacer(minLength: 0)

            VStack(alignment: .leading, spacing: 16) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.title.weight(.bold))
                    .foregroundStyle(Color.mintSuccess)

                VStack(alignment: .leading, spacing: 6) {
                    Text("Review complete")
                        .font(.title2.weight(.bold))
                }

                HStack(spacing: 10) {
                    Label("+XP", systemImage: "sparkles")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.warmAmber)

                    Label("Review accuracy improved", systemImage: "chart.line.uptrend.xyaxis")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.primaryBlue)
                }
                .labelStyle(.titleAndIcon)
                .fixedSize(horizontal: false, vertical: true)
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.claySurface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.clayStroke.opacity(0.72), lineWidth: 1)
            )

            Button("Back to Review") {
                onDone()
            }
            .buttonStyle(PrimaryButtonStyle())

            Spacer(minLength: 0)
        }
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
                    status: "Language"
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
                    detail: "Plan and billing details.",
                    status: "Account"
                )
                SettingsStatusRow(
                    symbol: "person.crop.circle.fill",
                    title: "Edit profile",
                    detail: "Learner name, avatar, and course identity.",
                    status: "Profile"
                )
                SettingsStatusRow(
                    symbol: "person.badge.key.fill",
                    title: "Sign in",
                    detail: "Sync lessons, saved lines, and practice history.",
                    status: "Sync"
                )
            }
            Section("Sharing") {
                SettingsStatusRow(
                    symbol: "gift.fill",
                    title: "Invite a friend",
                    detail: "Share Converlax with another learner.",
                    status: "Share"
                )
            }
            Section("Support") {
                SettingsStatusRow(
                    symbol: "questionmark.circle.fill",
                    title: "Get support",
                    detail: "Find help, report an issue, or send lesson feedback.",
                    status: "Help"
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
        .background(Color.claySurface, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
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
            Text("Choose whether Converlax should remind you to practice.")
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
            Text("Speech recognition uses your microphone and Apple's speech recognition to transcribe practice audio.")
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
    var subtitle: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.headline.weight(.bold))
                .foregroundStyle(Color.converlaxInk)
            if let subtitle {
                Text(subtitle)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
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
                ConverlaxAssetBadge(kind: asset, size: 58)
            } else {
                AvatarBadge(symbol: symbol, color: color)
                    .frame(width: 48, height: 48)
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
        .frame(maxWidth: .infinity, minHeight: 92, alignment: .leading)
        .padding(16)
        .background(color.opacity(0.09), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(color.opacity(0.2), lineWidth: 1)
        )
        .contentShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
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
        SettingsLikeRow(symbol: topic.symbol, title: topic.title, subtitle: topic.subtitle, color: topic.colorName.color)
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
        .background(Color.claySurface.opacity(0.62), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.clayStroke.opacity(0.65), lineWidth: 1)
        )
        .contentShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
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
    var color: Color = .primaryBlue

    var body: some View {
        HStack(spacing: 12) {
            AvatarBadge(symbol: symbol, color: color)
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

private struct PracticeSecondaryRow: View {
    let symbol: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: symbol)
                .font(.footnote.weight(.bold))
                .foregroundStyle(Color.primaryBlue)
                .frame(width: 28, height: 28)
                .background(Color.primaryBlue.opacity(0.09), in: RoundedRectangle(cornerRadius: 8, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary.opacity(0.72))
        }
        .frame(minHeight: 44)
        .padding(.horizontal, 4)
        .padding(.vertical, 2)
        .contentShape(Rectangle())
    }
}

private struct PracticeToolButton: View {
    let title: String
    let symbol: String
    let color: Color

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: symbol)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(color)
                .frame(width: 30, height: 30)
                .background(color.opacity(0.1), in: RoundedRectangle(cornerRadius: 9, style: .continuous))

            Text(title)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.primary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, minHeight: 54, alignment: .leading)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color.claySurface.opacity(0.58), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.clayStroke.opacity(0.58), lineWidth: 1)
        )
        .contentShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

import SwiftUI

struct OnboardingView: View {
    @ObservedObject var state: LearningState
    @State private var targetLanguage: TargetLanguage = .french
    @State private var selectedLevel: Level = .beginner
    @State private var dailyGoal = 2
    @State private var textMode = false
    @State private var reminderEnabled = true
    @State private var step = 0

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 18) {
                header
                LessonProgressBar(progress: Double(step + 1) / 4)
                titleBlock
                ConverlaxMascotView(state: mascotState, size: step == 0 ? 116 : 88)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, step == 0 ? 2 : -4)

                if step == 0 {
                    introCards
                } else if step == 1 {
                    languageChoices
                } else if step == 2 {
                    levelChoices
                } else {
                    preferenceChoices
                }

                Spacer()

                Button(action: continueFlow) {
                    Text(step == 3 ? "Start learning" : "Continue")
                }
                .buttonStyle(PrimaryButtonStyle())
            }
            .padding(22)
        }
    }

    private var header: some View {
        HStack {
            ConverlaxMascotView(state: .avatar, size: 48, isAnimated: false)
            Spacer()
            Text("Converlax")
                .font(.headline.weight(.bold))
                .foregroundStyle(.secondary)
        }
    }

    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.title.weight(.bold))
                .fixedSize(horizontal: false, vertical: true)
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var title: String {
        switch step {
        case 0: "Speak with confidence"
        case 1: "What do you want to learn?"
        case 2: "Where should we start?"
        default: "Tune your practice"
        }
    }

    private var subtitle: String {
        switch step {
        case 0: "Build lessons, tutor chats, roleplays, and saved-line review around real conversation."
        case 1: "Pick your target language. The first complete beginner unit is ready to practice."
        case 2: "Choose the level that best matches your current speaking comfort."
        default: "Choose how Converlax should guide your daily speaking sessions."
        }
    }

    private var mascotState: ConverlaxMascotState {
        switch step {
        case 0: .waving
        case 1: .encouraging
        case 2: .thinking
        default: .idle
        }
    }

    private var introCards: some View {
        VStack(spacing: 12) {
            OnboardingFeatureRow(asset: .freeTalk, symbol: "waveform", title: "Practice out loud", subtitle: "Lessons focus on useful lines, short answers, and speaking rhythm.")
            OnboardingFeatureRow(asset: .customLesson, symbol: "sparkles", title: "Chat with a tutor", subtitle: "Ask for phrases, save replies, and review them later.")
            OnboardingFeatureRow(asset: .roleplay, symbol: "person.2.wave.2.fill", title: "Roleplay real moments", subtitle: "Create or choose scenarios like cafes, travel, and work.")
        }
    }

    private var languageChoices: some View {
        VStack(spacing: 12) {
            ForEach(TargetLanguage.allCases) { language in
                ChoiceRow(
                    title: language.rawValue,
                    subtitle: subtitle(for: language),
                    selected: targetLanguage == language,
                    enabled: language.isAvailable
                ) {
                    targetLanguage = language
                }
            }
        }
    }

    private var levelChoices: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Part 1")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    ForEach([Level.beginner, .elementary]) { level in
                        levelButton(level)
                    }
                }
                VStack(alignment: .leading, spacing: 12) {
                    Text("Part 2")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    ForEach([Level.upperElementary, .intermediate]) { level in
                        levelButton(level)
                    }
                }
            }
        }
    }

    private var preferenceChoices: some View {
        VStack(alignment: .leading, spacing: 16) {
            Stepper("Daily goal: \(dailyGoal) lessons", value: $dailyGoal, in: 1...6)
                .padding(16)
                .background(Color.claySurface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))

            Toggle("Use text mode when voice is unavailable", isOn: $textMode)
                .padding(16)
                .background(Color.claySurface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))

            Toggle("Practice reminders", isOn: $reminderEnabled)
                .padding(16)
                .background(Color.claySurface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))

            VStack(alignment: .leading, spacing: 6) {
                Text("No subscription required for Phase 1")
                    .font(.headline.weight(.semibold))
                Text("Membership, login, and billing screens are mocked later in Profile.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(16)
            .background(Color.claySurface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }

    private func levelButton(_ level: Level) -> some View {
        Button {
            selectedLevel = level
        } label: {
            LevelCard(level: level, selected: selectedLevel == level)
        }
        .buttonStyle(.plain)
    }

    private func continueFlow() {
        if step < 3 {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.86)) {
                step += 1
            }
        } else {
            state.completeOnboarding(language: targetLanguage, level: selectedLevel)
            state.setDailyGoal(dailyGoal)
            state.setVoiceRecognitionEnabled(!textMode)
            state.setNotificationsEnabled(reminderEnabled)
        }
    }

    private func subtitle(for language: TargetLanguage) -> String {
        guard language.isAvailable else { return "Coming soon" }
        return "\(language.unitTitle) available now"
    }
}

private struct OnboardingFeatureRow: View {
    let asset: ConverlaxAssetKind?
    let symbol: String
    let title: String
    let subtitle: String

    init(asset: ConverlaxAssetKind? = nil, symbol: String, title: String, subtitle: String) {
        self.asset = asset
        self.symbol = symbol
        self.title = title
        self.subtitle = subtitle
    }

    var body: some View {
        HStack(spacing: 14) {
            if let asset {
                ConverlaxAssetBadge(kind: asset, size: 52)
            } else {
                AvatarBadge(symbol: symbol, color: .primaryBlue)
                    .frame(width: 46, height: 46)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline.weight(.semibold))
                Text(subtitle)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
        .padding(16)
        .background(Color.claySurface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

struct ChoiceRow: View {
    let title: String
    let subtitle: String
    let selected: Bool
    var enabled = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(selected ? Color.primaryBlue : Color.secondary)

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.primary)
                    Text(subtitle)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }
            .padding(16)
            .background(Color.claySurface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(selected ? Color.primaryBlue : Color.clayStroke, lineWidth: selected ? 2 : 1)
            )
            .opacity(enabled ? 1 : 0.55)
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
        .accessibilityHint(enabled ? "" : "This course is not available yet.")
    }
}

struct LevelSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var state: LearningState
    @State private var pendingLevel: Level?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    levelSection(title: "Part 1", subtitle: "Beginner foundations", levels: [.beginner, .elementary])
                    levelSection(title: "Part 2", subtitle: "Confident everyday conversation", levels: [.upperElementary, .intermediate])
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Changing level updates the course destination.")
                            .font(.headline.weight(.semibold))
                        Text("Completed progress stays saved, but the Home path will move to lessons that match the selected level.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(16)
                    .background(Color.claySurface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .padding(20)
            }
            .background(Color.appBackground.ignoresSafeArea())
            .navigationTitle("Select your level")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .accessibilityLabel("Close")
                }
            }
            .confirmationDialog(
                "Change level?",
                isPresented: Binding(
                    get: { pendingLevel != nil },
                    set: { if !$0 { pendingLevel = nil } }
                ),
                titleVisibility: .visible
            ) {
                if let pendingLevel {
                    Button("Switch to \(pendingLevel.rawValue)") {
                        state.selectLevel(pendingLevel)
                        self.pendingLevel = nil
                        dismiss()
                    }
                }
                Button("Cancel", role: .cancel) {
                    pendingLevel = nil
                }
            } message: {
                Text("Your saved lines and completed lessons stay available.")
            }
        }
    }

    private func levelSection(title: String, subtitle: String, levels: [Level]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text(subtitle)
                    .font(.title3.weight(.bold))
            }

            ForEach(levels) { level in
                Button {
                    pendingLevel = level
                } label: {
                    LevelCard(level: level, selected: state.profile.currentLevel == level)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

struct LevelCard: View {
    let level: Level
    let selected: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                LevelBars(active: level.index)
                Spacer()
                Text(level.code)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(Color.clayStroke.opacity(0.5), in: Capsule())
            }

            Text(level.rawValue)
                .font(.title3.weight(.bold))

            Text(level.description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.leading)

            HStack {
                Text(selected ? "Current level" : "Select")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(selected ? Color.white : Color.primaryBlue)
                Spacer()
                if selected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.white)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 11)
            .background(selected ? Color.primaryBlue : Color.primaryBlue.opacity(0.1), in: Capsule())
        }
        .padding(18)
        .background(Color.claySurface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(selected ? Color.primaryBlue : Color.clayStroke, lineWidth: selected ? 2 : 1)
        )
    }
}

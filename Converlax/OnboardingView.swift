import SwiftUI

struct OnboardingView: View {
    @ObservedObject var state: LearningState
    let onComplete: () -> Void
    @State private var targetLanguage: TargetLanguage
    @State private var selectedLevel: Level
    @State private var step = 0
    @State private var isAdvancing = false

    init(state: LearningState, onComplete: @escaping () -> Void = {}) {
        self.state = state
        self.onComplete = onComplete
        _targetLanguage = State(initialValue: state.profile.targetLanguage.isAvailable ? state.profile.targetLanguage : .english)
        _selectedLevel = State(initialValue: state.profile.currentLevel)
    }

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 18) {
                header
                LessonProgressBar(progress: Double(step + 1) / 3)
                titleBlock
                ConverlaxMascotView(state: mascotState, size: step == 0 ? 116 : 88)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, step == 0 ? 2 : -4)

                if step == 0 {
                    introCards
                } else if step == 1 {
                    languageChoices
                } else {
                    levelChoices
                }

                Spacer()

                Button(action: continueFlow) {
                    Text(primaryButtonTitle)
                }
                .buttonStyle(PrimaryButtonStyle(isEnabled: !isAdvancing))
                .disabled(isAdvancing)
                .accessibilityIdentifier("onboarding-primary-button-\(step)")
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
        case 0: "Start with speaking"
        case 1: "Pick a course language"
        default: "Choose a starting point"
        }
    }

    private var subtitle: String {
        switch step {
        case 0: "Converlax gives you one useful line, then helps you say it out loud."
        case 1: "Your first lesson will open in this language."
        default: "Beginner is best for a quick first speaking lesson."
        }
    }

    private var primaryButtonTitle: String {
        switch step {
        case 0: "Set up first lesson"
        case 1: "Choose level"
        default: "Show my first lesson"
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
        OnboardingFirstLessonCard()
    }

    private var languageChoices: some View {
        VStack(spacing: 12) {
            ForEach(TargetLanguage.allCases.filter(\.isAvailable)) { language in
                ChoiceRow(
                    title: language.rawValue,
                    subtitle: subtitle(for: language),
                    selected: targetLanguage == language
                ) {
                    targetLanguage = language
                    state.selectTargetLanguage(language)
                }
            }
        }
    }

    private var levelChoices: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(Level.allCases) { level in
                    levelButton(level)
                }

                Text("You can switch levels later from Home.")
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(.secondary)
                    .padding(.top, 2)
            }
        }
        .scrollIndicators(.hidden)
    }

    private func levelButton(_ level: Level) -> some View {
        ChoiceRow(
            title: level == .beginner ? "\(level.rawValue) \(level.code) - Recommended" : "\(level.rawValue) \(level.code)",
            subtitle: onboardingSubtitle(for: level),
            selected: selectedLevel == level
        ) {
            selectedLevel = level
            state.selectLevel(level)
        }
    }

    private func onboardingSubtitle(for level: Level) -> String {
        switch level {
        case .beginner:
            "Short introductions and everyday lines"
        case .elementary:
            "Daily routines and simple places"
        case .upperElementary:
            "Appointments and longer small talk"
        case .intermediate:
            "Opinions, stories, and follow-up questions"
        }
    }

    private func continueFlow() {
        guard !isAdvancing else { return }
        isAdvancing = true

        if step < 2 {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.86)) {
                step += 1
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                isAdvancing = false
            }
        } else {
            state.completeOnboarding(language: state.profile.targetLanguage, level: state.profile.currentLevel)
            onComplete()
        }
    }

    private func subtitle(for language: TargetLanguage) -> String {
        return language == .english ? "Start with practical English conversation" : "Start with practical French conversation"
    }
}

private struct OnboardingFirstLessonCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .center, spacing: 14) {
                ConverlaxAssetBadge(kind: .freeTalk, size: 62)

                VStack(alignment: .leading, spacing: 5) {
                    Text("Your first lesson takes about 4 minutes.")
                        .font(.headline.weight(.semibold))
                    Text("Learn one line, speak it, and check that it makes sense.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            HStack(spacing: 10) {
                OnboardingMiniStep(symbol: "text.bubble.fill", title: "Learn")
                OnboardingMiniStep(symbol: "mic.fill", title: "Speak")
                OnboardingMiniStep(symbol: "checkmark.seal.fill", title: "Check")
            }
        }
        .padding(16)
        .background(Color.claySurface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.clayStroke.opacity(0.72), lineWidth: 1)
        )
    }
}

private struct OnboardingMiniStep: View {
    let symbol: String
    let title: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: symbol)
                .font(.caption.weight(.bold))
                .foregroundStyle(Color.primaryBlue)
            Text(title)
                .font(.caption.weight(.bold))
                .foregroundStyle(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.84)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 9)
        .background(Color.appBackground.opacity(0.72), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
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
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title)
        .accessibilityHint(enabled ? subtitle : "Choose an active course language to start.")
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
                        Text("Your next lesson updates right away.")
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

import SwiftUI

struct ProgressViewScreen: View {
    @ObservedObject var state: LearningState

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                VStack(spacing: 18) {
                    streakCard

                    HStack(spacing: 12) {
                        StatCard(value: "\(state.completedLessonCount)", label: "Lessons done", color: Color.mintSuccess)
                        StatCard(value: "\(state.courseSavedWords.count)", label: "Words saved", color: Color.primaryBlue)
                    }

                    goalCard
                    unitProgressCard
                    Spacer()
                }
                .padding(20)
            }
            .navigationTitle("Progress")
        }
    }

    private var streakCard: some View {
        VStack(spacing: 8) {
            ConverlaxAssetBadge(kind: .streak, size: 92)
            Text(state.profile.streak == 0 ? "Start a Streak" : "\(state.profile.streak)-Day Streak")
                .font(.title2.weight(.bold))
            Text(state.profile.streak == 0 ? "Do one lesson today to keep your record alive." : "Complete another lesson tomorrow to keep it going.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(Color.claySurface, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .accessibilityElement(children: .combine)
    }

    private var goalCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Daily goal")
                    .font(.headline.weight(.semibold))
                Spacer()
                Text("\(min(state.completedLessonCount, state.profile.dailyGoal))/\(state.profile.dailyGoal)")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(Color.primaryBlue)
            }
            LessonProgressBar(progress: Double(min(state.completedLessonCount, state.profile.dailyGoal)) / Double(max(state.profile.dailyGoal, 1)))
        }
        .padding(18)
        .background(Color.claySurface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var unitProgressCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(state.profile.targetLanguage.unitTitle)
                    .font(.headline.weight(.semibold))
                Spacer()
                Text("\(Int(state.courseProgress * 100))%")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(Color.primaryBlue)
            }
            LessonProgressBar(progress: state.courseProgress)
        }
        .padding(18)
        .background(Color.claySurface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

struct ProfileView: View {
    @ObservedObject var state: LearningState
    @State private var resetConfirmation: ResetConfirmation?

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 18) {
                        profileHeader
                        settingsRows
                        learningControls
                        savedWordsSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 110)
                }
            }
            .navigationTitle("Profile")
            .confirmationDialog(
                resetConfirmation?.title ?? "",
                isPresented: Binding(
                    get: { resetConfirmation != nil },
                    set: { if !$0 { resetConfirmation = nil } }
                ),
                titleVisibility: .visible
            ) {
                if resetConfirmation == .progress {
                    Button("Reset progress", role: .destructive) {
                        state.resetProgress()
                        resetConfirmation = nil
                    }
                } else if resetConfirmation == .onboarding {
                    Button("Restart onboarding", role: .destructive) {
                        state.restartOnboarding()
                        resetConfirmation = nil
                    }
                }
                Button("Cancel", role: .cancel) {
                    resetConfirmation = nil
                }
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

    private var settingsRows: some View {
        VStack(spacing: 0) {
            ProfileRow(symbol: "bookmark.fill", title: "\(state.courseSavedWords.count) saved words and phrases")
            Divider().padding(.leading, 52)
            ProfileRow(symbol: "globe", title: "\(state.profile.targetLanguage.courseName) course")
        }
        .background(Color.claySurface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var learningControls: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Learning settings")
                .font(.headline.weight(.semibold))

            VStack(alignment: .leading, spacing: 8) {
                Text("Course")
                    .font(.subheadline.weight(.semibold))
                Picker("Course", selection: Binding(
                    get: { state.profile.targetLanguage },
                    set: state.selectTargetLanguage
                )) {
                    ForEach(TargetLanguage.allCases.filter(\.isAvailable)) { language in
                        Text(language.rawValue).tag(language)
                    }
                }
                .pickerStyle(.segmented)
            }

            Stepper("Daily goal: \(state.profile.dailyGoal) lessons", value: Binding(
                get: { state.profile.dailyGoal },
                set: state.setDailyGoal
            ), in: 1...6)

            Toggle("Sound effects", isOn: Binding(
                get: { state.profile.soundEnabled },
                set: state.setSoundEnabled
            ))

            Toggle("Haptics", isOn: Binding(
                get: { state.profile.hapticsEnabled },
                set: state.setHapticsEnabled
            ))

            Button("Reset progress", role: .destructive) {
                resetConfirmation = .progress
            }

            Button("Restart onboarding") {
                resetConfirmation = .onboarding
            }
        }
        .padding(18)
        .background(Color.claySurface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    @ViewBuilder
    private var savedWordsSection: some View {
        if state.courseSavedWords.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text("Saved words")
                    .font(.headline.weight(.semibold))
                Text("Complete lessons to collect useful words and phrases here.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(18)
            .background(Color.claySurface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        } else {
            VStack(alignment: .leading, spacing: 10) {
                Text("Saved words")
                    .font(.headline.weight(.semibold))
                ForEach(state.courseSavedWords) { word in
                    SavedWordRow(word: word) {
                        state.removeWord(word)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

private enum ResetConfirmation {
    case progress
    case onboarding

    var title: String {
        switch self {
        case .progress: "Reset all lesson progress?"
        case .onboarding: "Restart onboarding?"
        }
    }
}

private struct ProfileRow: View {
    let symbol: String
    let title: String

    var body: some View {
        HStack(spacing: 14) {
                ConverlaxAssetBadge(kind: rowAsset, size: 44)
            Text(title)
                .font(.subheadline.weight(.medium))
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundStyle(.secondary)
        }
        .padding(14)
    }

    private var rowAsset: ConverlaxAssetKind {
        if symbol.contains("bookmark") { return .savedLines }
        if symbol.contains("globe") { return .askDirections }
        return .settings
    }
}

private struct SavedWordRow: View {
    let word: SavedWord
    let remove: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(word.term)
                    .font(.subheadline.weight(.semibold))
                Text(word.translation)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(word.example)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button(action: remove) {
                Image(systemName: "bookmark.slash")
                    .foregroundStyle(Color.primaryBlue)
            }
            .accessibilityLabel("Remove \(word.term)")
        }
        .padding(12)
        .background(Color.claySurface, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

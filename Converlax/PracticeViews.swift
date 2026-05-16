import SwiftUI

struct QuickLessonPracticeView: View {
    @ObservedObject var state: LearningState

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 18) {
                Text("Quick lessons")
                    .font(.title2.weight(.bold))

                NavigationLink(value: QuickPracticeRoute.vocab) {
                    PracticeCard(title: "Vocab", subtitle: "Translate and save useful words", symbol: "character.book.closed.fill", color: Color.warmAmber, asset: .vocab)
                }

                NavigationLink(value: QuickPracticeRoute.verbs) {
                    PracticeCard(title: "Verbs", subtitle: "Fill blanks from the current unit", symbol: "textformat.abc.dottedunderline", color: Color.violetAccent, asset: .verbs)
                }

                Spacer()
                TutorPromptBar()
            }
            .padding(20)
        }
        .navigationTitle("Practice")
        .navigationDestination(for: QuickPracticeRoute.self) { route in
            switch route {
            case .vocab:
                VocabLessonView(lesson: BeginnerContent.vocabPracticeLesson(for: state.profile.targetLanguage), state: state)
            case .verbs:
                VerbLessonView(lesson: BeginnerContent.verbPracticeLesson(for: state.profile.targetLanguage), state: state)
            }
        }
    }
}

private struct PracticeCard: View {
    let title: String
    let subtitle: String
    let symbol: String
    let color: Color
    var asset: ConverlaxAssetKind? = nil

    var body: some View {
        HStack(spacing: 14) {
            if let asset {
                ConverlaxAssetBadge(kind: asset, size: 54)
            } else {
                Image(systemName: symbol)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 48, height: 48)
                    .background(color, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.primary)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.footnote.weight(.bold))
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .background(Color.claySurface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(Color.clayStroke))
    }
}

struct VocabLessonView: View {
    let lesson: BeginnerLesson
    @ObservedObject var state: LearningState
    @State private var selectedAnswer: String?
    @State private var showSettings = false
    @State private var finished = false
    @State private var checked = false
    @State private var savedLine = false
    @State private var audioEnabled = false
    @State private var feedback: LearningFeedback?
    @State private var completionResult: CompletionCelebrationResult?

    private var practiceStep: LessonStep {
        lesson.steps.first { $0.kind == .choice } ?? lesson.steps[0]
    }

    private var answers: [String] {
        practiceStep.choices
    }

    private var savedWordsSummary: String {
        let terms = lesson.savedWords.map(\.term)
        guard !terms.isEmpty else { return "Your progress is saved." }
        let summary = terms.count == 1 ? terms[0] : "\(terms.dropLast().joined(separator: ", ")) and \(terms.last ?? "")"
        return "Saved \(summary) to your words."
    }

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 22) {
                LessonProgressBar(progress: finished ? 1 : (checked ? 0.72 : 0.42))

                if finished, let completionResult {
                    CompletionCelebrationView(result: completionResult, mascotState: .success)
                } else {
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Translate")
                            .font(.title3.weight(.bold))
                        Text(practiceStep.prompt)
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(16)
                            .background(Color.claySurface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                        Text(practiceStep.helper)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        HStack(spacing: 14) {
                            Button {
                                audioEnabled.toggle()
                            } label: {
                                Label(audioEnabled ? "Audio on" : "Play word", systemImage: audioEnabled ? "speaker.wave.2.fill" : "speaker.wave.2")
                            }
                            Button {
                                savePracticeLine()
                            } label: {
                                Label(savedLine ? "Saved" : "Save line", systemImage: savedLine ? "bookmark.fill" : "bookmark")
                            }
                            .disabled(savedLine)
                        }
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(Color.primaryBlue)
                    }
                }

                if !finished {
                    VStack(spacing: 12) {
                        ForEach(answers, id: \.self) { answer in
                            Button {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                                    selectedAnswer = answer
                                }
                            } label: {
                                Text(answer)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(.primary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 15)
                                    .background(Color.claySurface, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .stroke(answerBorderColor(answer), lineWidth: selectedAnswer == answer || answer == practiceStep.correctAnswer && checked ? 2 : 1)
                                    )
                            }
                            .disabled(checked)
                        }
                    }
                }

                Spacer()

                feedbackPanel

                Button(action: completeOrRestart) {
                    Text(buttonTitle)
                }
                .buttonStyle(PrimaryButtonStyle(isEnabled: selectedAnswer != nil || finished))
                .disabled(selectedAnswer == nil && !finished)
            }
            .padding(20)
        }
        .navigationTitle("Vocab")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showSettings = true
                } label: {
                    Image(systemName: "slider.horizontal.3")
                }
                .accessibilityLabel("Vocab settings")
            }
        }
        .sheet(isPresented: $showSettings) {
            VocabSettingsSheet()
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
    }

    private func completeOrRestart() {
        if finished {
            selectedAnswer = nil
            finished = false
            checked = false
            savedLine = false
            feedback = nil
            completionResult = nil
        } else {
            selectedAnswer = selectedAnswer ?? practiceStep.correctAnswer ?? answers.first
            if checked {
                let previousProfile = state.profile
                state.completeLesson(lesson)
                completionResult = state.completionCelebration(
                    from: previousProfile,
                    title: "Vocab complete",
                    subtitle: savedWordsSummary
                )
                finished = true
            } else {
                feedback = state.recordPracticeResult(
                    lesson: lesson,
                    step: practiceStep,
                    selectedAnswer: selectedAnswer,
                    correct: selectedAnswer == practiceStep.correctAnswer,
                    mode: "Vocab lesson"
                )
                checked = true
            }
        }
    }

    private var buttonTitle: String {
        if finished { return "Practice again" }
        return checked ? "Complete lesson" : "Check answer"
    }

    @ViewBuilder
    private var feedbackPanel: some View {
        if checked, !finished {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 10) {
                    Image(systemName: selectedAnswer == practiceStep.correctAnswer ? "checkmark.circle.fill" : "lightbulb.fill")
                        .foregroundStyle(selectedAnswer == practiceStep.correctAnswer ? Color.mintSuccess : Color.warmAmber)
                    Text(selectedAnswer == practiceStep.correctAnswer ? "Correct. Listen once, then save or continue." : "Good try. Correct answer: \(practiceStep.correctAnswer ?? answers.first ?? "")")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                }

                if let feedback {
                    LearningFeedbackCard(feedback: feedback)
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.claySurface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }

    private func answerBorderColor(_ answer: String) -> Color {
        if checked, answer == practiceStep.correctAnswer { return .mintSuccess }
        if checked, answer == selectedAnswer { return .red }
        if answer == selectedAnswer { return .primaryBlue }
        return Color.clayStroke
    }

    private func savePracticeLine() {
        state.saveLine(
            SavedLine(
                id: "vocab-\(practiceStep.id)",
                text: practiceStep.prompt,
                translation: practiceStep.helper,
                source: "Vocab",
                note: "Saved from vocab practice."
            )
        )
        savedLine = true
    }
}

private struct VocabSettingsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var difficulty = "Easy"
    @State private var jumpIn = true

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Settings")
                        .font(.title3.weight(.bold))
                    Text("Applies starting the next jump-in lesson")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .foregroundStyle(.secondary)
                }
                .accessibilityLabel("Close")
            }

            Toggle("Jump in after each answer", isOn: $jumpIn)

            VStack(alignment: .leading, spacing: 10) {
                Text("Difficulty")
                    .font(.subheadline.weight(.semibold))
                Picker("Difficulty", selection: $difficulty) {
                    Text("Easy").tag("Easy")
                    Text("Balanced").tag("Balanced")
                    Text("Hard").tag("Hard")
                }
                .pickerStyle(.segmented)
            }

            Spacer()

            Button {
                dismiss()
            } label: {
                Text("Save Settings")
            }
            .buttonStyle(PrimaryButtonStyle())
        }
        .padding(22)
    }
}

struct VerbLessonView: View {
    let lesson: BeginnerLesson
    @ObservedObject var state: LearningState
    @State private var selectedAnswer: String?
    @State private var checked = false
    @State private var finished = false
    @State private var savedLine = false
    @State private var audioEnabled = false
    @State private var feedback: LearningFeedback?
    @State private var completionResult: CompletionCelebrationResult?

    private var practiceStep: LessonStep {
        lesson.steps.first { $0.kind == .choice } ?? lesson.steps[0]
    }

    private var answers: [String] {
        practiceStep.choices
    }

    private var correctAnswer: String {
        practiceStep.correctAnswer ?? answers.first ?? ""
    }

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 22) {
                LessonProgressBar(progress: finished ? 1 : (checked ? 0.8 : 0.58))
                Text(finished ? "Verb lesson complete" : "Fill in the blank")
                    .font(.title3.weight(.bold))
                if finished, let completionResult {
                    CompletionCelebrationView(result: completionResult, mascotState: .success)
                } else {
                    VerbPrompt(prompt: practiceStep.prompt, helper: practiceStep.helper, selectedAnswer: selectedAnswer)
                    HStack(spacing: 14) {
                        Button {
                            audioEnabled.toggle()
                        } label: {
                            Label(audioEnabled ? "Audio on" : "Play phrase", systemImage: audioEnabled ? "speaker.wave.2.fill" : "speaker.wave.2")
                        }
                        Button {
                            saveVerbLine()
                        } label: {
                            Label(savedLine ? "Saved" : "Save line", systemImage: savedLine ? "bookmark.fill" : "bookmark")
                        }
                        .disabled(savedLine)
                    }
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Color.primaryBlue)
                    answerButtons
                }
                Spacer()
                resultBanner
                if let feedback, checked && !finished {
                    LearningFeedbackCard(feedback: feedback)
                }
                Button(action: checkOrRestart) {
                    Text(buttonTitle)
                }
                .buttonStyle(PrimaryButtonStyle(isEnabled: selectedAnswer != nil || checked || finished))
                .disabled(selectedAnswer == nil && !checked && !finished)
            }
            .padding(20)
        }
        .navigationTitle("Verbs")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    audioEnabled.toggle()
                } label: {
                    Image(systemName: audioEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                }
                .accessibilityLabel("Play phrase")
            }
        }
    }

    private var answerButtons: some View {
        VStack(spacing: 12) {
            ForEach(answers, id: \.self) { answer in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.84)) {
                        selectedAnswer = answer
                        checked = false
                    }
                } label: {
                    Text(answer)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(selectedAnswer == answer ? Color.primaryBlue.opacity(0.14) : .white, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(verbBorderColor(answer), lineWidth: selectedAnswer == answer || answer == correctAnswer && checked ? 2 : 1)
                        )
                }
                .disabled(checked)
            }
        }
    }

    @ViewBuilder
    private var resultBanner: some View {
        if checked && !finished {
            HStack {
                Image(systemName: selectedAnswer == correctAnswer ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundStyle(selectedAnswer == correctAnswer ? Color.mintSuccess : Color.red)
                Text(selectedAnswer == correctAnswer ? "Correct. Progress saved." : "Correct answer: \(correctAnswer)")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(selectedAnswer == correctAnswer ? Color.mintSuccess : Color.red)
            }
            .padding(.vertical, 4)
        }
    }

    private func checkOrRestart() {
        if finished {
            selectedAnswer = nil
            checked = false
            finished = false
            savedLine = false
            feedback = nil
            completionResult = nil
        } else if checked {
            let previousProfile = state.profile
            state.completeLesson(lesson)
            completionResult = state.completionCelebration(
                from: previousProfile,
                title: "Verb lesson complete",
                subtitle: "You finished \(lesson.title.lowercased()).",
                savedItemsCreated: max(savedLine ? 1 : 0, state.profile.savedLearningObjects.count - previousProfile.savedLearningObjects.count)
            )
            finished = true
        } else {
            selectedAnswer = selectedAnswer ?? correctAnswer
            feedback = state.recordPracticeResult(
                lesson: lesson,
                step: practiceStep,
                selectedAnswer: selectedAnswer,
                correct: selectedAnswer == correctAnswer,
                mode: "Verb lesson"
            )
            checked = true
        }
    }

    private var buttonTitle: String {
        if finished { return "Practice again" }
        return checked ? "Finish lesson" : "Check"
    }

    private func verbBorderColor(_ answer: String) -> Color {
        if checked, answer == correctAnswer { return .mintSuccess }
        if checked, answer == selectedAnswer { return .red }
        if selectedAnswer == answer { return .primaryBlue }
        return Color.clayStroke
    }

    private func saveVerbLine() {
        state.saveLine(
            SavedLine(
                id: "verb-\(practiceStep.id)",
                text: practiceStep.prompt.replacingOccurrences(of: "___", with: correctAnswer),
                translation: practiceStep.helper,
                source: "Verb lesson",
                note: "Saved from verb practice."
            )
        )
        savedLine = true
    }
}

private struct VerbCompletionPanel: View {
    let lesson: BeginnerLesson
    let savedLine: Bool

    var body: some View {
            VStack(alignment: .leading, spacing: 12) {
            ConverlaxMascotView(state: .success, size: 78)
            Text("You finished \(lesson.title.lowercased()).")
                .font(.title3.weight(.bold))
            Text(savedLine ? "Your selected phrase is available in Saved Lines and Review." : "Progress is saved. Save a line next time to review it later.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(Color.claySurface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

private struct VerbPrompt: View {
    let prompt: String
    let helper: String
    let selectedAnswer: String?

    private var displayPrompt: String {
        prompt.replacingOccurrences(of: "___", with: selectedAnswer ?? "___")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(displayPrompt)
                .font(.title3.weight(.semibold))
                .foregroundStyle(.primary)

            Text(helper)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack {
                Spacer()
                Image(systemName: "bookmark")
                    .foregroundStyle(.secondary.opacity(0.8))
            }
        }
        .padding(18)
        .background(Color.claySurface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

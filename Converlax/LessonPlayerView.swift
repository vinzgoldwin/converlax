import SwiftUI

private extension LessonStep {
    var speakablePrompt: String {
        if prompt.contains("___"), let correctAnswer {
            return prompt.replacingOccurrences(of: "___", with: correctAnswer)
        }

        return correctAnswer ?? prompt
    }

    var voicePromptTitle: String {
        kind == .choice && correctAnswer != nil ? "Clear answer" : title
    }

    var voicePromptContext: String? {
        guard kind == .choice, correctAnswer != nil else { return nil }
        let trimmedPrompt = prompt.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedPrompt.isEmpty else { return nil }
        return "Situation: \(trimmedPrompt)"
    }

    var speakableContext: String {
        kind == .choice && correctAnswer != nil ? prompt : helper
    }

    var voiceReadyInstruction: String {
        switch kind {
        case .teach:
            if title.localizedCaseInsensitiveContains("repeat") {
                return "Repeat this sentence out loud."
            }
            return "Say this goal out loud."
        case .choice:
            if correctAnswer != nil {
                return "Say the clear answer out loud."
            }
            return "Answer this prompt out loud."
        case .speak:
            return "Say this line out loud. Change the details if needed."
        case .roleplay:
            return "Answer the situation out loud."
        case .freeResponse:
            return "Answer this prompt in your own words."
        }
    }
}

struct LessonPlayerView: View {
    @ObservedObject var state: LearningState
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var lesson: BeginnerLesson
    @State private var stepIndex = 0
    @State private var completed = false
    @State private var savedCurrentLine = false
    @State private var speechPhase: SpeechPracticePhase = .ready
    @State private var transcript = ""
    @State private var speechFeedback: LearningFeedback?
    @State private var turnFeedbackByStepID: [String: LearningFeedback] = [:]
    @State private var speechErrorMessage: String?
    @StateObject private var speechRecognizer = SpeechRecognitionService()
    @State private var didApplyLaunchSpeechState = false
    @State private var completionResult: CompletionCelebrationResult?
    @State private var turnEntranceVisible = false

    init(lesson: BeginnerLesson, state: LearningState) {
        _lesson = State(initialValue: lesson)
        _stepIndex = State(initialValue: state.resumeStepIndex(for: lesson))
        self.state = state
    }

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 18) {
                if completed {
                    if let completionResult {
                        CompletionCelebrationView(result: completionResult)
                    }
                    Spacer()
                    Button(action: dismiss.callAsFunction) {
                        Text("Back to course")
                    }
                    .buttonStyle(PrimaryButtonStyle())
                } else {
                    ScrollView {
                        VoiceFirstLessonTurn(
                            lesson: lesson,
                            step: step,
                            stepIndex: stepIndex,
                            stepCount: lesson.steps.count,
                            progress: progress,
                            accent: lesson.accent.color,
                            savedCurrentLine: savedCurrentLine,
                            speechPhase: speechPhase,
                            transcript: transcript,
                            voiceLevel: speechRecognizer.voiceLevel,
                            speechFeedback: speechFeedback,
                            speechErrorMessage: speechErrorMessage,
                            isLastTurn: stepIndex == lesson.steps.count - 1,
                            canGoToPreviousTurn: stepIndex > 0,
                            canGoToNextTurn: stepIndex < furthestAvailableStepIndex,
                            onSaveLine: saveCurrentLine,
                            onSpeechPrimary: advanceSpeechState,
                            onSpeechCancel: cancelSpeech,
                            onSpeechRetry: retryCurrentTurn,
                            onPreviousTurn: { moveToTurn(stepIndex - 1) },
                            onNextTurn: { moveToTurn(stepIndex + 1) }
                        )
                        .opacity(turnEntranceVisible ? 1 : 0)
                        .offset(y: turnEntranceVisible || reduceMotion ? 0 : 12)
                        .padding(.bottom, 18)
                    }
                    .scrollIndicators(.hidden)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 28)
        }
        .navigationTitle(lesson.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .onChange(of: speechRecognizer.transcript) { _, newValue in
            transcript = newValue
        }
        .onAppear {
            applyLaunchSpeechStateIfNeeded()
            syncSavedCurrentLine()
            withAnimation(reduceMotion ? nil : .easeOut(duration: 0.32).delay(0.04)) {
                turnEntranceVisible = true
            }
        }
        .onDisappear {
            speechRecognizer.cancelRecording()
        }
    }

    private var step: LessonStep {
        lesson.steps[stepIndex]
    }

    private var progress: Double {
        Double(stepIndex + 1) / Double(lesson.steps.count)
    }

    private var furthestAvailableStepIndex: Int {
        min(max(state.resumeStepIndex(for: lesson), stepIndex), max(lesson.steps.count - 1, 0))
    }

    private var currentSavedLine: SavedLine {
        SavedLine(
            id: "lesson-\(step.id)",
            text: step.speakablePrompt,
            translation: step.speakableContext,
            source: lesson.title,
            note: "Saved from a \(lesson.title.lowercased()) step."
        )
    }

    private func saveCurrentLine() {
        let line = currentSavedLine
        if savedCurrentLine {
            state.removeLine(line)
            savedCurrentLine = false
            return
        }

        state.saveLine(line)
        savedCurrentLine = true
    }

    private func syncSavedCurrentLine() {
        savedCurrentLine = state.savedLines.contains { $0.id == currentSavedLine.id }
    }

    private func advanceSpeechState() {
        switch speechPhase {
        case .permissionNeeded, .permissionDenied, .ready, .paused, .noSpeech, .error:
            startSpeechRecording()
        case .recording:
            finishSpeechRecording()
        case .requestingPermission, .processing, .transcribing:
            break
        case .transcript:
            Task { await generateSpeechFeedback() }
        case .feedback:
            advanceAfterSpeechAcceptance()
        case .accepted:
            speechPhase = .ready
            transcript = ""
            speechFeedback = nil
            speechErrorMessage = nil
        }
    }

    private func cancelSpeech() {
        speechRecognizer.cancelRecording()
        speechPhase = .ready
        transcript = ""
        speechFeedback = nil
        speechErrorMessage = nil
    }

    private func retryCurrentTurn() {
        speechRecognizer.cancelRecording()
        withAnimation(.easeOut(duration: 0.2)) {
            speechPhase = .ready
            transcript = ""
            speechFeedback = nil
            speechErrorMessage = nil
        }
    }

    private func moveToTurn(_ targetIndex: Int) {
        guard lesson.steps.indices.contains(targetIndex) else { return }
        speechRecognizer.cancelRecording()
        let targetStep = lesson.steps[targetIndex]
        let restoredFeedback = latestFeedback(for: targetStep)
        withAnimation(.spring(response: 0.32, dampingFraction: 0.86)) {
            stepIndex = targetIndex
            savedCurrentLine = state.savedLines.contains { $0.id == "lesson-\(targetStep.id)" }
            speechPhase = restoredFeedback == nil ? .ready : .feedback
            transcript = restoredFeedback?.attemptedText ?? ""
            speechFeedback = restoredFeedback
            speechErrorMessage = nil
        }
    }

    private func startSpeechRecording() {
        speechPhase = .requestingPermission
        transcript = ""
        speechFeedback = nil
        speechErrorMessage = nil

        Task {
            let started = await speechRecognizer.startRecording(localeIdentifier: state.profile.targetLanguage.speechRecognitionLocaleIdentifier)
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

    @MainActor
    private func generateSpeechFeedback() async {
        let cleanTranscript = transcript.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanTranscript.isEmpty else {
            speechErrorMessage = "No clear speech was captured. Try again a little slower and closer to the mic."
            speechPhase = .noSpeech
            return
        }

        speechPhase = .processing
        speechErrorMessage = nil

        let aiFeedback: AIFeedback?
        do {
            aiFeedback = try await AIFeedbackService.shared.feedback(
                transcript: cleanTranscript,
                context: speechFeedbackContext(mode: "Speaking practice", step: step)
            )
        } catch {
            aiFeedback = nil
            speechErrorMessage = AIFeedbackService.fallbackMessage(for: error)
        }

        let feedback = state.acceptSpeechPractice(
            lesson: lesson,
            step: step,
            transcript: cleanTranscript,
            mode: "Speaking practice",
            aiFeedback: aiFeedback
        )
        turnFeedbackByStepID[step.id] = feedback
        speechFeedback = feedback
        speechPhase = .feedback
    }

    private func latestFeedback(for step: LessonStep) -> LearningFeedback? {
        if let feedback = turnFeedbackByStepID[step.id] {
            return feedback
        }

        return state.profile.feedbackEvents.first { feedback in
            feedback.source.localizedCaseInsensitiveContains("speaking") &&
                feedback.promptText.trimmingCharacters(in: .whitespacesAndNewlines) ==
                step.prompt.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
    private func advanceAfterSpeechAcceptance() {
        speechPhase = .accepted

        if stepIndex < lesson.steps.count - 1 {
            let nextStepIndex = stepIndex + 1
            let nextStep = lesson.steps[nextStepIndex]
            state.saveLessonResume(lesson: lesson, stepIndex: nextStepIndex)
            withAnimation(.spring(response: 0.35, dampingFraction: 0.86)) {
                stepIndex = nextStepIndex
                savedCurrentLine = state.savedLines.contains { $0.id == "lesson-\(nextStep.id)" }
                speechPhase = .ready
                transcript = ""
                speechFeedback = nil
                speechErrorMessage = nil
            }
        } else {
            let previousProfile = state.profile
            state.completeLesson(lesson)
            completionResult = state.completionCelebration(
                from: previousProfile,
                title: "Lesson complete",
                subtitle: "You finished \(lesson.title.lowercased())."
            )
            withAnimation(.spring(response: 0.35, dampingFraction: 0.86)) {
                completed = true
            }
        }
    }

    private func applyLaunchSpeechStateIfNeeded() {
        guard
            !didApplyLaunchSpeechState,
            state.resumeStepIndex(for: lesson) == 0,
            ProcessInfo.processInfo.converlaxInitialHomeRoute == "lesson",
            let launchState = ProcessInfo.processInfo.converlaxArgumentValue(after: "-ConverlaxLessonSpeechState"),
            let targetIndex = lesson.steps.firstIndex(where: { $0.kind == .speak || $0.kind == .choice })
        else { return }

        didApplyLaunchSpeechState = true
        let targetStep = lesson.steps[targetIndex]
        stepIndex = targetIndex
        savedCurrentLine = state.savedLines.contains { $0.id == "lesson-\(targetStep.id)" }
        speechFeedback = nil
        speechErrorMessage = nil

        switch launchState {
        case "recording":
            transcript = ""
            speechPhase = .recording
        case "transcript", "transcriptReady":
            transcript = sampleTranscript(for: targetStep)
            speechPhase = .transcript
        case "feedback":
            transcript = sampleTranscript(for: targetStep)
            let feedback = state.acceptSpeechPractice(
                lesson: lesson,
                step: targetStep,
                transcript: transcript,
                mode: "Speaking practice"
            )
            turnFeedbackByStepID[targetStep.id] = feedback
            speechFeedback = feedback
            speechPhase = .feedback
        case "permissionDenied", "permission":
            transcript = ""
            speechErrorMessage = "Voice practice needs Microphone and Speech Recognition. Enable access in Settings, then try again."
            speechPhase = .permissionDenied
        default:
            break
        }
    }

    private func sampleTranscript(for step: LessonStep) -> String {
        let filledBlank = step.speakablePrompt.replacingOccurrences(of: "___", with: step.correctAnswer ?? "coffee")
        return filledBlank.replacingOccurrences(of: "...", with: "Alex")
    }

    private func speechFeedbackContext(mode: String, step: LessonStep) -> AIFeedbackRequestContext {
        AIFeedbackRequestContext(
            mode: mode,
            lessonTitle: lesson.title,
            prompt: step.speakablePrompt,
            expectedPhrase: expectedPhrase(for: step),
            targetLanguage: state.profile.targetLanguage.rawValue,
            proficiencyLevel: state.profile.currentLevel.code,
            roleplayTitle: nil,
            roleplaySetting: nil,
            usefulPhrases: nil
        )
    }

    private func expectedPhrase(for step: LessonStep) -> String {
        if step.prompt.contains("___"), let answer = step.correctAnswer {
            return step.prompt.replacingOccurrences(of: "___", with: answer)
        }
        return step.speakablePrompt
    }
}

private struct VoiceFirstLessonTurn: View {
    let lesson: BeginnerLesson
    let step: LessonStep
    let stepIndex: Int
    let stepCount: Int
    let progress: Double
    let accent: Color
    let savedCurrentLine: Bool
    let speechPhase: SpeechPracticePhase
    let transcript: String
    let voiceLevel: Double
    let speechFeedback: LearningFeedback?
    let speechErrorMessage: String?
    let isLastTurn: Bool
    let canGoToPreviousTurn: Bool
    let canGoToNextTurn: Bool
    let onSaveLine: () -> Void
    let onSpeechPrimary: () -> Void
    let onSpeechCancel: () -> Void
    let onSpeechRetry: () -> Void
    let onPreviousTurn: () -> Void
    let onNextTurn: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VoiceLessonHeader(
                lesson: lesson,
                stepIndex: stepIndex,
                stepCount: stepCount,
                progress: progress,
                canGoToPreviousTurn: canGoToPreviousTurn,
                canGoToNextTurn: canGoToNextTurn,
                onPreviousTurn: onPreviousTurn,
                onNextTurn: onNextTurn
            )

            VoicePromptBlock(
                step: step,
                helperText: helperText,
                savedCurrentLine: savedCurrentLine,
                onSaveLine: onSaveLine
            )

            SpeechPracticePanel(
                phase: speechPhase,
                transcript: transcript,
                feedback: speechFeedback,
                accent: accent,
                readyInstruction: step.voiceReadyInstruction,
                voiceLevel: voiceLevel,
                errorMessage: speechErrorMessage,
                primaryActionTitle: voiceActionTitle,
                secondaryActionTitle: retryActionTitle,
                onPrimary: onSpeechPrimary,
                onCancel: onSpeechCancel,
                onSecondary: onSpeechRetry
            )

        }
    }

    private var voiceActionTitle: String? {
        switch speechPhase {
        case .feedback, .accepted:
            isLastTurn ? "Finish lesson" : "Next prompt"
        default:
            nil
        }
    }

    private var retryActionTitle: String? {
        speechPhase == .feedback ? "Try again" : nil
    }

    private var helperText: String? {
        let trimmedHelper = step.helper.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedHelper.isEmpty else { return nil }

        let prompt = step.prompt.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedHelper.localizedCaseInsensitiveCompare(prompt) != .orderedSame else { return nil }

        let lowercasedHelper = trimmedHelper.lowercased()
        if step.kind == .choice && (lowercasedHelper.contains("choose") || lowercasedHelper.contains("pick")) {
            return nil
        }

        return trimmedHelper
    }
}

private struct VoiceLessonHeader: View {
    let lesson: BeginnerLesson
    let stepIndex: Int
    let stepCount: Int
    let progress: Double
    let canGoToPreviousTurn: Bool
    let canGoToNextTurn: Bool
    let onPreviousTurn: () -> Void
    let onNextTurn: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                ConverlaxAssetBadge(kind: lesson.visualAsset, size: 38)

                VStack(alignment: .leading, spacing: 2) {
                    Text(lesson.title)
                        .font(.subheadline.weight(.bold))
                        .lineLimit(1)
                    Text("Turn \(stepIndex + 1) of \(max(stepCount, 1))")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                HStack(spacing: 6) {
                    turnButton(symbol: "chevron.left", label: "Previous turn", isEnabled: canGoToPreviousTurn, action: onPreviousTurn)
                    turnButton(symbol: "chevron.right", label: "Next turn", isEnabled: canGoToNextTurn, action: onNextTurn)
                }
            }

            LessonProgressBar(progress: progress)
        }
        .padding(14)
        .background(Color.claySurface, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func turnButton(symbol: String, label: String, isEnabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.caption.weight(.bold))
                .foregroundStyle(isEnabled ? Color.primaryBlue : Color.secondary.opacity(0.55))
                .frame(width: 32, height: 32)
                .background(Color.appBackground.opacity(isEnabled ? 0.82 : 0.45), in: Circle())
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .accessibilityLabel(label)
    }
}

private struct VoicePromptBlock: View {
    let step: LessonStep
    let helperText: String?
    let savedCurrentLine: Bool
    let onSaveLine: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(step.voicePromptTitle)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.secondary)
                    Text(step.speakablePrompt)
                        .font(.title2.weight(.semibold))
                        .fixedSize(horizontal: false, vertical: true)
                    if let context = step.voicePromptContext {
                        Text(context)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Button(action: onSaveLine) {
                    Image(systemName: savedCurrentLine ? "bookmark.fill" : "bookmark")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(savedCurrentLine ? Color.primaryBlue : Color.secondary)
                        .symbolEffect(.bounce, value: savedCurrentLine)
                        .frame(width: 36, height: 36)
                        .background(Color.appBackground.opacity(0.76), in: Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(savedCurrentLine ? "Unsave line" : "Save line")
            }

            if let helperText {
                Text(helperText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(16)
        .background(Color.claySurface, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

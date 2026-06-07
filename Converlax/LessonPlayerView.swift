import AVFoundation
import SwiftUI

private let minimumLessonTurnScore = 70

final class SpeechPlaybackService: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    @Published private(set) var isPlaying = false

    private let synthesizer = AVSpeechSynthesizer()
    private var activeUtterance: AVSpeechUtterance?
    private var ownsAudioSession = false

    override init() {
        super.init()
        synthesizer.delegate = self
    }

    func toggle(text: String, localeIdentifier: String, voiceIdentifier: String? = nil) {
        if synthesizer.isSpeaking {
            stop()
            return
        }

        speak(text: text, localeIdentifier: localeIdentifier, voiceIdentifier: voiceIdentifier)
    }

    func speak(text: String, localeIdentifier: String, voiceIdentifier: String? = nil) {
        stop()

        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }

        guard prepareAudioSessionForPlayback() else { return }

        let utterance = AVSpeechUtterance(string: trimmedText)
        utterance.voice = voiceIdentifier.flatMap(AVSpeechSynthesisVoice.init(identifier:)) ??
            AVSpeechSynthesisVoice(language: localeIdentifier)
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.88
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0

        activeUtterance = utterance
        isPlaying = true
        synthesizer.speak(utterance)
    }

    func stop() {
        guard synthesizer.isSpeaking || synthesizer.isPaused || isPlaying else { return }
        synthesizer.stopSpeaking(at: .immediate)
        activeUtterance = nil
        isPlaying = false
        deactivateAudioSessionIfNeeded()
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        DispatchQueue.main.async { [weak self] in
            self?.completePlaybackIfCurrent(utterance)
        }
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        DispatchQueue.main.async { [weak self] in
            self?.completePlaybackIfCurrent(utterance)
        }
    }

    private func completePlaybackIfCurrent(_ utterance: AVSpeechUtterance) {
        guard activeUtterance === utterance else { return }
        activeUtterance = nil
        isPlaying = false
        deactivateAudioSessionIfNeeded()
    }

    private func prepareAudioSessionForPlayback() -> Bool {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
            try audioSession.setActive(true)
            ownsAudioSession = true
            return true
        } catch {
            isPlaying = false
            return false
        }
    }

    private func deactivateAudioSessionIfNeeded() {
        guard ownsAudioSession else { return }
        ownsAudioSession = false
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
}

private extension LessonStep {
    var isModelPhraseStep: Bool {
        showsPreSpeechPlayback
    }

    func speechTarget(selectedChoice: String? = nil) -> String {
        if turnIntent == .chooseAndSay,
           let selectedChoice,
           !selectedChoice.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return selectedChoice
        }

        return expectedSpeechText
    }

    var voicePromptTitle: String {
        turnIntent.rawValue
    }

    var voicePromptContext: String? {
        nil
    }

    var speakableContext: String {
        helper.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? visiblePromptText : helper
    }

    func voiceReadyInstruction(selectedChoice: String? = nil) -> String {
        switch turnIntent {
        case .listenAndRepeat:
            return "Listen first, then repeat it."
        case .sayThisSentence:
            return "Read it aloud when you are ready."
        case .answerOutLoud:
            return "Say it in your own words when you are ready."
        case .chooseAndSay:
            if let selectedChoice,
               !selectedChoice.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return "Say your selected answer out loud."
            }
            return "Choose an option first."
        }
    }

    var feedbackMode: String {
        switch turnIntent {
        case .listenAndRepeat:
            return "Listen and repeat"
        case .sayThisSentence:
            return "Read aloud"
        case .answerOutLoud:
            return "Say it in your own words"
        case .chooseAndSay:
            return "Choose and say"
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
    @State private var selectedChoicesByStepID: [String: String] = [:]
    @State private var speechErrorMessage: String?
    @StateObject private var speechRecognizer = SpeechRecognitionService()
    @StateObject private var speechPlayback = SpeechPlaybackService()
    @State private var savedLineReactionTrigger = 0
    @State private var didApplyLaunchSpeechState = false
    @State private var didApplyLaunchCompletionState = false
    @State private var completionResult: CompletionCelebrationResult?
    @State private var turnEntranceVisible = false

    init(lesson: BeginnerLesson, state: LearningState) {
        _lesson = State(initialValue: lesson)
        let launchStepIndex = ConverlaxLaunchArguments.lessonStepIndex(in: ProcessInfo.processInfo.arguments)
        let initialStepIndex = launchStepIndex.map { min(max($0, 0), max(lesson.steps.count - 1, 0)) }
            ?? state.resumeStepIndex(for: lesson)
        _stepIndex = State(initialValue: initialStepIndex)
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
                            savedLineReactionTrigger: savedLineReactionTrigger,
                            speechPhase: speechPhase,
                            transcript: transcript,
                            voiceLevel: speechRecognizer.voiceLevel,
                            speechFeedback: speechFeedback,
                            speechErrorMessage: speechErrorMessage,
                            isLastTurn: stepIndex == lesson.steps.count - 1,
                            canGoToPreviousTurn: stepIndex > 0,
                            canGoToNextTurn: stepIndex < furthestAvailableStepIndex,
                            isModelPhrasePlaying: speechPlayback.isPlaying,
                            selectedChoice: selectedChoice,
                            onSaveLine: saveCurrentLine,
                            onSelectChoice: { selectedChoicesByStepID[step.id] = $0 },
                            onPlayback: playCurrentModelPhrase,
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
            applyLaunchCompletionStateIfNeeded()
            guard !completed else { return }
            applyLaunchSpeechStateIfNeeded()
            restoreCurrentTurnFeedbackIfNeeded()
            syncSavedCurrentLine()
            withAnimation(reduceMotion ? nil : .easeOut(duration: 0.32).delay(0.04)) {
                turnEntranceVisible = true
            }
        }
        .onDisappear {
            speechPlayback.stop()
            speechRecognizer.cancelRecording()
        }
    }

    private var step: LessonStep {
        lesson.steps[stepIndex]
    }

    private var selectedChoice: String? {
        selectedChoicesByStepID[step.id]
    }

    private var progress: Double {
        Double(stepIndex + 1) / Double(lesson.steps.count)
    }

    private var furthestAvailableStepIndex: Int {
        if state.isCompleted(lesson) {
            return max(lesson.steps.count - 1, 0)
        }

        return min(max(state.resumeStepIndex(for: lesson), stepIndex), max(lesson.steps.count - 1, 0))
    }

    private var isCurrentTurnReadyForSpeech: Bool {
        step.turnIntent != .chooseAndSay || selectedChoice != nil
    }

    private var currentSavedLine: SavedLine {
        SavedLine(
            id: "lesson-\(step.id)",
            text: step.speechTarget(selectedChoice: selectedChoice),
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
        savedLineReactionTrigger += 1
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
            guard speechFeedback?.confidence ?? 0 >= minimumLessonTurnScore else {
                retryCurrentTurn()
                return
            }
            advanceAfterSpeechAcceptance()
        case .accepted:
            speechPhase = .ready
            transcript = ""
            speechFeedback = nil
            speechErrorMessage = nil
        }
    }

    private func cancelSpeech() {
        speechPlayback.stop()
        speechRecognizer.cancelRecording()
        speechPhase = .ready
        transcript = ""
        speechFeedback = nil
        speechErrorMessage = nil
    }

    private func retryCurrentTurn() {
        speechPlayback.stop()
        speechRecognizer.cancelRecording()
        withAnimation(reduceMotion ? nil : .easeOut(duration: 0.2)) {
            speechPhase = .ready
            transcript = ""
            speechFeedback = nil
            speechErrorMessage = nil
        }
    }

    private func moveToTurn(_ targetIndex: Int) {
        guard lesson.steps.indices.contains(targetIndex) else { return }
        speechPlayback.stop()
        speechRecognizer.cancelRecording()
        let targetStep = lesson.steps[targetIndex]
        let restoredFeedback = latestFeedback(for: targetStep)
        withAnimation(reduceMotion ? nil : .spring(response: 0.32, dampingFraction: 0.86)) {
            stepIndex = targetIndex
            savedCurrentLine = state.savedLines.contains { $0.id == "lesson-\(targetStep.id)" }
            speechPhase = restoredFeedback == nil ? .ready : .feedback
            transcript = restoredFeedback?.attemptedText ?? ""
            speechFeedback = restoredFeedback
            speechErrorMessage = nil
        }
    }

    private func startSpeechRecording() {
        guard isCurrentTurnReadyForSpeech else { return }

        speechPlayback.stop()
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
            speechErrorMessage = "Nothing clear was captured. Say one short sentence and try again."
            speechPhase = .noSpeech
            return
        }

        speechPhase = .transcript
    }

    private func playCurrentModelPhrase() {
        guard step.isModelPhraseStep else { return }
        speechPlayback.toggle(
            text: step.speechTarget(selectedChoice: selectedChoice),
            localeIdentifier: state.profile.targetLanguage.speechRecognitionLocaleIdentifier,
            voiceIdentifier: state.selectedLessonVoiceIdentifier
        )
    }

    @MainActor
    private func generateSpeechFeedback() async {
        let cleanTranscript = transcript.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanTranscript.isEmpty else {
            speechErrorMessage = "Nothing clear was captured. Say one short sentence and try again."
            speechPhase = .noSpeech
            return
        }

        speechPhase = .processing
        speechErrorMessage = nil

        let aiFeedback: AIFeedback
        do {
            aiFeedback = try await AIFeedbackService.shared.feedback(
                transcript: cleanTranscript,
                context: speechFeedbackContext(mode: step.feedbackMode, step: step)
            )
        } catch {
            speechErrorMessage = AIFeedbackService.fallbackMessage(for: error)
            speechPhase = .error
            return
        }

        let feedback = state.acceptSpeechPractice(
            lesson: lesson,
            step: step,
            transcript: cleanTranscript,
            mode: step.feedbackMode,
            aiFeedback: aiFeedback
        )
        turnFeedbackByStepID[step.id] = feedback
        speechFeedback = feedback
        speechPhase = .feedback
        speakMascotMoment(for: .lessonStrongAttempt(lessonID: lesson.id, confidence: feedback.confidence))
    }

    private func latestFeedback(for step: LessonStep) -> LearningFeedback? {
        if let feedback = turnFeedbackByStepID[step.id] {
            return feedback
        }

        return state.latestFeedback(for: step, in: lesson)
    }

    private func restoreCurrentTurnFeedbackIfNeeded() {
        guard speechPhase == .ready, transcript.isEmpty, speechFeedback == nil else { return }
        guard let restoredFeedback = latestFeedback(for: step) else { return }

        transcript = restoredFeedback.attemptedText
        speechFeedback = restoredFeedback
        speechPhase = .feedback
    }

    private func applyLaunchCompletionStateIfNeeded() {
        guard
            !didApplyLaunchCompletionState,
            ProcessInfo.processInfo.arguments.contains("-ConverlaxShowLessonCompletion")
        else { return }

        didApplyLaunchCompletionState = true
        let previousProfile = state.profile
        state.completeLesson(lesson)
        completionResult = state.completionCelebration(
            from: previousProfile,
            title: "Lesson complete",
            subtitle: "You finished \(lesson.title.lowercased())."
        )
        completed = true
    }

    private func advanceAfterSpeechAcceptance() {
        speechPlayback.stop()
        speechPhase = .accepted

        if stepIndex < lesson.steps.count - 1 {
            let nextStepIndex = stepIndex + 1
            let nextStep = lesson.steps[nextStepIndex]
            let restoredFeedback = latestFeedback(for: nextStep)
            state.saveLessonResume(lesson: lesson, stepIndex: nextStepIndex)
            withAnimation(reduceMotion ? nil : .spring(response: 0.35, dampingFraction: 0.86)) {
                stepIndex = nextStepIndex
                savedCurrentLine = state.savedLines.contains { $0.id == "lesson-\(nextStep.id)" }
                speechPhase = restoredFeedback == nil ? .ready : .feedback
                transcript = restoredFeedback?.attemptedText ?? ""
                speechFeedback = restoredFeedback
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
            withAnimation(reduceMotion ? nil : .spring(response: 0.35, dampingFraction: 0.86)) {
                completed = true
            }
            speakMascotMoment(for: .lessonCompletion(lessonID: lesson.id))
        }
    }

    private func speakMascotMoment(for event: MascotVoiceCelebrationEvent) {
        guard
            let moment = state.mascotVoiceMoment(
                for: event,
                isRecording: speechPhase == .requestingPermission || speechPhase == .recording
            )
        else { return }

        speechPlayback.speak(
            text: moment.text,
            localeIdentifier: state.profile.targetLanguage.speechRecognitionLocaleIdentifier,
            voiceIdentifier: state.selectedLessonVoiceIdentifier
        )
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
                mode: targetStep.feedbackMode
            )
            turnFeedbackByStepID[targetStep.id] = feedback
            speechFeedback = feedback
            speechPhase = .feedback
        case "permissionDenied", "permission":
            transcript = ""
            speechErrorMessage = "Voice practice needs Microphone and Speech Recognition. Allow access in Settings and try again."
            speechPhase = .permissionDenied
        default:
            break
        }
    }

    private func sampleTranscript(for step: LessonStep) -> String {
        let filledBlank = step.expectedSpeechText.replacingOccurrences(of: "___", with: step.correctAnswer ?? "coffee")
        return filledBlank.replacingOccurrences(of: "...", with: "Alex")
    }

    private func speechFeedbackContext(mode: String, step: LessonStep) -> AIFeedbackRequestContext {
        AIFeedbackRequestContext(
            mode: mode,
            lessonTitle: lesson.title,
            prompt: step.visiblePromptText,
            expectedPhrase: expectedPhrase(for: step),
            targetLanguage: state.profile.targetLanguage.rawValue,
            proficiencyLevel: state.profile.currentLevel.code,
            roleplayTitle: nil,
            roleplaySetting: nil,
            usefulPhrases: nil
        )
    }

    private func expectedPhrase(for step: LessonStep) -> String {
        if step.id == self.step.id {
            return step.speechTarget(selectedChoice: selectedChoice)
        }

        return step.expectedSpeechText
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
    let savedLineReactionTrigger: Int
    let speechPhase: SpeechPracticePhase
    let transcript: String
    let voiceLevel: Double
    let speechFeedback: LearningFeedback?
    let speechErrorMessage: String?
    let isLastTurn: Bool
    let canGoToPreviousTurn: Bool
    let canGoToNextTurn: Bool
    let isModelPhrasePlaying: Bool
    let selectedChoice: String?
    let onSaveLine: () -> Void
    let onSelectChoice: (String) -> Void
    let onPlayback: () -> Void
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
                savedLineReactionTrigger: savedLineReactionTrigger,
                isSaveVisible: !step.hidesExpectedAnswerBeforeSpeech,
                isPlaybackVisible: step.showsPreSpeechPlayback,
                isPlaying: isModelPhrasePlaying,
                selectedChoice: selectedChoice,
                accent: accent,
                onSaveLine: onSaveLine,
                onSelectChoice: onSelectChoice,
                onPlayback: onPlayback
            )

            SpeechPracticePanel(
                phase: speechPhase,
                transcript: transcript,
                feedback: speechFeedback,
                accent: accent,
                readyInstruction: step.voiceReadyInstruction(selectedChoice: selectedChoice),
                voiceLevel: voiceLevel,
                errorMessage: speechErrorMessage,
                primaryActionTitle: voiceActionTitle,
                secondaryActionTitle: retryActionTitle,
                isPrimaryAvailable: isSpeechPrimaryAvailable,
                disabledInstruction: disabledInstruction,
                onPrimary: onSpeechPrimary,
                onCancel: onSpeechCancel,
                onSecondary: onSpeechRetry
            )

        }
    }

    private var voiceActionTitle: String? {
        switch speechPhase {
        case .feedback:
            guard speechFeedback?.confidence ?? 0 >= minimumLessonTurnScore else {
                return "Try again"
            }
            return isLastTurn ? "Finish lesson" : "Next prompt"
        case .accepted:
            return isLastTurn ? "Finish lesson" : "Next prompt"
        default:
            return nil
        }
    }

    private var retryActionTitle: String? {
        guard speechPhase == .feedback, speechFeedback?.confidence ?? 0 >= minimumLessonTurnScore else {
            return nil
        }
        return "Try again"
    }

    private var isSpeechPrimaryAvailable: Bool {
        step.turnIntent != .chooseAndSay || selectedChoice != nil
    }

    private var disabledInstruction: String? {
        isSpeechPrimaryAvailable ? nil : "Choose an option first."
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
    let savedLineReactionTrigger: Int
    let isSaveVisible: Bool
    let isPlaybackVisible: Bool
    let isPlaying: Bool
    let selectedChoice: String?
    let accent: Color
    let onSaveLine: () -> Void
    let onSelectChoice: (String) -> Void
    let onPlayback: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(step.voicePromptTitle)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.secondary)
                        .accessibilityIdentifier("lesson-prompt-title")
                    Text(step.visiblePromptText)
                        .font(.title2.weight(.semibold))
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityIdentifier("lesson-prompt-text")
                    if let context = step.voicePromptContext {
                        Text(context)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                if isSaveVisible {
                    HStack(spacing: 8) {
                        ConverlaxMascotView(
                            state: .saved,
                            size: 34,
                            isAnimated: savedCurrentLine,
                            reactionTrigger: savedLineReactionTrigger
                        )
                        .opacity(savedCurrentLine ? 1 : 0)
                        .frame(width: 34, height: 34)
                        .accessibilityHidden(!savedCurrentLine)
                        .accessibilityIdentifier("saved-line-reaction-mascot")

                        Button(action: onSaveLine) {
                            Image(systemName: savedCurrentLine ? "bookmark.fill" : "bookmark")
                                .font(.headline.weight(.semibold))
                                .foregroundStyle(savedCurrentLine ? Color.primaryBlue : Color.secondary)
                                .frame(width: 36, height: 36)
                                .background(Color.appBackground.opacity(0.76), in: Circle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(savedCurrentLine ? "Unsave line" : "Save line")
                    }
                    .frame(width: 78, alignment: .trailing)
                }
            }

            if !step.choices.isEmpty {
                VStack(spacing: 8) {
                    ForEach(step.choices, id: \.self) { choice in
                        ChoiceLineButton(
                            title: choice,
                            isSelected: selectedChoice == choice,
                            accent: accent,
                            action: { onSelectChoice(choice) }
                        )
                    }
                }
            }

            if isPlaybackVisible {
                Button(action: onPlayback) {
                    HStack(spacing: 10) {
                        Image(systemName: isPlaying ? "stop.fill" : "speaker.wave.2.fill")
                            .font(.headline.weight(.bold))
                            .frame(width: 28, height: 28)
                            .background(Color.claySurface.opacity(0.75), in: Circle())

                        Text(isPlaying ? "Stop audio" : "Play sentence")
                            .font(.headline.weight(.bold))

                        Spacer(minLength: 0)
                    }
                    .foregroundStyle(accent)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(accent.opacity(0.12), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(accent.opacity(0.24), lineWidth: 1)
                    }
                }
                .buttonStyle(.plain)
                .accessibilityLabel(isPlaying ? "Stop sentence audio" : "Play sentence audio")
                .accessibilityIdentifier("lesson-audio-playback")
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

private struct ChoiceLineButton: View {
    let title: String
    let isSelected: Bool
    let accent: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(isSelected ? accent : Color.secondary)
                    .frame(width: 24, height: 24)

                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.converlaxInk)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 11)
            .background(Color.appBackground.opacity(isSelected ? 0.92 : 0.58), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(isSelected ? accent.opacity(0.55) : Color.clayStroke.opacity(0.75), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}

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

    private func moveToTurn(_ targetIndex: Int) {
        guard lesson.steps.indices.contains(targetIndex) else { return }
        speechRecognizer.cancelRecording()
        let targetStep = lesson.steps[targetIndex]
        withAnimation(.spring(response: 0.32, dampingFraction: 0.86)) {
            stepIndex = targetIndex
            savedCurrentLine = state.savedLines.contains { $0.id == "lesson-\(targetStep.id)" }
            speechPhase = .ready
            transcript = ""
            speechFeedback = nil
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

        speechFeedback = state.acceptSpeechPractice(
            lesson: lesson,
            step: step,
            transcript: cleanTranscript,
            mode: "Speaking practice",
            aiFeedback: aiFeedback
        )
        speechPhase = .feedback
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
            speechFeedback = state.acceptSpeechPractice(
                lesson: lesson,
                step: targetStep,
                transcript: transcript,
                mode: "Speaking practice"
            )
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

enum LessonModeKind {
    case video
    case speakingDrill
    case qa

    var title: String {
        switch self {
        case .video: "Watch and repeat"
        case .speakingDrill: "Practice speaking"
        case .qa: "Speak answers"
        }
    }

    var shortTitle: String {
        switch self {
        case .video: "Watch"
        case .speakingDrill: "Speak"
        case .qa: "Answers"
        }
    }

    var completionTitle: String {
        switch self {
        case .video: "Lesson watched"
        case .speakingDrill: "Speaking practice complete"
        case .qa: "Answer practice complete"
        }
    }

    var modeName: String {
        switch self {
        case .video: "Watch and repeat"
        case .speakingDrill: "Practice speaking"
        case .qa: "Spoken answer practice"
        }
    }

    var sourcePrefix: String {
        switch self {
        case .video: "video"
        case .speakingDrill: "speaking-drill"
        case .qa: "qa"
        }
    }

    var primarySymbol: String {
        switch self {
        case .video: "play.rectangle.fill"
        case .speakingDrill: "mic.circle.fill"
        case .qa: "mic.circle.fill"
        }
    }

    func steps(from lesson: BeginnerLesson) -> [LessonStep] {
        switch self {
        case .video:
            return lesson.steps
        case .speakingDrill:
            let speakingSteps = lesson.steps.filter { $0.kind == .speak }
            return speakingSteps.isEmpty ? lesson.steps : speakingSteps
        case .qa:
            let questionSteps = lesson.steps.filter { $0.kind == .choice }
            return questionSteps.isEmpty ? lesson.steps : questionSteps
        }
    }
}

struct LessonModePlayerView: View {
    let mode: LessonModeKind
    let lesson: BeginnerLesson
    @ObservedObject var state: LearningState
    @Environment(\.dismiss) private var dismiss
    @State private var stepIndex = 0
    @State private var completed = false
    @State private var audioEnabled = false
    @State private var savedStepIDs: Set<String> = []
    @State private var speechPhase: SpeechPracticePhase = .ready
    @State private var transcript = ""
    @State private var speechFeedback: LearningFeedback?
    @State private var speechErrorMessage: String?
    @StateObject private var speechRecognizer = SpeechRecognitionService()
    @State private var didApplyLaunchSpeechState = false
    @State private var completionResult: CompletionCelebrationResult?

    private var modeSteps: [LessonStep] {
        mode.steps(from: lesson)
    }

    private var step: LessonStep {
        modeSteps[min(stepIndex, max(modeSteps.count - 1, 0))]
    }

    private var progress: Double {
        guard !modeSteps.isEmpty else { return 1 }
        return completed ? 1 : Double(stepIndex + 1) / Double(modeSteps.count)
    }

    private var savedCurrentLine: Bool {
        savedStepIDs.contains(step.id) || state.savedLines.contains { $0.id == currentSavedLine.id }
    }

    private var currentSavedLine: SavedLine {
        SavedLine(
            id: "\(mode.sourcePrefix)-\(step.id)",
            text: step.speakablePrompt,
            translation: step.speakableContext,
            source: "\(mode.title): \(lesson.title)",
            note: "Saved from \(mode.title.lowercased())."
        )
    }

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 18) {
                LessonProgressBar(progress: progress)

                if completed {
                    ScrollView {
                        if let completionResult {
                            CompletionCelebrationView(result: completionResult)
                                .padding(.bottom, 8)
                        }
                    }
                    .scrollIndicators(.hidden)

                    Button(action: dismiss.callAsFunction) {
                        Text("Back to course")
                    }
                    .buttonStyle(PrimaryButtonStyle())
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            LessonModeHeader(mode: mode, lesson: lesson, stepIndex: stepIndex, stepCount: modeSteps.count)
                            modeStepContent
                        }
                        .padding(.bottom, currentInteraction == .speech ? 108 : 20)
                    }
                    .scrollIndicators(.hidden)

                    if currentInteraction != .speech {
                        Button(action: advance) {
                            Text(buttonTitle)
                        }
                        .buttonStyle(PrimaryButtonStyle(isEnabled: canAdvance))
                        .disabled(!canAdvance)
                    }
                }
            }
            .padding(20)
        }
        .navigationTitle(mode.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    audioEnabled.toggle()
                } label: {
                    Image(systemName: audioEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                }
                .accessibilityLabel(audioEnabled ? "Turn off lesson audio" : "Turn on lesson audio")
            }
        }
        .onChange(of: speechRecognizer.transcript) { _, newValue in
            transcript = newValue
        }
        .onAppear {
            applyLaunchSpeechStateIfNeeded()
        }
        .onDisappear {
            speechRecognizer.cancelRecording()
        }
    }

    @ViewBuilder
    private var modeStepContent: some View {
        switch mode {
        case .video:
            VideoLessonStepCard(
                lesson: lesson,
                step: step,
                audioEnabled: audioEnabled,
                savedCurrentLine: savedCurrentLine,
                speechPhase: speechPhase,
                transcript: transcript,
                voiceLevel: speechRecognizer.voiceLevel,
                speechFeedback: speechFeedback,
                speechErrorMessage: speechErrorMessage,
                onToggleAudio: { audioEnabled.toggle() },
                onSaveLine: saveCurrentLine,
                onSpeechPrimary: advanceSpeechState,
                onSpeechCancel: resetSpeech
            )
        case .speakingDrill:
            SpeakingDrillStepCard(
                step: step,
                accent: lesson.accent.color,
                savedCurrentLine: savedCurrentLine,
                speechPhase: speechPhase,
                transcript: transcript,
                voiceLevel: speechRecognizer.voiceLevel,
                speechFeedback: speechFeedback,
                speechErrorMessage: speechErrorMessage,
                onSaveLine: saveCurrentLine,
                onSpeechPrimary: advanceSpeechState,
                onSpeechCancel: resetSpeech
            )
        case .qa:
            SpeakingDrillStepCard(
                step: step,
                accent: lesson.accent.color,
                savedCurrentLine: savedCurrentLine,
                speechPhase: speechPhase,
                transcript: transcript,
                voiceLevel: speechRecognizer.voiceLevel,
                speechFeedback: speechFeedback,
                speechErrorMessage: speechErrorMessage,
                onSaveLine: saveCurrentLine,
                onSpeechPrimary: advanceSpeechState,
                onSpeechCancel: resetSpeech
            )
        }
    }

    private var canAdvance: Bool {
        switch currentInteraction {
        case .speech:
            return speechPhase == .accepted
        case .read:
            return true
        }
    }

    private var buttonTitle: String {
        return stepIndex == modeSteps.count - 1 ? "Finish \(mode.shortTitle.lowercased())" : "Continue"
    }

    private var currentInteraction: LessonModeInteraction {
        switch mode {
        case .video:
            return step.kind == .teach ? .read : .speech
        case .speakingDrill:
            return .speech
        case .qa:
            return .speech
        }
    }

    private func advance() {
        guard canAdvance else { return }

        if stepIndex < modeSteps.count - 1 {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.86)) {
                stepIndex += 1
                resetStepState()
            }
        } else {
            let previousProfile = state.profile
            state.completeLesson(lesson)
            completionResult = state.completionCelebration(
                from: previousProfile,
                title: mode.completionTitle,
                subtitle: "You finished \(lesson.title.lowercased()) in \(mode.shortTitle.lowercased()) mode.",
                savedItemsCreated: max(savedStepIDs.count, state.profile.savedLearningObjects.count - previousProfile.savedLearningObjects.count)
            )
            withAnimation(.spring(response: 0.35, dampingFraction: 0.86)) {
                completed = true
            }
        }
    }

    private func saveCurrentLine() {
        let line = currentSavedLine
        if savedCurrentLine {
            state.removeLine(line)
            savedStepIDs.remove(step.id)
            return
        }

        state.saveLine(line)
        savedStepIDs.insert(step.id)
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
            speechPhase = .accepted
            advanceAfterSpeechAcceptance()
        case .accepted:
            resetSpeech()
        }
    }

    private func advanceAfterSpeechAcceptance() {
        if stepIndex < modeSteps.count - 1 {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.86)) {
                stepIndex += 1
                resetStepState()
            }
        } else {
            let previousProfile = state.profile
            state.completeLesson(lesson)
            completionResult = state.completionCelebration(
                from: previousProfile,
                title: mode.completionTitle,
                subtitle: "You finished \(lesson.title.lowercased()) in \(mode.shortTitle.lowercased()) mode.",
                savedItemsCreated: max(savedStepIDs.count, state.profile.savedLearningObjects.count - previousProfile.savedLearningObjects.count)
            )
            withAnimation(.spring(response: 0.35, dampingFraction: 0.86)) {
                completed = true
            }
        }
    }

    private func resetSpeech() {
        speechRecognizer.cancelRecording()
        speechPhase = .ready
        transcript = ""
        speechFeedback = nil
        speechErrorMessage = nil
    }

    private func resetStepState() {
        resetSpeech()
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
                context: speechFeedbackContext(mode: mode.modeName, step: step)
            )
        } catch {
            aiFeedback = nil
            speechErrorMessage = AIFeedbackService.fallbackMessage(for: error)
        }

        speechFeedback = state.acceptSpeechPractice(
            lesson: lesson,
            step: step,
            transcript: cleanTranscript,
            mode: mode.modeName,
            aiFeedback: aiFeedback
        )
        speechPhase = .feedback
    }
    private func applyLaunchSpeechStateIfNeeded() {
        guard
            !didApplyLaunchSpeechState,
            ProcessInfo.processInfo.converlaxInitialHomeRoute == homeRouteArgument,
            let launchState = ProcessInfo.processInfo.converlaxArgumentValue(after: "-ConverlaxLessonSpeechState"),
            let targetIndex = modeSteps.firstIndex(where: { $0.kind == .speak || $0.kind == .choice })
        else { return }

        didApplyLaunchSpeechState = true
        let targetStep = modeSteps[targetIndex]
        stepIndex = targetIndex
        resetStepState()

        switch launchState {
        case "recording":
            transcript = ""
            speechPhase = .recording
        case "transcript", "transcriptReady":
            transcript = sampleTranscript(for: targetStep)
            speechPhase = .transcript
        case "feedback":
            transcript = sampleTranscript(for: targetStep)
            speechFeedback = state.acceptSpeechPractice(
                lesson: lesson,
                step: targetStep,
                transcript: transcript,
                mode: mode.modeName
            )
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

    private var homeRouteArgument: String {
        switch mode {
        case .video:
            "videoLesson"
        case .speakingDrill:
            "speakingDrill"
        case .qa:
            "qaLesson"
        }
    }
}

private enum LessonModeInteraction {
    case speech
    case read
}

private struct LessonModeHeader: View {
    let mode: LessonModeKind
    let lesson: BeginnerLesson
    let stepIndex: Int
    let stepCount: Int

    var body: some View {
        HStack(spacing: 14) {
            ConverlaxAssetBadge(kind: lesson.visualAsset, size: 58)
            VStack(alignment: .leading, spacing: 4) {
                Text(mode.title)
                    .font(.title3.weight(.bold))
                Text("\(lesson.title) • Step \(stepIndex + 1) of \(max(stepCount, 1))")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: mode.primarySymbol)
                .font(.title2.weight(.semibold))
                .foregroundStyle(lesson.accent.color)
        }
        .padding(16)
        .background(Color.claySurface, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

private struct VideoLessonStepCard: View {
    let lesson: BeginnerLesson
    let step: LessonStep
    let audioEnabled: Bool
    let savedCurrentLine: Bool
    let speechPhase: SpeechPracticePhase
    let transcript: String
    let voiceLevel: Double
    let speechFeedback: LearningFeedback?
    let speechErrorMessage: String?
    let onToggleAudio: () -> Void
    let onSaveLine: () -> Void
    let onSpeechPrimary: () -> Void
    let onSpeechCancel: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ZStack(alignment: .bottomLeading) {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [lesson.accent.color.opacity(0.82), Color.converlaxInk.opacity(0.86)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 178)

                VStack(alignment: .leading, spacing: 10) {
                    Image(systemName: audioEnabled ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 52, weight: .semibold))
                    Text(step.title)
                        .font(.title3.weight(.bold))
                    Text("Watch the line, listen once, then answer or repeat.")
                        .font(.footnote.weight(.semibold))
                        .opacity(0.86)
                }
                .foregroundStyle(.white)
                .padding(18)
            }

            Button(action: onToggleAudio) {
                Label(audioEnabled ? "Pause clip" : "Play clip", systemImage: audioEnabled ? "pause.fill" : "speaker.wave.2.fill")
            }
            .buttonStyle(SecondaryButtonStyle())

            LessonPromptBlock(step: step, savedCurrentLine: savedCurrentLine, onSaveLine: onSaveLine)

            switch step.kind {
            case .teach:
                EmptyView()
            case .choice, .speak:
                SpeechPracticePanel(
                    phase: speechPhase,
                    transcript: transcript,
                    feedback: speechFeedback,
                    accent: lesson.accent.color,
                    voiceLevel: voiceLevel,
                    errorMessage: speechErrorMessage,
                    onPrimary: onSpeechPrimary,
                    onCancel: onSpeechCancel
                )

            }
        }
    }
}

private struct SpeakingDrillStepCard: View {
    let step: LessonStep
    let accent: Color
    let savedCurrentLine: Bool
    let speechPhase: SpeechPracticePhase
    let transcript: String
    let voiceLevel: Double
    let speechFeedback: LearningFeedback?
    let speechErrorMessage: String?
    let onSaveLine: () -> Void
    let onSpeechPrimary: () -> Void
    let onSpeechCancel: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            LessonPromptBlock(step: step, savedCurrentLine: savedCurrentLine, onSaveLine: onSaveLine)

            SpeechPracticePanel(
                phase: speechPhase,
                transcript: transcript,
                feedback: speechFeedback,
                accent: accent,
                voiceLevel: voiceLevel,
                errorMessage: speechErrorMessage,
                onPrimary: onSpeechPrimary,
                onCancel: onSpeechCancel
            )

        }
    }
}

private struct LessonPromptBlock: View {
    let step: LessonStep
    let savedCurrentLine: Bool
    let onSaveLine: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(step.speakablePrompt)
                .font(.title2.weight(.semibold))
                .frame(maxWidth: .infinity, alignment: .leading)

            if let context = step.voicePromptContext {
                Text(context)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                Text(step.helper)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Button(action: onSaveLine) {
                Label(savedCurrentLine ? "Unsave line" : "Save line", systemImage: savedCurrentLine ? "bookmark.fill" : "bookmark")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.primaryBlue)
                    .symbolEffect(.bounce, value: savedCurrentLine)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(savedCurrentLine ? "Unsave line" : "Save line")
        }
        .padding(18)
        .background(Color.claySurface, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
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
                voiceLevel: voiceLevel,
                errorMessage: speechErrorMessage,
                primaryActionTitle: voiceActionTitle,
                onPrimary: onSpeechPrimary,
                onCancel: onSpeechCancel
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


private struct CompletionPanel: View {
    let lesson: BeginnerLesson
    let savedWords: [SavedWord]

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            ConverlaxMascotView(state: .celebrating, size: 104)

            VStack(alignment: .leading, spacing: 8) {
                Text("Lesson complete")
                    .font(.largeTitle.weight(.bold))
                Text("You finished \(lesson.title.lowercased()).")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: 10) {
                Text("Saved from this lesson")
                    .font(.headline.weight(.semibold))
                ForEach(savedWords) { word in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(word.term)
                                .font(.subheadline.weight(.semibold))
                            Text(word.translation)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Image(systemName: "bookmark.fill")
                            .foregroundStyle(Color.primaryBlue)
                    }
                    .padding(.vertical, 6)
                    .accessibilityElement(children: .combine)
                }
            }
        }
        .padding(20)
    }
}

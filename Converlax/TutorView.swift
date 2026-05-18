import SwiftUI

struct TutorView: View {
    private let firstPrompt = "Say one English sentence."
    private let maxTurns = 4

    @ObservedObject var state: LearningState
    @State private var voicePhase: SpeechPracticePhase = .ready
    @State private var showHistory = false
    @State private var lastFeedback: LearningFeedback?
    @State private var noInputNotice: String?
    @State private var feedbackNotice: String?
    @State private var voiceTranscript = ""
    @State private var voiceErrorMessage: String?
    @State private var savedMessageIDs: Set<UUID> = []
    @State private var isTutorResponding = false
    @State private var currentPrompt = "Say one English sentence."
    @State private var turnCount = 0
    @State private var conversationTurns: [TutorTurnRecord] = []
    @State private var isPracticeComplete = false
    @StateObject private var speechRecognizer = SpeechRecognitionService()
    @State private var didApplyLaunchVoiceState = false
    @State private var messages: [ChatMessage] = []

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                messageList
                composer
            }
        }
        .navigationTitle("Tutor")
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Menu {
                    Button("Chat history") {
                        showHistory = true
                    }
                    Button(state.profile.tutorAudioEnabled ? "Turn off Tutor audio" : "Turn on Tutor audio") {
                        state.setTutorAudioEnabled(!state.profile.tutorAudioEnabled)
                    }
                    Button("Saved messages") {
                        showHistory = true
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
                .accessibilityLabel("Tutor menu")
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: resetConversation) {
                    Image(systemName: "clock.arrow.circlepath")
                }
                .accessibilityLabel("Reset conversation")
            }
        }
        .sheet(isPresented: $showHistory) {
            TutorHistorySheet(messages: messages, state: state)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .onChange(of: speechRecognizer.transcript) { _, newValue in
            voiceTranscript = newValue
        }
        .onAppear {
            applyLaunchVoiceStateIfNeeded()
        }
        .onDisappear {
            speechRecognizer.cancelRecording()
        }
    }

    private var messageList: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ForEach(messages) { message in
                    ChatBubble(message: message, isSaved: savedMessageIDs.contains(message.id)) {
                        saveMessage(message)
                    }
                }

                if let noInputNotice {
                    Label(noInputNotice, systemImage: "exclamationmark.triangle.fill")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Color.warmAmber)
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.warmAmber.opacity(0.12), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .accessibilityIdentifier("tutor-no-input-notice")
                }

                if let lastWord = state.courseSavedWords.last {
                    TranslationCard(word: lastWord)
                }

                if let lastFeedback {
                    LearningFeedbackCard(feedback: lastFeedback)
                        .accessibilityIdentifier("tutor-correction-card")
                    if lastFeedback.feedbackProvider.hasPrefix("local"), let feedbackNotice {
                        FeedbackFallbackNotice(text: feedbackNotice)
                    }
                }
            }
            .padding(20)
        }
    }

    private var composer: some View {
        VStack(alignment: .leading, spacing: 12) {
            if isPracticeComplete {
                TutorSessionSummary(
                    improvedPhrase: summaryImprovedPhrase,
                    mistakePattern: summaryMistakePattern,
                    reviewItem: summaryReviewItem,
                    nextAction: summaryNextAction
                )
                .accessibilityIdentifier("tutor-session-summary")

                Button(action: resetConversation) {
                    Label("Finish practice", systemImage: "checkmark")
                }
                .buttonStyle(PrimaryButtonStyle())
            } else {
                SpeechPracticePanel(
                    phase: voicePhase,
                    transcript: voiceTranscript,
                    feedback: nil,
                    accent: .primaryBlue,
                    prompt: currentPrompt,
                    voiceLevel: speechRecognizer.voiceLevel,
                    errorMessage: voiceErrorMessage,
                    primaryActionTitle: tutorVoiceActionTitle,
                    onPrimary: handleVoicePrimaryAction,
                    onCancel: cancelVoice
                )
            }
        }
        .padding(20)
        .background(.regularMaterial)
    }

    private var tutorVoiceActionTitle: String? {
        if isPracticeComplete {
            return "Finish practice"
        }

        switch voicePhase {
        case .ready where turnCount > 0:
            return "Answer prompt"
        case .transcript:
            return "Send to Tutor"
        default:
            return nil
        }
    }

    private func handleVoicePrimaryAction() {
        if isPracticeComplete {
            resetConversation()
            return
        }

        switch voicePhase {
        case .permissionNeeded, .permissionDenied, .ready, .paused, .noSpeech, .error:
            startVoiceRecording()
        case .recording:
            finishVoiceRecording()
        case .requestingPermission, .processing, .transcribing:
            break
        case .transcript:
            Task { await submitVoiceTranscript() }
        case .feedback, .accepted:
            resetVoiceInput()
        }
    }

    private func startVoiceRecording() {
        if let transcript = uiTestVoiceTranscript() {
            voiceTranscript = transcript
            voiceErrorMessage = nil
            feedbackNotice = nil
            voicePhase = .transcript
            return
        }

        voicePhase = .requestingPermission
        voiceTranscript = ""
        voiceErrorMessage = nil
        feedbackNotice = nil

        Task {
            let started = await speechRecognizer.startRecording(localeIdentifier: state.profile.targetLanguage.speechRecognitionLocaleIdentifier)
            if started {
                voicePhase = .recording
            } else {
                voiceErrorMessage = speechRecognizer.errorMessage
                voicePhase = speechRecognizer.errorMessage?.localizedCaseInsensitiveContains("permission") == true ? .permissionDenied : .error
            }
        }
    }

    private func finishVoiceRecording() {
        voicePhase = .transcribing
        let recognizedText = speechRecognizer.stopRecording()
        voiceTranscript = recognizedText

        guard !recognizedText.isEmpty else {
            voiceErrorMessage = "No clear speech was captured. Try again a little slower and closer to the mic."
            voicePhase = .noSpeech
            return
        }

        voicePhase = .transcript
    }

    @MainActor
    private func submitVoiceTranscript() async {
        let recognizedText = voiceTranscript.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !recognizedText.isEmpty else {
            voiceErrorMessage = "No clear speech was captured. Try again a little slower and closer to the mic."
            voicePhase = .noSpeech
            return
        }

        noInputNotice = nil
        voicePhase = .processing
        voiceErrorMessage = nil

        await submitTutorMessage(recognizedText)
    }

    @MainActor
    private func submitTutorMessage(_ userMessage: String) async {
        let clean = userMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !clean.isEmpty else { return }
        guard !isTutorResponding else { return }

        let answeredPrompt = currentPrompt
        isTutorResponding = true
        withAnimation {
            noInputNotice = nil
            feedbackNotice = nil
            messages.append(ChatMessage(text: clean, isUser: true))
        }

        let tutorResponse: TutorAIResponse
        let isFallback: Bool
        do {
            tutorResponse = try await TutorAIService.shared.response(message: clean, context: tutorContext(answeredPrompt: answeredPrompt))
            isFallback = false
        } catch {
            tutorResponse = TutorAIService.fallbackResponse(for: clean)
            feedbackNotice = TutorAIService.fallbackMessage(for: error)
            isFallback = true
        }

        withAnimation(.spring(response: 0.3, dampingFraction: 0.86)) {
            messages.append(ChatMessage(
                text: tutorResponse.tutorReply,
                isUser: false,
                canSave: true,
                savedArtifactText: savedArtifactText(for: tutorResponse),
                savedArtifactNote: savedArtifactNote(for: clean)
            ))
            lastFeedback = state.recordTutorCorrection(for: clean, tutorResponse: tutorResponse, isFallback: isFallback)
            let turn = TutorTurnRecord(
                prompt: answeredPrompt,
                learnerMessage: clean,
                tutorReply: tutorResponse.tutorReply,
                correction: tutorResponse.correction,
                naturalAlternative: tutorResponse.naturalAlternative,
                nextPrompt: normalizedPrompt(tutorResponse.nextPrompt),
                savedPhrase: tutorResponse.savedPhrase,
                reviewItem: tutorResponse.reviewItem,
                mistakePatternTitle: turnMistakePatternTitle(for: clean, response: tutorResponse),
                sessionSummary: tutorResponse.sessionSummary
            )
            conversationTurns.append(turn)
            let nextTurnCount = turnCount + 1
            turnCount = nextTurnCount
            if nextTurnCount >= maxTurns {
                isPracticeComplete = true
                state.recordTutorSessionSummary(
                    improvedPhrase: summaryImprovedPhraseText(for: turn),
                    mistakePatternTitle: summaryMistakePatternText(for: turn),
                    reviewItem: summaryReviewItemText(for: turn),
                    nextAction: summaryNextActionText(for: turn),
                    turnCount: nextTurnCount
                )
            } else {
                currentPrompt = normalizedPrompt(tutorResponse.nextPrompt)
            }
            resetVoiceInput()
            isTutorResponding = false
        }
    }

    private func tutorContext(answeredPrompt: String) -> TutorAIRequestContext {
        let recentMessages = messages.suffix(6).map { message in
            TutorAIMessageContext(role: message.isUser ? "learner" : "tutor", text: message.text)
        }
        let recentSavedPhrases = (state.savedLines.prefix(6).map(\.text) + conversationTurns.map(\.savedPhrase))
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        return TutorAIRequestContext(
            targetLanguage: state.profile.targetLanguage.rawValue,
            proficiencyLevel: state.profile.currentLevel.code,
            currentLessonTitle: state.currentLesson.title,
            currentLessonPrompt: state.currentLesson.steps.first?.prompt,
            currentPrompt: currentPrompt,
            answeredPrompt: answeredPrompt,
            turnCount: turnCount,
            maxTurns: maxTurns,
            nextRecommendation: state.nextRecommendation.title,
            recentSavedPhrases: Array(recentSavedPhrases.prefix(8)),
            recentTutorMessages: Array(recentMessages),
            conversationTurns: conversationTurns.suffix(5).map(\.context),
            recurringMistakes: state.tutorMistakeContext,
            recentReviewPerformance: state.tutorReviewPerformanceContext
        )
    }

    private func cancelVoice() {
        speechRecognizer.cancelRecording()
        resetVoiceInput()
    }

    private func resetVoiceInput() {
        voicePhase = .ready
        voiceTranscript = ""
        voiceErrorMessage = nil
    }

    private var summaryImprovedPhrase: String {
        summaryImprovedPhraseText(for: conversationTurns.last)
    }

    private var summaryMistakePattern: String {
        summaryMistakePatternText(for: conversationTurns.last)
    }

    private var summaryReviewItem: String {
        summaryReviewItemText(for: conversationTurns.last)
    }

    private var summaryNextAction: String {
        summaryNextActionText(for: conversationTurns.last)
    }

    private func summaryImprovedPhraseText(for turn: TutorTurnRecord?) -> String {
        nonEmpty(turn?.sessionSummary.improvedPhrase)
            ?? nonEmpty(turn?.naturalAlternative)
            ?? nonEmpty(turn?.savedPhrase)
            ?? turn?.correction
            ?? "One clear English sentence."
    }

    private func summaryMistakePatternText(for turn: TutorTurnRecord?) -> String {
        nonEmpty(turn?.sessionSummary.mistakePattern)
            ?? nonEmpty(turn?.mistakePatternTitle)
            ?? state.recurringMistakePatterns.first?.title
            ?? "Complete answers"
    }

    private func summaryReviewItemText(for turn: TutorTurnRecord?) -> String {
        nonEmpty(turn?.sessionSummary.savedReviewItem)
            ?? nonEmpty(turn?.reviewItem.prompt)
            ?? "Review today's corrected phrase."
    }

    private func summaryNextActionText(for turn: TutorTurnRecord?) -> String {
        nonEmpty(turn?.sessionSummary.nextPrompt)
            ?? nonEmpty(turn?.nextPrompt)
            ?? state.nextRecommendation.title
    }

    private func nonEmpty(_ text: String?) -> String? {
        let trimmed = text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return trimmed.isEmpty ? nil : trimmed
    }

    private func turnMistakePatternTitle(for learnerSentence: String, response: TutorAIResponse) -> String? {
        if let title = nonEmpty(response.mistakePattern.title) {
            return title
        }

        return MistakePatternDetector
            .detect(learnerSentence: learnerSentence, correctedSentence: response.correction)?
            .title
    }

    private func saveMessage(_ message: ChatMessage) {
        let savedText = nonEmpty(message.savedArtifactText) ?? message.text
        let savedNote = nonEmpty(message.savedArtifactNote) ?? "Saved from Tutor chat."
        let line = SavedLine(
            id: "tutor-\(stableMessageID(savedText))",
            text: savedText,
            translation: savedText,
            source: "Tutor",
            note: savedNote
        )
        state.saveLine(line)
        savedMessageIDs.insert(message.id)
    }

    private func savedArtifactText(for response: TutorAIResponse) -> String {
        nonEmpty(response.savedPhrase) ?? response.correction
    }

    private func savedArtifactNote(for learnerMessage: String) -> String {
        guard let learnerMessage = nonEmpty(learnerMessage) else {
            return "Tutor correction."
        }

        return "Corrected from: \(learnerMessage)"
    }

    private func resetConversation() {
        speechRecognizer.cancelRecording()
        messages = []
        lastFeedback = nil
        noInputNotice = nil
        feedbackNotice = nil
        savedMessageIDs = []
        currentPrompt = firstPrompt
        turnCount = 0
        conversationTurns = []
        isPracticeComplete = false
        resetVoiceInput()
    }

    private func applyLaunchVoiceStateIfNeeded() {
        guard
            !didApplyLaunchVoiceState,
            let launchState = ProcessInfo.processInfo.converlaxArgumentValue(after: "-ConverlaxTutorVoiceState")
        else { return }

        didApplyLaunchVoiceState = true
        voiceTranscript = ""
        voiceErrorMessage = nil
        noInputNotice = nil

        switch launchState {
        case "recording":
            voicePhase = .recording
        case "transcript", "response":
            voiceTranscript = "How do I ask for directions politely?"
            voicePhase = .transcript
        case "finalTranscript":
            turnCount = maxTurns - 1
            currentPrompt = "Tell me one more detail."
            voiceTranscript = "I went to work yesterday and I was tired"
            voicePhase = .transcript
        case "permissionDenied", "permission":
            voiceErrorMessage = "Voice practice needs Microphone and Speech Recognition. Enable access in Settings, then try again."
            voicePhase = .permissionDenied
        default:
            voicePhase = .ready
        }
    }

    private func stableMessageID(_ text: String) -> String {
        let characters = text.lowercased().map { character -> Character in
            character.isLetter || character.isNumber ? character : "-"
        }
        let collapsed = String(characters).split(separator: "-").joined(separator: "-")
        return String(collapsed.prefix(48)).isEmpty ? "message" : String(collapsed.prefix(48))
    }

    private func normalizedPrompt(_ prompt: String) -> String {
        let trimmed = prompt.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return firstPrompt }

        let firstLine = trimmed.components(separatedBy: .newlines).first ?? trimmed
        let clean = firstLine.trimmingCharacters(in: .whitespacesAndNewlines)
        return clean.isEmpty ? firstPrompt : String(clean.prefix(96))
    }

    private func uiTestVoiceTranscript() -> String? {
        let arguments = ProcessInfo.processInfo.arguments
        guard arguments.contains("-ConverlaxUseUITestVoiceTranscript") else { return nil }

        if let transcript = ProcessInfo.processInfo.converlaxArgumentValue(after: "-ConverlaxUITestVoiceTranscript")?.trimmingCharacters(in: .whitespacesAndNewlines),
           !transcript.isEmpty {
            return transcript
        }

        return "I went to work yesterday and I was tired"
    }
}

private struct TutorTurnRecord: Identifiable, Hashable {
    let id = UUID()
    let prompt: String
    let learnerMessage: String
    let tutorReply: String
    let correction: String
    let naturalAlternative: String
    let nextPrompt: String
    let savedPhrase: String
    let reviewItem: TutorAIReviewItem
    let mistakePatternTitle: String?
    let sessionSummary: TutorAISessionSummary

    var context: TutorAITurnContext {
        TutorAITurnContext(
            prompt: prompt,
            learnerMessage: learnerMessage,
            tutorReply: tutorReply,
            nextPrompt: nextPrompt,
            savedPhrase: savedPhrase
        )
    }
}

private struct TutorSessionSummary: View {
    let improvedPhrase: String
    let mistakePattern: String
    let reviewItem: String
    let nextAction: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Practice complete")
                .font(.headline.weight(.bold))
                .foregroundStyle(Color.converlaxInk)

            TutorSummaryRow(title: "Phrase improved", value: improvedPhrase)
            TutorSummaryRow(title: "Pattern noticed", value: mistakePattern)
            TutorSummaryRow(title: "Review saved", value: reviewItem)
            TutorSummaryRow(title: "Next", value: nextAction)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.claySurface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Color.clayStroke.opacity(0.9)))
    }
}

private struct TutorSummaryRow: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.converlaxInk)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

private struct ChatBubble: View {
    let message: ChatMessage
    let isSaved: Bool
    let onSave: () -> Void

    var body: some View {
        HStack(alignment: .bottom) {
            if message.isUser {
                Spacer(minLength: 48)
            }

            VStack(alignment: .trailing, spacing: 6) {
                Text(message.text)
                    .font(.subheadline)
                    .foregroundStyle(message.isUser ? .white : .primary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 11)
                    .background(message.isUser ? Color.primaryBlue : .white, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .accessibilityIdentifier(message.isUser ? "tutor-learner-message" : "tutor-reply-message")

                if message.canSave && !message.isUser {
                    Button(action: onSave) {
                        Label(isSaved ? "Saved" : "Save phrase", systemImage: isSaved ? "bookmark.fill" : "bookmark")
                            .font(.caption.weight(.semibold))
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(Color.primaryBlue)
                    .disabled(isSaved)
                }
            }

            if !message.isUser {
                Spacer(minLength: 48)
            }
        }
    }
}

private struct TranslationCard: View {
    let word: SavedWord

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Saved phrase")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack {
                Image(systemName: "speaker.wave.2.fill")
                    .foregroundStyle(Color.primaryBlue)
                VStack(alignment: .leading, spacing: 2) {
                    Text(word.term)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(Color.primaryBlue)
                    Text(word.translation)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "bookmark.fill")
                    .foregroundStyle(Color.primaryBlue)
            }
            .padding(.vertical, 8)
        }
    }
}

private struct TutorHistorySheet: View {
    let messages: [ChatMessage]
    @ObservedObject var state: LearningState

    var body: some View {
        NavigationStack {
            List {
                Section("Chat history") {
                    ForEach(messages) { message in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(message.isUser ? "You" : "Tutor")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(.secondary)
                            Text(message.text)
                        }
                    }
                }
                Section("Saved lines") {
                    ForEach(state.savedLines.prefix(4)) { line in
                        Text(line.text)
                    }
                }
            }
            .navigationTitle("Tutor menu")
        }
    }
}

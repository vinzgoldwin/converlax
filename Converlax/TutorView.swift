import SwiftUI

struct TutorView: View {
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
    @StateObject private var speechRecognizer = SpeechRecognitionService()
    @State private var didApplyLaunchVoiceState = false
    @State private var messages = [
        ChatMessage(text: "Say one English sentence. I will help you make it clearer.", isUser: false)
    ]

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
        SpeechPracticePanel(
            phase: voicePhase,
            transcript: voiceTranscript,
            feedback: nil,
            accent: .primaryBlue,
            voiceLevel: speechRecognizer.voiceLevel,
            errorMessage: voiceErrorMessage,
            primaryActionTitle: tutorVoiceActionTitle,
            onPrimary: handleVoicePrimaryAction,
            onCancel: cancelVoice
        )
        .padding(20)
        .background(.regularMaterial)
    }

    private var tutorVoiceActionTitle: String? {
        switch voicePhase {
        case .transcript:
            "Send to Tutor"
        default:
            nil
        }
    }

    private func handleVoicePrimaryAction() {
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

        isTutorResponding = true
        withAnimation {
            noInputNotice = nil
            feedbackNotice = nil
            messages.append(ChatMessage(text: clean, isUser: true))
        }

        let tutorResponse: TutorAIResponse
        let isFallback: Bool
        do {
            tutorResponse = try await TutorAIService.shared.response(message: clean, context: tutorContext())
            isFallback = false
        } catch {
            tutorResponse = TutorAIService.fallbackResponse(for: clean)
            feedbackNotice = TutorAIService.fallbackMessage(for: error)
            isFallback = true
        }

        withAnimation(.spring(response: 0.3, dampingFraction: 0.86)) {
            messages.append(ChatMessage(text: tutorResponse.tutorReply, isUser: false, canSave: true))
            lastFeedback = state.recordTutorCorrection(for: clean, tutorResponse: tutorResponse, isFallback: isFallback)
            resetVoiceInput()
            isTutorResponding = false
        }
    }

    private func tutorContext() -> TutorAIRequestContext {
        let recentMessages = messages.suffix(6).map { message in
            TutorAIMessageContext(role: message.isUser ? "learner" : "tutor", text: message.text)
        }

        return TutorAIRequestContext(
            targetLanguage: state.profile.targetLanguage.rawValue,
            proficiencyLevel: state.profile.currentLevel.code,
            currentLessonTitle: state.currentLesson.title,
            currentLessonPrompt: state.currentLesson.steps.first?.prompt,
            nextRecommendation: state.nextRecommendation.title,
            recentSavedPhrases: state.savedLines.prefix(6).map(\.text),
            recentTutorMessages: Array(recentMessages)
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
    private func saveMessage(_ message: ChatMessage) {
        let line = SavedLine(
            id: "tutor-\(stableMessageID(message.text))",
            text: message.text,
            translation: "Saved Tutor response",
            source: "Tutor",
            note: "Saved from Tutor chat."
        )
        state.saveLine(line)
        savedMessageIDs.insert(message.id)
    }

    private func resetConversation() {
        speechRecognizer.cancelRecording()
        messages = [
            ChatMessage(text: "Say one English sentence. I will help you make it clearer.", isUser: false)
        ]
        lastFeedback = nil
        noInputNotice = nil
        feedbackNotice = nil
        savedMessageIDs = []
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

                if message.canSave && !message.isUser {
                    Button(action: onSave) {
                        Label(isSaved ? "Saved" : "Save line", systemImage: isSaved ? "bookmark.fill" : "bookmark")
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
        VStack(alignment: .leading, spacing: 10) {
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
            .padding(14)
            .background(Color.claySurface, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(Color.clayStroke))
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

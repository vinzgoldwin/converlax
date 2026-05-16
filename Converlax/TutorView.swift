import SwiftUI

struct TutorView: View {
    @ObservedObject var state: LearningState
    @State private var input = ""
    @State private var isVoiceInputActive = true
    @State private var voicePhase: SpeechPracticePhase = .ready
    @State private var showHistory = false
    @State private var lastFeedback: LearningFeedback?
    @State private var noInputNotice: String?
    @State private var feedbackNotice: String?
    @State private var voiceTranscript = ""
    @State private var fallbackText = ""
    @State private var showsTextFallback = false
    @State private var voiceErrorMessage: String?
    @State private var savedMessageIDs: Set<UUID> = []
    @StateObject private var speechRecognizer = SpeechRecognitionService()
    @State private var didApplyLaunchVoiceState = false
    @State private var messages = [
        ChatMessage(text: "Say a phrase from your current unit, or ask what to say next.", isUser: false),
        ChatMessage(text: "I will listen first, then give you a clearer English version.", isUser: false)
    ]

    private let suggestions = [
        "Practice my saved words",
        "How do I order coffee?",
        "Give me a travel phrase"
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
                    if lastFeedback.feedbackProvider == "local", let feedbackNotice {
                        FeedbackFallbackNotice(text: feedbackNotice)
                    }
                }
            }
            .padding(20)
        }
    }

    private var composer: some View {
        Group {
            if isVoiceInputActive {
                SpeechPracticePanel(
                    phase: voicePhase,
                    transcript: voiceTranscript,
                    feedback: nil,
                    accent: .primaryBlue,
                    errorMessage: voiceErrorMessage,
                    primaryActionTitle: tutorVoiceActionTitle,
                    onPrimary: handleVoicePrimaryAction,
                    onCancel: cancelVoice
                )
                .padding(20)
                .background(.regularMaterial)

                if offersTextFallback {
                    VoiceFallbackTextEntry(
                        text: $fallbackText,
                        isExpanded: showsTextFallback || voicePhase == .permissionDenied,
                        placeholder: "Type your Tutor message",
                        revealTitle: "Type instead",
                        submitTitle: "Send text",
                        onReveal: { showsTextFallback = true },
                        onSubmit: submitTextFallback
                    )
                    .padding(.horizontal, 20)
                    .padding(.bottom, 14)
                    .background(.regularMaterial)
                }
            } else {
                TextComposer(
                    input: $input,
                    suggestions: suggestions,
                    onSelectSuggestion: sendSuggestion,
                    onStartVoice: startVoice,
                    onSend: sendMessage
                )
            }
        }
    }

    private var tutorVoiceActionTitle: String? {
        switch voicePhase {
        case .transcript:
            "Send to Tutor"
        default:
            nil
        }
    }

    private func sendSuggestion(_ suggestion: String) {
        input = suggestion
        sendMessage()
    }

    private func startVoice() {
        noInputNotice = nil
        withAnimation(.spring(response: 0.3, dampingFraction: 0.86)) {
            isVoiceInputActive = true
        }
        startVoiceRecording()
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
        fallbackText = ""
        showsTextFallback = false
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

    private func sendMessage() {
        let clean = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !clean.isEmpty else {
            noInputNotice = "Start speaking, or type a fallback message if voice is not available."
            return
        }
        let word = state.courseSavedWords.last ?? state.courseLessons.first?.savedWords.first ?? BeginnerContent.lessons[0].savedWords[0]
        withAnimation {
            noInputNotice = nil
            feedbackNotice = nil
            messages.append(ChatMessage(text: clean, isUser: true))
            messages.append(ChatMessage(text: "\(word.term) means \(word.translation). Try it in this sentence: \(word.example)", isUser: false, canSave: true))
            messages.append(ChatMessage(text: "Next best action: \(state.nextRecommendation.title).", isUser: false, canSave: true))
        }
        lastFeedback = state.recordTutorCorrection(for: clean)
        input = ""
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

        let aiFeedback: AIFeedback?
        do {
            aiFeedback = try await AIFeedbackService.shared.feedback(
                transcript: recognizedText,
                context: AIFeedbackRequestContext(
                    mode: "Tutor voice",
                    lessonTitle: state.currentLesson.title,
                    prompt: "Tutor chat voice message",
                    expectedPhrase: nil,
                    targetLanguage: state.profile.targetLanguage.rawValue,
                    proficiencyLevel: state.profile.currentLevel.code,
                    roleplayTitle: nil,
                    roleplaySetting: nil,
                    usefulPhrases: state.savedLines.prefix(5).map(\.text)
                )
            )
        } catch {
            aiFeedback = nil
            feedbackNotice = AIFeedbackService.fallbackMessage(for: error)
        }

        withAnimation(.spring(response: 0.3, dampingFraction: 0.86)) {
            addTutorResponse(for: recognizedText, aiFeedback: aiFeedback)
            resetVoiceInput(keepVoiceReady: true)
        }
    }

    private func submitTextFallback() {
        let cleanText = fallbackText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanText.isEmpty else { return }

        noInputNotice = nil
        feedbackNotice = nil
        voiceTranscript = cleanText
        fallbackText = ""
        showsTextFallback = false
        withAnimation(.spring(response: 0.3, dampingFraction: 0.86)) {
            addTutorResponse(for: cleanText)
            resetVoiceInput(keepVoiceReady: true)
        }
    }

    private func addTutorResponse(for userMessage: String, aiFeedback: AIFeedback? = nil) {
        let lesson = state.currentLesson
        withAnimation {
            messages.append(ChatMessage(text: userMessage, isUser: true))
            messages.append(ChatMessage(text: "Yes. Your next lesson is \(lesson.title.lowercased()). Start with: \(lesson.steps.first?.prompt ?? lesson.title)", isUser: false, canSave: true))
        }
        lastFeedback = state.recordTutorCorrection(for: userMessage, aiFeedback: aiFeedback)
    }

    private func cancelVoice() {
        speechRecognizer.cancelRecording()
        resetVoiceInput()
    }

    private func resetVoiceInput(keepVoiceReady: Bool = false) {
        voicePhase = .ready
        isVoiceInputActive = keepVoiceReady
        voiceTranscript = ""
        fallbackText = ""
        showsTextFallback = false
        voiceErrorMessage = nil
    }

    private var offersTextFallback: Bool {
        switch voicePhase {
        case .permissionNeeded, .permissionDenied, .noSpeech, .error:
            true
        default:
            false
        }
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
        messages = Array(messages.prefix(2))
        lastFeedback = nil
        noInputNotice = nil
        feedbackNotice = nil
        savedMessageIDs = []
        resetVoiceInput(keepVoiceReady: true)
    }

    private func applyLaunchVoiceStateIfNeeded() {
        guard
            !didApplyLaunchVoiceState,
            let launchState = ProcessInfo.processInfo.converlaxArgumentValue(after: "-ConverlaxTutorVoiceState")
        else { return }

        didApplyLaunchVoiceState = true
        isVoiceInputActive = true
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
            voiceErrorMessage = "Voice practice needs Microphone and Speech Recognition. Use text now or enable access later."
            voicePhase = .permissionDenied
        default:
            isVoiceInputActive = false
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

private struct TextComposer: View {
    @Binding var input: String
    let suggestions: [String]
    let onSelectSuggestion: (String) -> Void
    let onStartVoice: () -> Void
    let onSend: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(suggestions, id: \.self) { suggestion in
                        Button {
                            onSelectSuggestion(suggestion)
                        } label: {
                            Text(suggestion)
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(Color.primaryBlue)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(Color.primaryBlue.opacity(0.1), in: Capsule())
                        }
                    }
                }
                .padding(.horizontal, 20)
            }

            HStack(spacing: 10) {
                Button(action: onStartVoice) {
                    Image(systemName: "mic.fill")
                        .frame(width: 42, height: 42)
                        .background(Color.primaryBlue.opacity(0.12), in: Circle())
                }
                .accessibilityLabel("Start voice input")

                TextField("Text fallback", text: $input)
                    .textFieldStyle(.plain)
                    .padding(.horizontal, 14)
                    .frame(height: 42)
                    .background(Color.claySurface, in: Capsule())

                Button(action: onSend) {
                    Image(systemName: "arrow.up")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.white)
                        .frame(width: 42, height: 42)
                        .background(Color.primaryBlue, in: Circle())
                }
                .disabled(input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .accessibilityLabel("Send message")
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 12)
        }
        .padding(.top, 12)
        .background(.regularMaterial)
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

import SwiftUI

struct TutorView: View {
    @ObservedObject var state: LearningState
    @State private var input = ""
    @State private var voiceState: TutorVoiceState = .keyboard
    @State private var showHistory = false
    @State private var lastFeedback: LearningFeedback?
    @State private var messages = [
        ChatMessage(text: "Hi there. I can help you rehearse the phrases from your current unit.", isUser: false),
        ChatMessage(text: "Ask me a question, tap a suggestion, or practice one of your saved words.", isUser: false)
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
    }

    private var messageList: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ForEach(messages) { message in
                    ChatBubble(message: message) {
                        saveMessage(message)
                    }
                }

                if let lastWord = state.courseSavedWords.last {
                    TranslationCard(word: lastWord)
                }

                if let lastFeedback {
                    LearningFeedbackCard(feedback: lastFeedback)
                        .accessibilityIdentifier("tutor-correction-card")
                }
            }
            .padding(20)
        }
    }

    private var composer: some View {
        Group {
            if voiceState != .keyboard {
                VoiceInputPanel(
                    state: voiceState,
                    onCancel: { voiceState = .keyboard },
                    onSubmit: {
                        if voiceState == .response {
                            voiceState = .keyboard
                        } else {
                            submitVoice()
                        }
                    }
                )
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

    private func sendSuggestion(_ suggestion: String) {
        input = suggestion
        sendMessage()
    }

    private func startVoice() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.86)) {
            voiceState = .recording
        }
    }

    private func sendMessage() {
        let clean = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !clean.isEmpty else { return }
        let word = state.courseSavedWords.last ?? state.courseLessons.first?.savedWords.first ?? BeginnerContent.lessons[0].savedWords[0]
        withAnimation {
            messages.append(ChatMessage(text: clean, isUser: true))
            messages.append(ChatMessage(text: "\(word.term) means \(word.translation). Try it in this sentence: \(word.example)", isUser: false, canSave: true))
            messages.append(ChatMessage(text: "Next best action: \(state.nextRecommendation).", isUser: false, canSave: true))
        }
        lastFeedback = state.recordTutorCorrection(for: clean)
        input = ""
    }

    private func submitVoice() {
        voiceState = .loading
        addTutorResponse()
        voiceState = .response
    }

    private func addTutorResponse() {
        let lesson = state.currentLesson
        withAnimation {
            messages.append(ChatMessage(text: "Can we rehearse my next lesson?", isUser: true))
            messages.append(ChatMessage(text: "Yes. Your next lesson is \(lesson.title.lowercased()). Start with: \(lesson.steps.first?.prompt ?? lesson.title)", isUser: false, canSave: true))
        }
        lastFeedback = state.recordTutorCorrection(for: "Can we rehearse my next lesson?")
    }

    private func saveMessage(_ message: ChatMessage) {
        let line = SavedLine(
            id: "tutor-\(message.text.hashValue)",
            text: message.text,
            translation: "Saved Tutor response",
            source: "Tutor",
            note: "Saved from Tutor chat."
        )
        state.saveLine(line)
    }

    private func resetConversation() {
        messages = Array(messages.prefix(2))
        lastFeedback = nil
    }
}

private enum TutorVoiceState: Equatable {
    case keyboard
    case recording
    case loading
    case response

    var title: String {
        switch self {
        case .keyboard: "Keyboard"
        case .recording: "Listening"
        case .loading: "Thinking"
        case .response: "Response ready"
        }
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

                TextField("Send a message", text: $input)
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
    let onSave: () -> Void

    var body: some View {
        HStack(alignment: .bottom) {
            if message.isUser {
                Spacer(minLength: 48)
            } else {
                ConverlaxMascotView(state: .avatar, size: 34, isAnimated: false)
            }

            VStack(alignment: .trailing, spacing: 6) {
                Text(message.text)
                    .font(.subheadline)
                    .foregroundStyle(message.isUser ? .white : .primary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 11)
                    .background(message.isUser ? Color.primaryBlue : .white, in: RoundedRectangle(cornerRadius: 16, style: .continuous))

                if message.canSave && !message.isUser {
                    Button(action: onSave) {
                        Label("Save line", systemImage: "bookmark.fill")
                            .font(.caption.weight(.semibold))
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(Color.primaryBlue)
                }
            }

            if !message.isUser {
                Spacer(minLength: 44)
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
            .background(Color.claySurface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Color.clayStroke))
        }
    }
}

private struct VoiceInputPanel: View {
    let state: TutorVoiceState
    let onCancel: () -> Void
    let onSubmit: () -> Void

    var body: some View {
        VStack(spacing: 22) {
            ConverlaxMascotView(state: mascotState, size: 112)
            Text(state.title)
                .font(.headline.weight(.semibold))
            ConverlaxWaveform(color: state == .loading ? .warmAmber : .primaryBlue, isActive: state != .response)

            HStack(spacing: 26) {
                Button(action: onCancel) {
                    Image(systemName: "xmark")
                        .foregroundStyle(.red)
                        .frame(width: 54, height: 54)
                        .background(Color.red.opacity(0.08), in: Circle())
                }
                .accessibilityLabel("Cancel voice input")

                Button(action: onSubmit) {
                    Image(systemName: state == .response ? "keyboard" : "arrow.up")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.white)
                        .frame(width: 72, height: 72)
                        .background(Color.primaryBlue, in: Circle())
                        .shadow(color: .primaryBlue.opacity(0.25), radius: 18, y: 8)
                }
                .accessibilityLabel("Send voice input")
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .background(.regularMaterial)
    }

    private var mascotState: ConverlaxMascotState {
        switch state {
        case .keyboard: .idle
        case .recording: .listening
        case .loading: .thinking
        case .response: .speaking
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

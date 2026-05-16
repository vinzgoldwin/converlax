import SwiftUI

extension Color {
    static let primaryBlue = Color(hex: 0x087D79)
    static let mintSuccess = Color(hex: 0x7ECBB6)
    static let warmAmber = Color(hex: 0xF4AA4D)
    static let violetAccent = Color(hex: 0x8E72D8)
    static let appBackground = Color(hex: 0xFCF6EB)
    static let converlaxTeal = Color(hex: 0x0F8E88)
    static let converlaxInk = Color(hex: 0x1F313B)
    static let converlaxCream = Color(hex: 0xFFF1CD)
    static let converlaxCoral = Color(hex: 0xF2785F)
    static let claySurface = Color(hex: 0xFFFDF8)
    static let clayStroke = Color(hex: 0xE9DDCC)

    init(hex: UInt, alpha: Double = 1) {
        let red = Double((hex >> 16) & 0xFF) / 255
        let green = Double((hex >> 8) & 0xFF) / 255
        let blue = Double(hex & 0xFF) / 255
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    var isEnabled = true
    @Environment(\.isEnabled) private var controlIsEnabled

    func makeBody(configuration: Configuration) -> some View {
        let active = isEnabled && controlIsEnabled

        configuration.label
            .font(.headline.weight(.semibold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 50)
            .padding(.horizontal, 18)
            .background(active ? Color.primaryBlue : Color.primaryBlue.opacity(0.45), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .shadow(color: active ? Color.primaryBlue.opacity(0.10) : .clear, radius: 8, y: 4)
            .contentShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.16), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.semibold))
            .foregroundStyle(isEnabled ? Color.primaryBlue : Color.secondary)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 48)
            .padding(.horizontal, 18)
            .background(Color.claySurface, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.clayStroke.opacity(isEnabled ? 1 : 0.5), lineWidth: 1)
            )
            .contentShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.16), value: configuration.isPressed)
    }
}

struct LessonProgressBar: View {
    let progress: Double

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule().fill(Color.clayStroke.opacity(0.65))
                Capsule()
                    .fill(Color.primaryBlue)
                    .frame(width: max(12, proxy.size.width * min(max(progress, 0), 1)))
            }
        }
        .frame(height: 6)
        .accessibilityLabel("Progress")
        .accessibilityValue("\(Int(min(max(progress, 0), 1) * 100)) percent")
    }
}

struct AvatarBadge: View {
    let symbol: String
    let color: Color

    var body: some View {
        ZStack {
            Circle()
                .fill(color.opacity(0.16))
            Image(systemName: symbol)
                .font(.headline.weight(.bold))
                .foregroundStyle(color)
        }
        .accessibilityHidden(true)
    }
}

enum ConverlaxMascotState: String {
    case idle
    case success
    case encouraging
    case listening
    case thinking
    case speaking
    case celebrating
    case tryAgain
    case waving
    case avatar

    var assetName: String {
        switch self {
        case .idle: "ClxMascotIdle"
        case .success: "ClxMascotSuccess"
        case .encouraging: "ClxMascotEncouraging"
        case .listening: "ClxMascotListening"
        case .thinking: "ClxMascotThinking"
        case .speaking: "ClxMascotSpeaking"
        case .celebrating: "ClxMascotCelebrating"
        case .tryAgain: "ClxMascotTryAgain"
        case .waving: "ClxMascotWaving"
        case .avatar: "ClxMascotAvatar"
        }
    }

    var accessibilityLabel: String {
        switch self {
        case .idle: "Melo, the Converlax mascot"
        case .success: "Melo showing success"
        case .encouraging: "Melo encouraging practice"
        case .listening: "Melo listening"
        case .thinking: "Melo thinking"
        case .speaking: "Melo speaking"
        case .celebrating: "Melo celebrating"
        case .tryAgain: "Melo suggesting another try"
        case .waving: "Melo waving"
        case .avatar: "Melo profile avatar"
        }
    }
}

enum ConverlaxAssetKind {
    case askInfo
    case bookAccommodation
    case askDirections
    case vocab
    case verbs
    case customLesson
    case freeTalk
    case roleplay
    case savedLines
    case review
    case community
    case favorites
    case historyUsage
    case activities
    case settings
    case streak
    case profile

    var assetName: String {
        switch self {
        case .askInfo: "ClxAssetAskInfo"
        case .bookAccommodation: "ClxAssetBookAccommodation"
        case .askDirections: "ClxAssetAskDirections"
        case .vocab: "ClxAssetVocab"
        case .verbs: "ClxAssetVerbs"
        case .customLesson: "ClxAssetCustomLesson"
        case .freeTalk: "ClxAssetFreeTalk"
        case .roleplay: "ClxAssetRoleplay"
        case .savedLines: "ClxAssetSavedLines"
        case .review: "ClxAssetReview"
        case .community: "ClxAssetCommunity"
        case .favorites: "ClxAssetFavorites"
        case .historyUsage: "ClxAssetHistoryUsage"
        case .activities: "ClxAssetActivities"
        case .settings: "ClxAssetSettings"
        case .streak: "ClxAssetStreak"
        case .profile: "ClxAssetProfile"
        }
    }

    var accessibilityLabel: String {
        switch self {
        case .askInfo: "Ask for information illustration"
        case .bookAccommodation: "Book accommodation illustration"
        case .askDirections: "Ask for directions illustration"
        case .vocab: "Vocab illustration"
        case .verbs: "Verbs illustration"
        case .customLesson: "Custom situation illustration"
        case .freeTalk: "Free talk illustration"
        case .roleplay: "Situation illustration"
        case .savedLines: "Saved lines illustration"
        case .review: "Review illustration"
        case .community: "Community illustration"
        case .favorites: "Favorites illustration"
        case .historyUsage: "History and usage illustration"
        case .activities: "Activities illustration"
        case .settings: "Settings illustration"
        case .streak: "Streak illustration"
        case .profile: "Profile illustration"
        }
    }
}

struct ConverlaxMascotView: View {
    let state: ConverlaxMascotState
    var size: CGFloat = 112
    var isAnimated = true
    @State private var animate = false

    var body: some View {
        Image(state.assetName)
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .scaleEffect(scale)
            .rotationEffect(rotation)
            .offset(y: verticalOffset)
            .shadow(color: shadowColor, radius: size * 0.08, y: size * 0.04)
            .animation(animation, value: animate)
            .onAppear { animate = isAnimated }
            .onChange(of: state) { _, _ in
                animate = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.04) {
                    animate = isAnimated
                }
            }
            .accessibilityLabel(state.accessibilityLabel)
    }

    private var scale: CGFloat {
        guard isAnimated else { return 1 }
        switch state {
        case .success, .celebrating:
            return animate ? 1.08 : 0.96
        case .listening, .speaking:
            return animate ? 1.03 : 0.98
        case .tryAgain:
            return animate ? 0.98 : 1.02
        default:
            return 1
        }
    }

    private var rotation: Angle {
        guard isAnimated else { return .zero }
        switch state {
        case .waving:
            return .degrees(animate ? 4 : -4)
        case .thinking:
            return .degrees(animate ? -2 : 2)
        case .tryAgain:
            return .degrees(animate ? -3 : 3)
        default:
            return .zero
        }
    }

    private var verticalOffset: CGFloat {
        guard isAnimated else { return 0 }
        switch state {
        case .idle, .encouraging, .avatar:
            return animate ? -4 : 2
        case .celebrating:
            return animate ? -8 : 0
        default:
            return 0
        }
    }

    private var animation: Animation {
        switch state {
        case .success, .celebrating:
            .spring(response: 0.34, dampingFraction: 0.48).repeatCount(2, autoreverses: true)
        case .listening, .speaking:
            .easeInOut(duration: 0.72).repeatForever(autoreverses: true)
        case .waving, .thinking, .tryAgain:
            .easeInOut(duration: 0.52).repeatForever(autoreverses: true)
        default:
            .easeInOut(duration: 2.6).repeatForever(autoreverses: true)
        }
    }

    private var shadowColor: Color {
        state == .avatar ? .clear : Color.converlaxInk.opacity(0.12)
    }
}

struct ConverlaxAssetBadge: View {
    let kind: ConverlaxAssetKind
    var size: CGFloat = 54

    var body: some View {
        Image(kind.assetName)
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .accessibilityLabel(kind.accessibilityLabel)
    }
}

extension BeginnerLesson {
    var visualAsset: ConverlaxAssetKind {
        if id.contains("direction") || id.contains("transport") || id.contains("ticket") { return .askDirections }
        if id.contains("hotel") || id.contains("travel") || id.contains("airport") { return .bookAccommodation }
        if id.contains("order") || id.contains("coffee") || id.contains("restaurant") || id.contains("shopping") { return .askInfo }
        if id.contains("small-talk") || id.contains("intro") || id.contains("free-time") || id.contains("plans") { return .freeTalk }
        if id.contains("work") || id.contains("meeting") || id.contains("phone") || id.contains("opinion") || id.contains("agree") { return .roleplay }
        if id.contains("help") || id.contains("problem") || id.contains("doctor") || id.contains("pharmacy") || id.contains("emergency") { return .askInfo }
        if id.contains("review") { return .review }
        return .customLesson
    }
}

extension RoleplayTopic {
    var visualAsset: ConverlaxAssetKind {
        switch id {
        case "travel":
            return .bookAccommodation
        case "food":
            return .askInfo
        case "work":
            return .roleplay
        default:
            return .askDirections
        }
    }
}

extension LessonStepKind {
    var visualAsset: ConverlaxAssetKind {
        switch self {
        case .teach:
            return .vocab
        case .choice:
            return .review
        case .speak:
            return .freeTalk
        }
    }
}

struct ConverlaxWaveform: View {
    var color: Color = .primaryBlue
    var isActive = true
    @State private var animate = false

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<14, id: \.self) { index in
                Capsule()
                    .fill(color.opacity(index.isMultiple(of: 3) ? 0.84 : 0.42))
                    .frame(width: 4, height: height(for: index))
            }
        }
        .frame(height: 42)
        .onAppear { animate = isActive }
        .onChange(of: isActive) { _, newValue in
            animate = newValue
        }
        .animation(.easeInOut(duration: 0.58).repeatForever(autoreverses: true), value: animate)
        .accessibilityHidden(true)
    }

    private func height(for index: Int) -> CGFloat {
        let base = CGFloat(10 + (index % 5) * 5)
        guard animate else { return base }
        return index.isMultiple(of: 2) ? base + 12 : max(8, base - 4)
    }
}

struct LevelBars: View {
    let active: Int

    var body: some View {
        HStack(alignment: .bottom, spacing: 3) {
            ForEach(1...5, id: \.self) { index in
                Capsule()
                    .fill(index <= active ? Color.primaryBlue : Color.clayStroke)
                    .frame(width: 4, height: CGFloat(8 + index * 4))
            }
        }
        .frame(height: 30)
        .accessibilityHidden(true)
    }
}

struct StatCard: View {
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.title2.weight(.bold))
                .foregroundStyle(color)
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .padding(.horizontal, 10)
        .background(Color.claySurface.opacity(0.62), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.clayStroke.opacity(0.6), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
    }
}

struct TutorPromptBar: View {
    var body: some View {
        HStack(spacing: 10) {
            ConverlaxMascotView(state: .encouraging, size: 42)

            Text("Create a custom lesson")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.primary)

            Spacer()

            Image(systemName: "mic.fill")
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color.claySurface, in: Capsule())
        .overlay(Capsule().stroke(Color.primaryBlue.opacity(0.22)))
        .accessibilityElement(children: .combine)
    }
}

struct LearningFeedbackCard: View {
    let feedback: LearningFeedback

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 10) {
                Label(feedbackTitle, systemImage: isSpeechFeedback ? "bubble.left.and.text.bubble.right.fill" : "sparkles")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(Color.primaryBlue)

                Spacer(minLength: 10)
            }

            if isSpeechFeedback {
                FeedbackConfidenceLine(confidence: feedback.confidence)
            }

            if let attemptText {
                FeedbackCoachLine(title: attemptTitle, text: attemptText, symbol: attemptSymbol, color: .primaryBlue)
            }

            if let naturalVersion {
                FeedbackCoachLine(title: "Natural version", text: naturalVersion, symbol: "quote.bubble.fill", color: .mintSuccess)
            }

            if let grammarCorrection {
                FeedbackCoachLine(title: "Grammar", text: grammarCorrection, symbol: "textformat", color: .primaryBlue)
            }

            if let vocabularyImprovement {
                FeedbackCoachLine(title: "Vocabulary", text: vocabularyImprovement, symbol: "character.book.closed.fill", color: .violetAccent)
            }

            if let coachTip {
                FeedbackCoachLine(title: "Coach tip", text: coachTip, symbol: "waveform", color: .warmAmber)
            }

            if let didWell {
                FeedbackCoachLine(title: "Did well", text: didWell, symbol: "checkmark.seal.fill", color: .mintSuccess)
            }

            if let tryNext {
                FeedbackCoachLine(title: "Try next", text: tryNext, symbol: "arrow.forward.circle.fill", color: .primaryBlue)
            }

            if let reviewItem {
                FeedbackCoachLine(title: "Review later", text: reviewItem, symbol: "arrow.clockwise", color: .warmAmber)
            }

            if let savedTakeaway {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "bookmark.fill")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color.primaryBlue)
                        .padding(.top, 2)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Saved takeaway")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(Color.primaryBlue)
                        Text(savedTakeaway)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.primary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.primaryBlue.opacity(0.08), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
        }
        .padding(16)
        .background(Color.claySurface, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(Color.clayStroke))
        .accessibilityIdentifier("learning-feedback-card")
        .accessibilityElement(children: .combine)
    }

    private var isSpeechFeedback: Bool {
        let source = feedback.source.lowercased()
        let prompt = feedback.promptText.lowercased()
        return source.contains("speaking") ||
            source.contains("voice") ||
            source.contains("talk") ||
            source.contains("tutor") ||
            source.contains("conversation") ||
            source.contains("roleplay") ||
            prompt.contains("roleplay")
    }

    private var feedbackTitle: String {
        isSpeechFeedback ? "Coach note" : "Quick feedback"
    }

    private var attemptTitle: String {
        isSpeechFeedback ? "You said" : "You chose"
    }

    private var attemptSymbol: String {
        isSpeechFeedback ? "mic.fill" : "checkmark.circle.fill"
    }

    private var attemptText: String? {
        clean(feedback.attemptedText)
    }

    private var naturalVersion: String? {
        cleanCoachText(feedback.naturalVersion) ?? cleanCoachText(feedback.betterPhrase) ?? cleanCoachText(feedback.correction)
    }

    private var grammarCorrection: String? {
        let grammar = cleanCoachText(feedback.grammarCorrection)
        guard grammar != naturalVersion else { return nil }
        return grammar
    }

    private var vocabularyImprovement: String? {
        clean(feedback.vocabularyImprovement)
    }

    private var coachTip: String? {
        let rawTips = [
            clean(feedback.pronunciationNotes) ?? clean(feedback.pronunciationTip),
            clean(feedback.fluencyTip)
        ]
        var tips: [String] = []
        for tip in rawTips.compactMap({ $0 }) where !tips.contains(tip) {
            tips.append(tip)
        }

        guard !tips.isEmpty else { return nil }
        return tips.joined(separator: " ")
    }

    private var didWell: String? {
        clean(feedback.didWell)
    }

    private var tryNext: String? {
        clean(feedback.tryNext.isEmpty ? feedback.nextAction : feedback.tryNext)
    }

    private var reviewItem: String? {
        guard
            let prompt = clean(feedback.reviewItemPrompt),
            let answer = clean(feedback.reviewItemAnswer)
        else { return nil }

        return "\(prompt) \(answer)"
    }

    private var savedTakeaway: String? {
        cleanCoachText(feedback.savedTakeaway)
    }

    private func clean(_ text: String) -> String? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    private func cleanCoachText(_ text: String) -> String? {
        guard var cleaned = clean(text) else { return nil }
        let prefixes = [
            "Correct it to:",
            "Correct answer:",
            "Correction:",
            "Use this clearer version:",
            "Clear attempt. Keep this version:",
            "Keep this clear version:",
            "Keep it short and complete:",
            "Tighten this line:",
            "Try:",
            "Use:"
        ]

        var didRemovePrefix = true
        while didRemovePrefix {
            didRemovePrefix = false
            for prefix in prefixes where cleaned.range(of: prefix, options: [.caseInsensitive, .anchored]) != nil {
                cleaned.removeFirst(prefix.count)
                cleaned = clean(cleaned) ?? ""
                didRemovePrefix = true
                break
            }
        }

        return clean(cleaned)
    }
}

struct FeedbackFallbackNotice: View {
    let text: String

    var body: some View {
        Label(text, systemImage: "wifi.slash")
            .font(.footnote.weight(.semibold))
            .foregroundStyle(Color.warmAmber)
            .padding(.vertical, 2)
            .fixedSize(horizontal: false, vertical: true)
    }
}

private struct FeedbackConfidenceLine: View {
    let confidence: Int

    private var progress: Double {
        Double(min(100, max(0, confidence))) / 100
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack {
                Text("Speaking confidence")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(min(100, max(0, confidence)))%")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color.primaryBlue)
            }

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.appBackground.opacity(0.82))
                    Capsule()
                        .fill(Color.primaryBlue)
                        .frame(width: proxy.size.width * progress)
                }
            }
            .frame(height: 7)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Speaking confidence \(confidence) percent")
    }
}

private struct FeedbackCoachLine: View {
    let title: String
    let text: String
    let symbol: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Label(title, systemImage: symbol)
                .font(.caption.weight(.bold))
                .foregroundStyle(color)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct SpeechPracticePanel: View {
    let phase: SpeechPracticePhase
    let transcript: String
    let feedback: LearningFeedback?
    let accent: Color
    var errorMessage: String?
    var primaryActionTitle: String? = nil
    let onPrimary: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            header

            VStack(spacing: 16) {
                VoiceInputOrb(
                    phase: phase,
                    accent: actionColor,
                    isActive: isListeningOrWorking
                )
                .frame(maxWidth: .infinity)

                transcriptSection
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: contentMinHeight, alignment: .center)

            if showsMessage {
                SpeechStateMessage(
                    symbol: messageSymbol,
                    text: messageText,
                    color: messageColor
                )
            }

            if let feedback {
                LearningFeedbackCard(feedback: feedback)
            }

            primaryActionButton
        }
        .padding(16)
        .background(Color.claySurface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(Color.clayStroke.opacity(0.9)))
        .accessibilityIdentifier("speech-practice-panel")
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 12) {
            SpeechStatusBadge(symbol: statusSymbol, color: statusColor)

            VStack(alignment: .leading, spacing: 3) {
                Text(phase.title)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(Color.converlaxInk)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
                Text(statusDetail)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 8)

            if showsCancel {
                Button(action: onCancel) {
                    Image(systemName: "xmark")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.secondary)
                        .frame(width: 34, height: 34)
                        .background(Color.appBackground.opacity(0.78), in: Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Cancel voice input")
            }
        }
    }

    @ViewBuilder
    private var transcriptSection: some View {
        if showsTranscript {
            SpeechTranscriptBlock(
                title: transcriptTitle,
                text: transcriptText,
                isLive: phase == .recording,
                accent: accent
            )
        } else if showsMessage {
            EmptyView()
        } else {
            Text(transcriptPlaceholder)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 12)
        }
    }

    private var primaryActionButton: some View {
        Button(action: onPrimary) {
            HStack(spacing: 10) {
                Image(systemName: primarySymbol)
                    .font(.headline.weight(.bold))
                Text(primaryActionTitle ?? phase.actionTitle)
                    .font(.headline.weight(.bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 56)
            .padding(.horizontal, 18)
            .background(actionColor, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .shadow(color: actionColor.opacity(isPrimaryEnabled ? 0.14 : 0), radius: 10, y: 6)
        }
        .buttonStyle(.plain)
        .disabled(!isPrimaryEnabled)
        .opacity(isPrimaryEnabled ? 1 : 0.58)
        .accessibilityIdentifier("speech-primary-action")
    }

    private var showsCancel: Bool {
        switch phase {
        case .ready, .requestingPermission, .processing, .transcribing, .feedback, .accepted:
            false
        case .permissionNeeded, .permissionDenied, .recording, .paused, .transcript, .noSpeech, .error:
            true
        }
    }

    private var isPrimaryEnabled: Bool {
        phase != .requestingPermission && phase != .processing && phase != .transcribing
    }

    private var isListeningOrWorking: Bool {
        phase == .recording || phase == .requestingPermission || phase == .processing || phase == .transcribing
    }

    private var showsTranscript: Bool {
        !transcript.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var contentMinHeight: CGFloat {
        showsMessage ? 116 : 142
    }

    private var transcriptTitle: String {
        phase == .recording ? "Live transcript" : "Final transcript"
    }

    private var transcriptText: String {
        transcript.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var transcriptPlaceholder: String {
        switch phase {
        case .recording:
            "Listening for your answer..."
        case .requestingPermission:
            "iOS will ask for microphone and speech recognition access before the first recording."
        case .processing, .transcribing:
            "Turning your speech into text..."
        case .transcript:
            "Your transcript will appear here before feedback."
        case .permissionNeeded, .permissionDenied:
            "Voice input is unavailable for now. You can still type this turn."
        case .noSpeech:
            "Nothing clear was captured."
        case .error:
            "The recording did not finish."
        default:
            "Tap start and answer out loud."
        }
    }

    private var statusSymbol: String {
        switch phase {
        case .requestingPermission:
            "hand.raised.fill"
        case .permissionNeeded, .permissionDenied:
            "mic.slash.fill"
        case .ready, .paused:
            "mic.fill"
        case .recording:
            "waveform"
        case .processing, .transcribing:
            "hourglass"
        case .transcript, .feedback:
            "text.bubble.fill"
        case .accepted:
            "checkmark.seal.fill"
        case .noSpeech:
            "waveform.slash"
        case .error:
            "exclamationmark.triangle.fill"
        }
    }

    private var primarySymbol: String {
        switch phase {
        case .recording:
            "stop.fill"
        case .transcript:
            "arrow.right"
        case .feedback, .accepted:
            "checkmark.circle.fill"
        case .permissionNeeded, .permissionDenied, .noSpeech, .error:
            "arrow.clockwise"
        case .requestingPermission, .processing, .transcribing:
            "hourglass"
        default:
            "mic.fill"
        }
    }

    private var actionColor: Color {
        switch phase {
        case .recording:
            Color.converlaxCoral
        case .permissionNeeded, .permissionDenied, .noSpeech, .error:
            Color.warmAmber
        default:
            accent
        }
    }

    private var statusColor: Color {
        switch phase {
        case .permissionNeeded, .permissionDenied, .noSpeech, .error:
            Color.warmAmber
        case .recording:
            Color.converlaxCoral
        case .transcript, .feedback, .accepted:
            Color.mintSuccess
        default:
            accent
        }
    }

    private var showsMessage: Bool {
        switch phase {
        case .permissionNeeded, .permissionDenied, .noSpeech, .error:
            true
        case .feedback:
            errorMessage != nil
        default:
            false
        }
    }

    private var messageSymbol: String {
        switch phase {
        case .permissionNeeded, .permissionDenied:
            "lock.fill"
        case .noSpeech:
            "waveform.slash"
        case .feedback:
            "wifi.slash"
        default:
            "exclamationmark.triangle.fill"
        }
    }

    private var messageColor: Color {
        phase == .permissionNeeded || phase == .permissionDenied ? accent : Color.warmAmber
    }

    private var messageText: String {
        switch phase {
        case .permissionNeeded, .permissionDenied:
            return errorMessage ?? "Voice practice needs Microphone and Speech Recognition. Allow access in Settings when you are ready, or use text for this turn."
        case .noSpeech:
            return errorMessage ?? "No speech was recognized. Hold the phone close, speak one clear sentence, and try again."
        case .feedback:
            return errorMessage ?? "Feedback is ready."
        default:
            return errorMessage ?? "Voice input stopped unexpectedly. Try again with a shorter answer."
        }
    }

    private var statusDetail: String {
        switch phase {
        case .requestingPermission:
            "Waiting for iOS permission."
        case .permissionNeeded, .permissionDenied:
            "Use text now or enable access later."
        case .ready:
            "Record one clear answer."
        case .recording:
            "Speak naturally. Your words appear below."
        case .paused:
            "Resume when you are ready."
        case .processing, .transcribing:
            "Checking your audio."
        case .transcript:
            "Review before feedback."
        case .feedback:
            "Use the feedback, then continue."
        case .accepted:
            "Saved for practice."
        case .noSpeech:
            "Try again with one clear sentence."
        case .error:
            "Retry when you are ready."
        }
    }
}

struct VoiceFallbackTextEntry: View {
    @Binding var text: String
    let isExpanded: Bool
    let placeholder: String
    var revealTitle = "Use text instead"
    var submitTitle = "Use text answer"
    let onReveal: () -> Void
    let onSubmit: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if isExpanded {
                TextField(placeholder, text: $text, axis: .vertical)
                    .textFieldStyle(.plain)
                    .lineLimit(2...4)
                    .padding(12)
                    .background(Color.appBackground.opacity(0.72), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Color.clayStroke.opacity(0.8), lineWidth: 1)
                    )

                Button(submitTitle, action: onSubmit)
                    .buttonStyle(SecondaryButtonStyle())
                    .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            } else {
                Button(action: onReveal) {
                    Label(revealTitle, systemImage: "keyboard")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.primaryBlue)
                        .frame(maxWidth: .infinity, minHeight: 44)
                }
                .buttonStyle(.plain)
                .background(Color.claySurface.opacity(0.72), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.clayStroke.opacity(0.7), lineWidth: 1)
                )
            }
        }
        .accessibilityIdentifier("voice-text-fallback")
    }
}

private struct SpeechStatusBadge: View {
    let symbol: String
    let color: Color

    var body: some View {
        ZStack {
            Circle()
                .fill(color.opacity(0.14))
            Image(systemName: symbol)
                .font(.headline.weight(.bold))
                .foregroundStyle(color)
        }
        .frame(width: 44, height: 44)
        .accessibilityHidden(true)
    }
}

private struct VoiceInputOrb: View {
    let phase: SpeechPracticePhase
    let accent: Color
    let isActive: Bool

    var body: some View {
        ZStack {
            Circle()
                .fill(accent.opacity(phase == .recording ? 0.16 : 0.11))
                .frame(width: 108, height: 108)

            if isActive {
                Circle()
                    .stroke(accent.opacity(0.18), lineWidth: 10)
                    .frame(width: 92, height: 92)
            }

            Circle()
                .fill(accent)
                .frame(width: 68, height: 68)
                .shadow(color: accent.opacity(0.16), radius: 14, y: 8)

            Image(systemName: orbSymbol)
                .font(.system(size: 25, weight: .bold))
                .foregroundStyle(.white)

            if isActive {
                VoiceActivityRing(color: accent, phase: phase)
                    .frame(width: 124, height: 124)
            }
        }
        .frame(width: 132, height: 132)
        .accessibilityHidden(true)
    }

    private var orbSymbol: String {
        switch phase {
        case .recording:
            "stop.fill"
        case .requestingPermission:
            "hand.raised.fill"
        case .processing, .transcribing:
            "waveform"
        case .transcript, .feedback, .accepted:
            "checkmark"
        case .permissionNeeded, .permissionDenied:
            "mic.slash.fill"
        case .noSpeech:
            "waveform.slash"
        case .error:
            "arrow.clockwise"
        default:
            "mic.fill"
        }
    }
}

private struct VoiceActivityRing: View {
    let color: Color
    let phase: SpeechPracticePhase
    @State private var rotate = false

    var body: some View {
        Circle()
            .trim(from: 0.08, to: 0.32)
            .stroke(
                color.opacity(0.68),
                style: StrokeStyle(lineWidth: 4, lineCap: .round)
            )
            .rotationEffect(.degrees(rotate ? 360 : 0))
            .opacity(phase == .recording ? 1 : 0.62)
            .onAppear { rotate = true }
            .animation(.linear(duration: phase == .recording ? 1.35 : 2.4).repeatForever(autoreverses: false), value: rotate)
    }
}

private struct SpeechTranscriptBlock: View {
    let title: String
    let text: String
    let isLive: Bool
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Circle()
                    .fill(isLive ? Color.converlaxCoral : accent)
                    .frame(width: 7, height: 7)
                Text(title)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
            }

            Text(text)
                .font(.body.weight(.semibold))
                .foregroundStyle(Color.converlaxInk)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.appBackground.opacity(0.74), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(Color.clayStroke.opacity(0.65)))
        .accessibilityLabel(title)
        .accessibilityValue(text)
    }
}

private struct SpeechStateMessage: View {
    let symbol: String
    let text: String
    let color: Color

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: symbol)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(color)
                .frame(width: 22)
            Text(text)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(Color.converlaxInk)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(color.opacity(0.11), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

struct LearningObjectRow: View {
    let object: SavedLearningObject
    var actionTitle = "Review"
    let action: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            AvatarBadge(symbol: symbol, color: color)
                .frame(width: 42, height: 42)

            VStack(alignment: .leading, spacing: 5) {
                Text(object.text)
                    .font(.subheadline.weight(.semibold))
                Text(object.translation)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("\(object.kind.rawValue) · \(object.source)")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(Color.primaryBlue)
            }

            Spacer()

            Button(actionTitle, action: action)
                .font(.caption.weight(.bold))
                .buttonStyle(.plain)
                .foregroundStyle(Color.primaryBlue)
        }
        .padding(.vertical, 6)
    }

    private var symbol: String {
        switch object.kind {
        case .word:
            "character.book.closed.fill"
        case .mistake:
            "arrow.clockwise"
        case .tutorMessage:
            "sparkles"
        case .roleplayPhrase:
            "person.2.wave.2.fill"
        default:
            "bookmark.fill"
        }
    }

    private var color: Color {
        object.kind == .mistake ? .converlaxCoral : .primaryBlue
    }
}

struct SessionSummaryPanel: View {
    let summary: LearningSessionSummary

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Session summary", systemImage: "doc.text.magnifyingglass")
                .font(.headline.weight(.semibold))
                .foregroundStyle(Color.primaryBlue)

            Text(summary.transcript)
                .font(.subheadline)
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.appBackground.opacity(0.72), in: RoundedRectangle(cornerRadius: 14, style: .continuous))

            if !summary.strongPhrases.isEmpty {
                PhraseList(title: "Strong phrases", phrases: summary.strongPhrases, color: .mintSuccess)
            }

            if !summary.weakPhrases.isEmpty {
                PhraseList(title: "Review next", phrases: summary.weakPhrases, color: .converlaxCoral)
            }

            Text(summary.nextRecommendation)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .background(Color.claySurface, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

struct CompletionCelebrationView: View {
    let result: CompletionCelebrationResult
    var mascotState: ConverlaxMascotState = .celebrating

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .center, spacing: 14) {
                ConverlaxMascotView(state: mascotState, size: 86)

                VStack(alignment: .leading, spacing: 6) {
                    Text(result.title)
                        .font(.title2.weight(.bold))
                    Text(result.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            VStack(spacing: 10) {
                CompletionResultMetricRow(
                    symbol: "sparkles",
                    title: "XP earned",
                    value: result.xpEarned > 0 ? "+\(result.xpEarned) XP" : "No new XP",
                    color: .warmAmber
                )

                CompletionLevelProgressRow(result: result)

                CompletionResultMetricRow(
                    symbol: "bookmark.fill",
                    title: "Saved items created",
                    value: "\(result.savedItemsCreated)",
                    color: .primaryBlue
                )
            }

            CompletionNextActionRow(result: result)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.claySurface, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.clayStroke.opacity(0.72), lineWidth: 1)
        )
        .accessibilityIdentifier("completion-celebration")
    }
}

private struct CompletionResultMetricRow: View {
    let symbol: String
    let title: String
    let value: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: symbol)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(color)
                .frame(width: 28, height: 28)
                .background(color.opacity(0.14), in: Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.subheadline.weight(.semibold))
            }

            Spacer(minLength: 8)
        }
        .padding(12)
        .background(Color.appBackground.opacity(0.58), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

private struct CompletionLevelProgressRow: View {
    let result: CompletionCelebrationResult

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack(spacing: 12) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(Color.mintSuccess)
                    .frame(width: 28, height: 28)
                    .background(Color.mintSuccess.opacity(0.16), in: Circle())

                VStack(alignment: .leading, spacing: 2) {
                    Text(result.levelProgressTitle)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.secondary)
                    Text(result.levelProgressDetail)
                        .font(.subheadline.weight(.semibold))
                }

                Spacer(minLength: 8)
            }

            ZStack(alignment: .leading) {
                LessonProgressBar(progress: result.levelProgressAfter)
                GeometryReader { proxy in
                    Rectangle()
                        .fill(Color.converlaxInk.opacity(0.42))
                        .frame(width: 2, height: 12)
                        .offset(x: max(0, min(proxy.size.width - 2, proxy.size.width * result.levelProgressBefore)))
                }
                .frame(height: 12)
                .allowsHitTesting(false)
            }
            .frame(height: 12)
        }
        .padding(12)
        .background(Color.appBackground.opacity(0.58), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

private struct CompletionNextActionRow: View {
    let result: CompletionCelebrationResult

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "arrow.forward.circle.fill")
                .font(.title3.weight(.semibold))
                .foregroundStyle(Color.primaryBlue)

            VStack(alignment: .leading, spacing: 3) {
                Text("Next suggested action")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
                Text(result.nextActionTitle)
                    .font(.subheadline.weight(.semibold))
                Text(result.nextActionDetail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 8)
        }
        .padding(12)
        .background(Color.primaryBlue.opacity(0.08), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

private struct PhraseList: View {
    let title: String
    let phrases: [String]
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption.weight(.bold))
                .foregroundStyle(color)
            ForEach(phrases, id: \.self) { phrase in
                Text(phrase)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct SkillProgressStrip: View {
    let progress: [SkillProgress]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Learning progress")
                .font(.headline.weight(.semibold))

            ForEach(progress.prefix(4)) { item in
                HStack(spacing: 10) {
                    Text(item.title)
                        .font(.caption.weight(.semibold))
                        .frame(width: 126, alignment: .leading)
                    LessonProgressBar(progress: Double(item.confidence) / 100)
                    Text("\(item.confidence)%")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.secondary)
                        .frame(width: 42, alignment: .trailing)
                }
            }
        }
        .padding(16)
        .background(Color.claySurface, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

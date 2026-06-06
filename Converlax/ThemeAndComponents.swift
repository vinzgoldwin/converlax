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

struct CalmPressButtonStyle: ButtonStyle {
    var cornerRadius: CGFloat = 14
    var highlightColor: Color = .primaryBlue

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(highlightColor.opacity(configuration.isPressed ? 0.08 : 0))
            )
            .scaleEffect(configuration.isPressed ? 0.985 : 1)
            .animation(.easeOut(duration: 0.16), value: configuration.isPressed)
    }
}

private struct ConverlaxListSurfaceModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(Color.appBackground.ignoresSafeArea())
            .foregroundStyle(Color.converlaxInk)
            .tint(Color.primaryBlue)
    }
}

extension View {
    func converlaxListSurface() -> some View {
        modifier(ConverlaxListSurfaceModifier())
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
        .animation(.easeOut(duration: 0.36), value: progress)
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
    case encouraging
    case thinking
    case celebrating
    case waving
    case avatar

    var assetName: String {
        switch self {
        case .idle: "ClxMascotIdle"
        case .encouraging: "ClxMascotEncouraging"
        case .thinking: "ClxMascotThinking"
        case .celebrating: "ClxMascotCelebrating"
        case .waving: "ClxMascotWaving"
        case .avatar: "ClxMascotAvatar"
        }
    }

    var accessibilityLabel: String {
        switch self {
        case .idle: "Melo, the Converlax mascot"
        case .encouraging: "Melo encouraging practice"
        case .thinking: "Melo thinking"
        case .celebrating: "Melo celebrating"
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
    case customLesson
    case freeTalk
    case roleplay
    case savedLines
    case review
    case historyUsage
    case settings
    case streak

    var assetName: String {
        switch self {
        case .askInfo: "ClxAssetAskInfo"
        case .bookAccommodation: "ClxAssetBookAccommodation"
        case .askDirections: "ClxAssetAskDirections"
        case .vocab: "ClxAssetVocab"
        case .customLesson: "ClxAssetCustomLesson"
        case .freeTalk: "ClxAssetFreeTalk"
        case .roleplay: "ClxAssetRoleplay"
        case .savedLines: "ClxAssetSavedLines"
        case .review: "ClxAssetReview"
        case .historyUsage: "ClxAssetHistoryUsage"
        case .settings: "ClxAssetSettings"
        case .streak: "ClxAssetStreak"
        }
    }

    var accessibilityLabel: String {
        switch self {
        case .askInfo: "Ask for information illustration"
        case .bookAccommodation: "Book accommodation illustration"
        case .askDirections: "Ask for directions illustration"
        case .vocab: "Vocab illustration"
        case .customLesson: "Custom situation illustration"
        case .freeTalk: "Free talk illustration"
        case .roleplay: "Situation illustration"
        case .savedLines: "Saved lines illustration"
        case .review: "Review illustration"
        case .historyUsage: "History and usage illustration"
        case .settings: "Settings illustration"
        case .streak: "Streak illustration"
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
        case .celebrating:
            return animate ? 1.08 : 0.96
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
        case .celebrating:
            .spring(response: 0.34, dampingFraction: 0.48).repeatCount(2, autoreverses: true)
        case .waving, .thinking:
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

extension LessonStepKind {
    var visualAsset: ConverlaxAssetKind {
        switch self {
        case .teach:
            return .vocab
        case .choice:
            return .review
        case .speak:
            return .freeTalk
        case .roleplay:
            return .roleplay
        case .freeResponse:
            return .customLesson
        }
    }
}

struct ConverlaxWaveform: View {
    var color: Color = .primaryBlue
    var level: Double = 0
    var isActive = true
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let barCount = 13

    var body: some View {
        TimelineView(.animation(minimumInterval: 0.16, paused: reduceMotion || !isActive)) { timeline in
            HStack(alignment: .center, spacing: 4) {
                ForEach(0..<barCount, id: \.self) { index in
                    Capsule()
                        .fill(color.opacity(index.isMultiple(of: 3) ? 0.72 : 0.42))
                        .frame(width: 4, height: height(for: index, at: timeline.date))
                }
            }
            .frame(height: 40)
        }
        .frame(height: 40)
        .animation(.easeOut(duration: 0.18), value: normalizedLevel)
        .accessibilityHidden(true)
    }

    private var normalizedLevel: Double {
        min(max(level, 0), 1)
    }

    private func height(for index: Int, at date: Date) -> CGFloat {
        let basePattern = [0.16, 0.42, 0.72, 0.48, 0.88, 0.58, 0.34, 0.78, 0.44, 0.64, 0.30, 0.54, 0.22]
        let base = basePattern[index % basePattern.count]
        let speakingLift = isActive ? max(0.18, normalizedLevel) : 0.08
        let time = date.timeIntervalSinceReferenceDate
        let ripple = reduceMotion ? 0 : (sin(time * 5.8 + Double(index) * 0.72) + 1) * 0.5
        let motion = isActive ? ripple * 0.22 : 0
        let height = 8 + CGFloat(base + speakingLift + motion) * 19

        return min(38, max(8, height))
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

    init(feedback: LearningFeedback, startsExpanded _: Bool = false) {
        self.feedback = feedback
    }

    var body: some View {
        VStack(alignment: .leading, spacing: isSpeechFeedback ? 10 : 14) {
            if !isSpeechFeedback {
                HStack(alignment: .top, spacing: 10) {
                    Label("Feedback", systemImage: "checkmark.seal.fill")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(Color.primaryBlue)

                    Spacer(minLength: 10)
                }
            }

            feedbackContent
        }
        .padding(isSpeechFeedback ? 0 : 16)
        .background {
            if !isSpeechFeedback {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.claySurface)
            }
        }
        .overlay {
            if !isSpeechFeedback {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.clayStroke)
            }
        }
        .accessibilityIdentifier("learning-feedback-card")
    }

    @ViewBuilder
    private var feedbackContent: some View {
        if let attemptText {
            FeedbackCompactRow(title: "You said", text: attemptText, symbol: "mic.fill", color: .secondary)
        }

        if let betterLine {
            FeedbackCompactRow(title: "Better", text: betterLine, symbol: "quote.bubble.fill", color: .mintSuccess)
        }

        FeedbackCompactRow(title: "Fix", text: fixDetails ?? "No fix needed.", symbol: "textformat", color: .primaryBlue)

        if let pronunciationDetails {
            FeedbackCompactRow(title: "Pronunciation", text: pronunciationDetails, symbol: "waveform", color: .warmAmber)
        }

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

    private var attemptText: String? {
        clean(feedback.attemptedText)
    }

    private var naturalVersion: String? {
        cleanCoachText(feedback.naturalVersion) ?? cleanCoachText(feedback.betterPhrase) ?? cleanCoachText(feedback.correction)
    }

    private var naturalAlternative: String? {
        guard let alternative = cleanCoachText(feedback.naturalVersion) else { return nil }
        guard alternative != correctedPhrase else { return nil }
        return alternative
    }

    private var correctedPhrase: String? {
        cleanCoachText(feedback.grammarCorrection) ?? cleanCoachText(feedback.correction)
    }

    private var betterLine: String? {
        naturalAlternative ?? naturalVersion ?? correctedPhrase
    }

    private var fixDetails: String? {
        let details = [
            cleanedFixText(feedback.grammarCorrection),
            cleanedFixText(feedback.vocabularyImprovement)
        ].compactMap { $0 }

        guard !details.isEmpty else { return nil }
        let joined = details.joined(separator: " ")
        guard !isDuplicate(joined, of: [betterLine]) else { return nil }
        return joined
    }

    private var pronunciationDetails: String? {
        let details = [
            clean(feedback.pronunciationNotes),
            clean(feedback.pronunciationTip),
            clean(feedback.fluencyTip)
        ].compactMap { $0 }

        var uniqueDetails: [String] = []
        for detail in details where !uniqueDetails.contains(where: { isSameLine($0, detail) }) {
            uniqueDetails.append(detail)
        }

        guard !uniqueDetails.isEmpty else { return nil }
        let joined = uniqueDetails.joined(separator: " ")
        guard !isDuplicate(joined, of: [betterLine, fixDetails]) else { return nil }
        return joined
    }

    private func cleanedFixText(_ text: String) -> String? {
        guard let cleaned = cleanCoachText(text) else { return nil }
        guard !isDuplicate(cleaned, of: [betterLine]) else { return nil }
        return cleaned
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

    private func isSameLine(_ lhs: String, _ rhs: String) -> Bool {
        normalizeLine(lhs) == normalizeLine(rhs)
    }

    private func isDuplicate(_ text: String, of candidates: [String?]) -> Bool {
        candidates.compactMap { $0 }.contains { isSameLine($0, text) }
    }

    private func normalizeLine(_ text: String) -> String {
        text
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .filter { $0.isLetter || $0.isNumber || $0.isWhitespace }
            .split(separator: " ")
            .joined(separator: " ")
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

private struct FeedbackCompactRow: View {
    let title: String
    let text: String
    let symbol: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: symbol)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(color)
                    .frame(width: 18, height: 18)
                    .padding(.top, 1)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(color)
                        .lineLimit(1)
                        .minimumScaleFactor(0.82)

                    Text(text)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(.vertical, 6)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }
}

struct SpeechPracticePanel: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    let phase: SpeechPracticePhase
    let transcript: String
    let feedback: LearningFeedback?
    let accent: Color
    var prompt: String? = nil
    var readyInstruction: String? = nil
    var voiceLevel: Double = 0
    var errorMessage: String?
    var primaryActionTitle: String? = nil
    var secondaryActionTitle: String? = nil
    let onPrimary: () -> Void
    let onCancel: () -> Void
    var onSecondary: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: panelSpacing) {
            header

            if let promptText {
                SpeechPromptBlock(text: promptText)
            }

            inputContent

            if showsMessage {
                SpeechStateMessage(
                    symbol: messageSymbol,
                    text: messageText,
                    color: messageColor
                )
            }

            if let feedback {
                Divider()
                    .overlay(Color.clayStroke.opacity(0.7))

                LearningFeedbackCard(feedback: feedback)
            }

            actionArea
        }
        .padding(16)
        .background(Color.claySurface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(Color.clayStroke.opacity(0.9)))
        .accessibilityIdentifier("speech-practice-panel")
    }

    @ViewBuilder
    private var inputContent: some View {
        if showsFeedbackCard {
            EmptyView()
        } else if phase == .transcript {
            transcriptSection
        } else {
            VStack(spacing: 16) {
                VoiceInputOrb(
                    phase: phase,
                    accent: actionColor,
                    isActive: isListeningOrWorking
                )
                .frame(maxWidth: .infinity)

                if phase == .recording {
                    ConverlaxWaveform(color: actionColor, level: voiceLevel, isActive: true)
                        .frame(maxWidth: .infinity)
                        .transition(.opacity.combined(with: .scale(scale: 0.98)))
                }

                transcriptSection
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: contentMinHeight, alignment: .center)
        }
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 12) {
            SpeechStatusBadge(symbol: statusSymbol, color: statusColor)

            VStack(alignment: .leading, spacing: 3) {
                Text(phase.title)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(Color.converlaxInk)
                    .fixedSize(horizontal: false, vertical: true)
                if phase != .feedback {
                    Text(statusDetail)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                if let feedback, phase == .feedback, horizontalSizeClass == .compact {
                    FeedbackScorePill(confidence: feedback.confidence)
                        .padding(.top, 3)
                }
            }

            Spacer(minLength: 8)

            if let feedback, phase == .feedback, horizontalSizeClass != .compact {
                FeedbackScorePill(confidence: feedback.confidence)
            }

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
    private var actionArea: some View {
        if phase == .feedback,
           let secondaryActionTitle,
           let onSecondary {
            if horizontalSizeClass == .regular {
                HStack(spacing: 12) {
                    SpeechSecondaryButton(title: secondaryActionTitle, action: onSecondary)
                        .frame(maxWidth: .infinity)
                        .accessibilityIdentifier("speech-secondary-action")

                    primaryActionButton
                        .frame(maxWidth: .infinity)
                }
            } else {
                VStack(spacing: 10) {
                    SpeechSecondaryButton(title: secondaryActionTitle, action: onSecondary)
                        .accessibilityIdentifier("speech-secondary-action")

                    primaryActionButton
                }
            }
        } else {
            primaryActionButton
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
        } else if showsMessage || phase == .ready {
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
        SpeechPrimaryButton(
            title: primaryActionTitle ?? phase.actionTitle,
            symbol: primarySymbol,
            color: actionColor,
            phase: phase,
            isEnabled: isPrimaryEnabled,
            action: onPrimary
        )
        .disabled(!isPrimaryEnabled)
        .opacity(isPrimaryEnabled ? 1 : 0.58)
        .accessibilityIdentifier("speech-primary-action")
    }

    private var showsCancel: Bool {
        switch phase {
        case .ready, .requestingPermission, .processing, .transcribing, .feedback, .accepted:
            false
        case .permissionNeeded, .permissionDenied, .noSpeech, .error:
            false
        case .recording, .paused, .transcript:
            true
        }
    }

    private var isPrimaryEnabled: Bool {
        phase != .requestingPermission && phase != .processing && phase != .transcribing
    }

    private var isListeningOrWorking: Bool {
        phase == .recording || phase == .requestingPermission || phase == .processing || phase == .transcribing
    }

    private var showsFeedbackCard: Bool {
        phase == .feedback && feedback != nil
    }

    private var showsTranscript: Bool {
        !transcript.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var promptText: String? {
        let trimmed = prompt?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return trimmed.isEmpty ? nil : trimmed
    }

    private var panelSpacing: CGFloat {
        showsFeedbackCard ? 14 : 18
    }

    private var contentMinHeight: CGFloat {
        if phase == .transcript {
            return 0
        }

        return showsMessage ? 116 : 142
    }

    private var transcriptTitle: String {
        phase == .recording ? "Live transcript" : "Heard"
    }

    private var transcriptText: String {
        transcript.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var transcriptPlaceholder: String {
        switch phase {
        case .recording:
            "Listening for one clear answer."
        case .requestingPermission:
            "iOS may ask for Microphone and Speech Recognition."
        case .processing, .transcribing:
            "Checking what you said."
        case .transcript:
            "Your words will appear here."
        case .permissionNeeded, .permissionDenied:
            "Voice input is unavailable."
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
            return errorMessage ?? "Allow Microphone and Speech Recognition in Settings. Come back and try the same line."
        case .noSpeech:
            return errorMessage ?? "Nothing clear was captured. Hold the phone close and say one short sentence."
        case .feedback:
            return errorMessage ?? "Feedback is ready."
        default:
            return errorMessage ?? "Voice input stopped. Try again with one shorter answer."
        }
    }

    private var statusDetail: String {
        switch phase {
        case .requestingPermission:
            "Waiting for access."
        case .permissionNeeded, .permissionDenied:
            "Fix access and retry this turn."
        case .ready:
            readyInstructionText ?? "Answer the prompt out loud."
        case .recording:
            readyInstructionText ?? "Speak naturally. Your words appear below."
        case .paused:
            "Resume when you are ready."
        case .processing, .transcribing:
            "Checking your answer."
        case .transcript:
            "Use it, or cancel and try again."
        case .feedback:
            "Continue when you are ready."
        case .accepted:
            "Saved."
        case .noSpeech:
            "Say one short sentence."
        case .error:
            "Retry this turn."
        }
    }

    private var readyInstructionText: String? {
        let trimmed = readyInstruction?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return trimmed.isEmpty ? nil : trimmed
    }
}

private struct FeedbackScorePill: View {
    let confidence: Int

    private var boundedConfidence: Int {
        min(100, max(0, confidence))
    }

    private var summary: String {
        switch boundedConfidence {
        case 85...100:
            "Strong attempt"
        case 70..<85:
            "Clear attempt"
        case 55..<70:
            "Good start"
        default:
            "Keep practicing"
        }
    }

    var body: some View {
        Text("\(summary) · \(boundedConfidence)%")
            .font(.caption.weight(.bold))
            .foregroundStyle(Color.primaryBlue)
            .lineLimit(1)
            .minimumScaleFactor(0.78)
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(Color.primaryBlue.opacity(0.08), in: Capsule())
            .accessibilityLabel("\(summary), \(boundedConfidence) percent")
    }
}

private struct SpeechSecondaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: "arrow.clockwise")
                    .font(.headline.weight(.semibold))
                Text(title)
                    .font(.headline.weight(.semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
            }
            .foregroundStyle(Color.primaryBlue)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 56)
            .padding(.horizontal, 18)
            .background(Color.claySurface, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.primaryBlue.opacity(0.24), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(.isButton)
    }
}

private struct SpeechPrimaryButton: View {
    let title: String
    let symbol: String
    let color: Color
    let phase: SpeechPracticePhase
    let isEnabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: symbol)
                    .font(.headline.weight(.bold))
                Text(title)
                    .font(.headline.weight(.bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 56)
            .padding(.horizontal, 18)
            .background(buttonBackground)
            .shadow(color: color.opacity(isEnabled ? 0.12 : 0), radius: 10, y: 6)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(.isButton)
    }

    private var buttonBackground: some View {
        RoundedRectangle(cornerRadius: 14, style: .continuous)
            .fill(color)
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

private struct SpeechPromptBlock: View {
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Tutor prompt")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            Text(text)
                .font(.title3.weight(.bold))
                .foregroundStyle(Color.converlaxInk)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityIdentifier("tutor-active-prompt")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 4)
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
                .lineLimit(isLive ? 3 : nil)
                .fixedSize(horizontal: false, vertical: !isLive)
        }
        .padding(.vertical, 2)
        .frame(maxWidth: .infinity, alignment: .leading)
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
            "bubble.left.and.bubble.right.fill"
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
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isVisible = false

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

            CompletionLevelProgressRow(result: result)
            CompletionRewardRow(result: result)

            CompletionNextActionRow(result: result)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.claySurface, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.clayStroke.opacity(0.72), lineWidth: 1)
        )
        .opacity(isVisible ? 1 : 0)
        .offset(y: isVisible || reduceMotion ? 0 : 10)
        .scaleEffect(isVisible || reduceMotion ? 1 : 0.985)
        .onAppear {
            withAnimation(reduceMotion ? nil : .easeOut(duration: 0.32)) {
                isVisible = true
            }
        }
        .accessibilityIdentifier("completion-celebration")
    }
}

private struct CompletionLevelProgressRow: View {
    let result: CompletionCelebrationResult
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var displayedProgress = 0.0

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
                        .contentTransition(.numericText())
                }

                Spacer(minLength: 8)
            }

            ZStack(alignment: .leading) {
                LessonProgressBar(progress: displayedProgress)
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
            .padding(.leading, 40)
        }
        .onAppear {
            displayedProgress = result.levelProgressBefore
            withAnimation(reduceMotion ? nil : .easeOut(duration: 0.82).delay(0.12)) {
                displayedProgress = result.levelProgressAfter
            }
        }
        .onChange(of: result.levelProgressAfter) { _, newValue in
            withAnimation(reduceMotion ? nil : .easeOut(duration: 0.42)) {
                displayedProgress = newValue
            }
        }
    }
}

private struct CompletionRewardRow: View {
    let result: CompletionCelebrationResult

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: "medal.fill")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(Color.warmAmber)
                .frame(width: 28, height: 28)
                .background(Color.warmAmber.opacity(0.16), in: Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text("Level \(result.levelAfter) · \(result.levelTitle)")
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(2)
                    .minimumScaleFactor(0.84)

                if result.xpEarned > 0 {
                    Text("+\(result.xpEarned) XP")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .contentTransition(.numericText())
                }
            }

            Spacer(minLength: 8)
        }
        .accessibilityElement(children: .combine)
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
                Text("Continue from here")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
                Text(result.nextActionTitle)
                    .font(.subheadline.weight(.semibold))
                if !result.nextActionDetail.isEmpty {
                    Text(result.nextActionDetail)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            Spacer(minLength: 8)
        }
        .padding(.top, 4)
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

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
            .frame(minHeight: 54)
            .padding(.horizontal, 18)
            .background(active ? Color.primaryBlue : Color.primaryBlue.opacity(0.45), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: active ? Color.primaryBlue.opacity(0.18) : .clear, radius: 14, y: 7)
            .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
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
            .frame(minHeight: 54)
            .padding(.horizontal, 18)
            .background(Color.claySurface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.clayStroke.opacity(isEnabled ? 1 : 0.5), lineWidth: 1)
            )
            .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
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
        case .customLesson: "Custom lesson illustration"
        case .freeTalk: "Free talk illustration"
        case .roleplay: "Roleplay illustration"
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
        if id.contains("direction") { return .askDirections }
        if id.contains("hotel") { return .bookAccommodation }
        if id.contains("order") || id.contains("coffee") { return .askInfo }
        if id.contains("greeting") || id.contains("small-talk") || id.contains("intro") { return .freeTalk }
        if id.contains("work") { return .roleplay }
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
                .font(.title.weight(.bold))
                .foregroundStyle(color)
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(18)
        .background(Color.claySurface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
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
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Feedback", systemImage: "sparkles")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(Color.primaryBlue)
                Spacer()
                Text("\(feedback.averageScore)%")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(scoreColor(feedback.averageScore))
            }

            Text(feedback.correction)
                .font(.subheadline.weight(.medium))

            Text(feedback.betterPhrase)
                .font(.caption)
                .foregroundStyle(.secondary)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                FeedbackMetric(title: "Pronunciation", value: feedback.pronunciation)
                FeedbackMetric(title: "Grammar", value: feedback.grammar)
                FeedbackMetric(title: "Vocabulary", value: feedback.vocabulary)
                FeedbackMetric(title: "Fluency", value: feedback.fluency)
            }
        }
        .padding(16)
        .background(Color.claySurface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(Color.clayStroke))
        .accessibilityElement(children: .combine)
    }

    private func scoreColor(_ score: Int) -> Color {
        score >= 76 ? .mintSuccess : score >= 60 ? .warmAmber : .converlaxCoral
    }
}

private struct FeedbackMetric: View {
    let title: String
    let value: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(value)")
                    .font(.caption.weight(.bold))
            }
            LessonProgressBar(progress: Double(value) / 100)
        }
        .padding(10)
        .background(Color.appBackground.opacity(0.72), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

struct SpeechPracticePanel: View {
    let phase: SpeechPracticePhase
    let transcript: String
    let feedback: LearningFeedback?
    let accent: Color
    let onPrimary: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            ConverlaxMascotView(state: mascotState, size: 88)
            Text(phase.title)
                .font(.headline.weight(.semibold))
            ConverlaxWaveform(color: accent, isActive: phase == .recording || phase == .processing)

            if !transcript.isEmpty {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Recognized transcript")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Text(transcript)
                        .font(.subheadline.weight(.medium))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(Color.appBackground.opacity(0.72), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            }

            if let feedback {
                LearningFeedbackCard(feedback: feedback)
            }

            HStack(spacing: 12) {
                Button(action: onCancel) {
                    Label("Cancel", systemImage: "xmark")
                }
                .buttonStyle(SecondaryButtonStyle())
                .disabled(phase == .ready || phase == .accepted)

                Button(action: onPrimary) {
                    Text(phase.actionTitle)
                }
                .buttonStyle(PrimaryButtonStyle(isEnabled: phase != .processing))
                .disabled(phase == .processing)
            }
        }
        .padding(16)
        .background(Color.claySurface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(Color.clayStroke))
        .accessibilityIdentifier("speech-practice-panel")
    }

    private var mascotState: ConverlaxMascotState {
        switch phase {
        case .permissionNeeded, .ready, .paused:
            .listening
        case .recording:
            .speaking
        case .processing:
            .thinking
        case .transcript, .feedback:
            .encouraging
        case .accepted:
            .success
        case .error:
            .tryAgain
        }
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
        .background(Color.claySurface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
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
        .background(Color.claySurface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

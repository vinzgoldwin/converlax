import SwiftUI

struct QuickLessonPracticeView: View {
    @ObservedObject var state: LearningState

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 18) {
                Text("Quick lessons")
                    .font(.title2.weight(.bold))

                NavigationLink(value: QuickPracticeRoute.vocab) {
                    PracticeCard(title: "Vocab", subtitle: "Say useful phrases out loud", symbol: "character.book.closed.fill", color: Color.warmAmber, asset: .vocab)
                }

                NavigationLink(value: QuickPracticeRoute.verbs) {
                    PracticeCard(title: "Verbs", subtitle: "Speak the line in context", symbol: "textformat.abc.dottedunderline", color: Color.violetAccent, asset: .verbs)
                }

                Spacer()
                TutorPromptBar()
            }
            .padding(20)
        }
        .navigationTitle("Practice")
        .navigationDestination(for: QuickPracticeRoute.self) { route in
            switch route {
            case .vocab:
                VocabLessonView(lesson: BeginnerContent.vocabPracticeLesson(for: state.profile.targetLanguage), state: state)
            case .verbs:
                VerbLessonView(lesson: BeginnerContent.verbPracticeLesson(for: state.profile.targetLanguage), state: state)
            }
        }
    }
}

private struct PracticeCard: View {
    let title: String
    let subtitle: String
    let symbol: String
    let color: Color
    var asset: ConverlaxAssetKind? = nil

    var body: some View {
        HStack(spacing: 14) {
            if let asset {
                ConverlaxAssetBadge(kind: asset, size: 54)
            } else {
                Image(systemName: symbol)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 48, height: 48)
                    .background(color, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.primary)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.footnote.weight(.bold))
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .background(Color.claySurface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(Color.clayStroke))
    }
}

struct VocabLessonView: View {
    let lesson: BeginnerLesson
    @ObservedObject var state: LearningState

    var body: some View {
        LessonPlayerView(lesson: lesson, state: state)
    }
}

struct VerbLessonView: View {
    let lesson: BeginnerLesson
    @ObservedObject var state: LearningState

    var body: some View {
        LessonPlayerView(lesson: lesson, state: state)
    }
}

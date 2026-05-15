import SwiftUI

struct CourseHomeView: View {
    @ObservedObject var state: LearningState
    @Binding var activeSheet: ActiveSheet?

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    CourseHeader(state: state, activeSheet: $activeSheet)
                    CourseTrackContent(state: state, activeSheet: $activeSheet)
                }
                .padding(.horizontal, 20)
                .padding(.top, 14)
            }
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 96)
            }
        }
        .navigationTitle("Converlax")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct CourseTrackContent: View {
    @ObservedObject var state: LearningState
    @Binding var activeSheet: ActiveSheet?

    var body: some View {
        CurrentLessonLink(state: state)
        HomeProgressRow(state: state, activeSheet: $activeSheet)
        HomeQuickActions(state: state)
    }
}

private struct CourseHeader: View {
    @ObservedObject var state: LearningState
    @Binding var activeSheet: ActiveSheet?

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Start today's lesson")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.primary)
                    .lineLimit(2)

                Button {
                    activeSheet = .level
                } label: {
                    HStack(spacing: 7) {
                        Text(state.profile.targetLanguage.sampleNote)
                            .lineLimit(1)
                        Text(state.profile.currentLevel.code)
                            .font(.caption.weight(.bold))
                            .foregroundStyle(Color.primaryBlue)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 4)
                            .background(Color.primaryBlue.opacity(0.1), in: Capsule())
                        Image(systemName: "chevron.down")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(.secondary)
                    }
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.primary)
                    .padding(.horizontal, 11)
                    .padding(.vertical, 7)
                    .background(Color.claySurface, in: Capsule())
                }
                .accessibilityLabel("Current level \(state.profile.currentLevel.rawValue)")
            }

            Spacer(minLength: 8)

            ConverlaxMascotView(state: .waving, size: 58)
                .accessibilityHidden(true)
        }
    }
}

private struct HomeProgressRow: View {
    @ObservedObject var state: LearningState
    @Binding var activeSheet: ActiveSheet?

    var body: some View {
        HStack(spacing: 14) {
            Button {
                activeSheet = .streak
            } label: {
                HStack(spacing: 9) {
                    ConverlaxAssetBadge(kind: .streak, size: 34)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Streak")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                        Text("\(state.profile.streak) days")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(.primary)
                            .lineLimit(1)
                    }
                }
                .frame(minWidth: 92, alignment: .leading)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("\(state.profile.streak) day streak")

            Rectangle()
                .fill(Color.clayStroke)
                .frame(width: 1)
                .padding(.vertical, 4)

            VStack(alignment: .leading, spacing: 7) {
                HStack {
                    Text("Unit progress")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("\(state.completedLessonCount)/\(state.courseLessons.count)")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.secondary)
                }

                LessonProgressBar(progress: state.courseProgress)

                Text(state.nextRecommendation)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.primaryBlue)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
            }
        }
        .padding(14)
        .background(Color.claySurface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.clayStroke.opacity(0.72), lineWidth: 1)
        )
    }
}

private struct CourseUnitIntro: View {
    let language: TargetLanguage

    var body: some View {
        HStack(spacing: 14) {
            ConverlaxMascotView(state: .idle, size: 84)

            VStack(alignment: .leading, spacing: 6) {
                Text("Unit 1")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text(language.unitTitle)
                    .font(.title2.weight(.bold))
                Text(language.unitDescription)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

private struct CurrentLessonLink: View {
    @ObservedObject var state: LearningState

    var body: some View {
        NavigationLink(value: HomeRoute.lesson(state.currentLesson)) {
            FeaturedLessonCard(lesson: state.currentLesson, completed: state.isCompleted(state.currentLesson))
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("home-primary-lesson-action")
    }
}

private struct HomeQuickActions: View {
    @ObservedObject var state: LearningState

    var body: some View {
        HStack(spacing: 10) {
            NavigationLink(value: HomeRoute.courseDetail) {
                SecondaryLearningAction(title: "See all lessons", subtitle: "Course path", symbol: "map.fill", color: .primaryBlue)
            }
            .accessibilityIdentifier("home-course-path-action")

            NavigationLink(value: HomeRoute.speakingDrill(state.currentLesson)) {
                SecondaryLearningAction(title: "Practice speaking", subtitle: "Speak now", symbol: "mic.fill", color: .mintSuccess)
            }
            .accessibilityIdentifier("home-extra-practice-action")
        }
        .buttonStyle(.plain)
    }
}

private struct SecondaryLearningAction: View {
    let title: String
    let subtitle: String
    let symbol: String
    let color: Color

    var body: some View {
        HStack(spacing: 10) {
            AvatarBadge(symbol: symbol, color: color)
                .frame(width: 34, height: 34)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, minHeight: 62, alignment: .leading)
        .padding(.horizontal, 12)
        .background(Color.claySurface.opacity(0.78), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.clayStroke.opacity(0.68), lineWidth: 1)
        )
    }
}

private struct QuickActionCard: View {
    let title: String
    let subtitle: String
    let symbol: String
    let color: Color
    var asset: ConverlaxAssetKind? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let asset {
                ConverlaxAssetBadge(kind: asset, size: 48)
            } else {
                AvatarBadge(symbol: symbol, color: color)
                    .frame(width: 42, height: 42)
            }
            Text(title)
                .font(.headline.weight(.semibold))
                .foregroundStyle(.primary)
            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color.claySurface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

private struct FeaturedLessonCard: View {
    let lesson: BeginnerLesson
    let completed: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top, spacing: 12) {
                ConverlaxAssetBadge(kind: lesson.visualAsset, size: 62)

                VStack(alignment: .leading, spacing: 4) {
                    Text(completed ? "Review lesson" : "Continue lesson")
                        .font(.caption.weight(.bold))
                        .textCase(.uppercase)
                        .foregroundStyle(.white.opacity(0.72))
                    Text(lesson.title)
                        .font(.title2.weight(.bold))
                        .lineLimit(2)
                        .minimumScaleFactor(0.9)
                }

                Spacer()

                Text("\(lesson.minutes) min")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white.opacity(0.88))
                    .padding(.horizontal, 9)
                    .padding(.vertical, 6)
                    .background(.white.opacity(0.14), in: Capsule())
            }

            VStack(alignment: .leading, spacing: 7) {
                Text(lesson.subtitle)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.82))
                    .lineLimit(2)

                Text(lesson.steps.first?.prompt ?? "Start your next lesson")
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(.white)
                    .lineLimit(2)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 18, style: .continuous))

            HStack(spacing: 8) {
                Image(systemName: completed ? "arrow.clockwise" : "play.fill")
                    .font(.headline.weight(.bold))
                    .accessibilityHidden(true)
                Text(completed ? "Practice again" : "Start lesson")
                    .font(.headline.weight(.bold))
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .accessibilityHidden(true)
            }
            .foregroundStyle(Color.primaryBlue)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16)
            .padding(.vertical, 15)
            .background(Color.claySurface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .padding(16)
        .foregroundStyle(.white)
        .background(
            LinearGradient(colors: [Color.primaryBlue, Color.converlaxTeal, Color.mintSuccess.opacity(0.88)], startPoint: .topLeading, endPoint: .bottomTrailing),
            in: RoundedRectangle(cornerRadius: 24, style: .continuous)
        )
        .shadow(color: lesson.accent.color.opacity(0.24), radius: 20, y: 10)
    }
}

private struct LessonPath: View {
    @ObservedObject var state: LearningState
    let lessons: [BeginnerLesson]

    var body: some View {
        VStack(spacing: 12) {
            ForEach(lessons) { lesson in
                LessonRowLink(state: state, lesson: lesson)
            }
        }
    }
}

private struct LessonRowLink: View {
    @ObservedObject var state: LearningState
    let lesson: BeginnerLesson

    var body: some View {
        NavigationLink(value: HomeRoute.lessonDetail(lesson)) {
            LessonRow(lesson: lesson, isCurrent: state.isCurrent(lesson), isCompleted: state.isCompleted(lesson))
        }
        .buttonStyle(.plain)
        .disabled(!state.isUnlocked(lesson))
        .opacity(state.isUnlocked(lesson) ? 1 : 0.5)
    }
}

struct CourseDetailView: View {
    @ObservedObject var state: LearningState

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    CourseUnitIntro(language: state.profile.targetLanguage)
                    CurrentCourseLessonStart(state: state)

                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader(title: "Choose a lesson", subtitle: "Each one builds a useful conversation.")
                        ForEach(state.courseLessons) { lesson in
                            NavigationLink(value: HomeRoute.lessonDetail(lesson)) {
                                LessonRow(lesson: lesson, isCurrent: state.isCurrent(lesson), isCompleted: state.isCompleted(lesson))
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    LessonToolsMenu(lesson: state.currentLesson, title: "Practice another way", includesCourseModes: true)
                }
                .padding(20)
            }
        }
        .navigationTitle("Course")
    }
}

private struct CurrentCourseLessonStart: View {
    @ObservedObject var state: LearningState

    private var lesson: BeginnerLesson {
        state.currentLesson
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 14) {
                ConverlaxAssetBadge(kind: lesson.visualAsset, size: 58)

                VStack(alignment: .leading, spacing: 4) {
                    Text(state.isCompleted(lesson) ? "Review current lesson" : "Up next")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.primaryBlue)
                    Text(lesson.title)
                        .font(.headline.weight(.bold))
                    Text(lesson.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            NavigationLink(value: HomeRoute.lesson(lesson)) {
                Label(state.isCompleted(lesson) ? "Start again" : "Start lesson", systemImage: "play.fill")
            }
            .buttonStyle(PrimaryButtonStyle())
            .accessibilityIdentifier("course-detail-start-button")
        }
        .padding(18)
        .background(Color.claySurface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

private struct LessonRow: View {
    let lesson: BeginnerLesson
    let isCurrent: Bool
    let isCompleted: Bool

    var body: some View {
        HStack(spacing: 14) {
            ConverlaxAssetBadge(kind: lesson.visualAsset, size: 50)
                .frame(width: 46, height: 46)

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(lesson.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                    if isCurrent && !isCompleted {
                        Text("Next")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .background(Color.primaryBlue, in: Capsule())
                    }
                }
                Text(lesson.subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: isCompleted ? "checkmark.circle.fill" : "chevron.right")
                .foregroundStyle(isCompleted ? Color.mintSuccess : Color.secondary.opacity(0.7))
        }
        .padding(14)
        .background(Color.claySurface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(isCurrent ? Color.primaryBlue.opacity(0.32) : Color.clayStroke, lineWidth: isCurrent ? 1.5 : 1)
        )
    }
}

private struct LockedUnitPreview: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Unit 2")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            Text("Daily Life")
                .font(.headline.weight(.semibold))
                .foregroundStyle(.secondary)
            Text("Unlocks after Unit 1.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.vertical, 8)
    }
}

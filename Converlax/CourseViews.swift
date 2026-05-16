import SwiftUI

struct CourseHomeView: View {
    @ObservedObject var state: LearningState

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    CourseHeader(state: state)
                    CourseTrackContent(state: state)
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
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

    var body: some View {
        CurrentLessonLink(state: state)
        HomeSecondaryActionRow(state: state)
    }
}

private struct CourseHeader: View {
    @ObservedObject var state: LearningState

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Continue from here")
                .font(.title2.weight(.bold))
                .foregroundStyle(.primary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            Text("\(state.profile.currentLevel.rawValue) \(state.profile.targetLanguage.rawValue)")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct CourseUnitIntro: View {
    let language: TargetLanguage

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Speaking course")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.primaryBlue)
            Text(language.unitTitle)
                .font(.title2.weight(.bold))
            Text(language.unitDescription)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

private struct CurrentLessonLink: View {
    @ObservedObject var state: LearningState

    var body: some View {
        NavigationLink(value: HomeRoute.lesson(state.currentLesson)) {
            FeaturedLessonCard(
                lesson: state.currentLesson,
                completed: state.isCompleted(state.currentLesson),
                isFirstSession: !state.hasStartedLearning
            )
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("home-primary-lesson-action")
    }
}

private struct HomeSecondaryActionRow: View {
    @ObservedObject var state: LearningState

    var body: some View {
        NavigationLink(value: HomeRoute.courseDetail) {
            SecondaryLearningAction(title: "See course path", subtitle: remainingLessonSummary, symbol: "map.fill", color: .primaryBlue)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("home-course-path-action")
        .background(Color.claySurface.opacity(0.68), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.clayStroke.opacity(0.66), lineWidth: 1)
        )
    }

    private var remainingLessonCount: Int {
        max(0, state.courseLessons.count - state.completedLessonCount)
    }

    private var remainingLessonSummary: String {
        remainingLessonCount == 1 ? "1 lesson left" : "\(remainingLessonCount) lessons left"
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

            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 56, alignment: .leading)
        .padding(.horizontal, 14)
        .contentShape(Rectangle())
    }
}

private struct FeaturedLessonCard: View {
    let lesson: BeginnerLesson
    let completed: Bool
    var isFirstSession = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 12) {
                ConverlaxAssetBadge(kind: lesson.visualAsset, size: 62)

                VStack(alignment: .leading, spacing: 4) {
                    Text(eyebrow)
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

            Text(supportingLine)
                .font(.headline.weight(.semibold))
                .foregroundStyle(.white)
                .lineLimit(2)

            HStack(spacing: 8) {
                Image(systemName: completed ? "arrow.clockwise" : "play.fill")
                    .font(.headline.weight(.bold))
                    .accessibilityHidden(true)
                Text(primaryActionTitle)
                    .font(.headline.weight(.bold))
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .accessibilityHidden(true)
            }
            .foregroundStyle(Color.primaryBlue)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16)
            .padding(.vertical, 13)
            .background(Color.claySurface, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .padding(16)
        .foregroundStyle(.white)
        .background(Color.primaryBlue, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: Color.primaryBlue.opacity(0.12), radius: 10, y: 5)
    }

    private var eyebrow: String {
        if completed { return "Review lesson" }
        return isFirstSession ? "First speaking lesson" : "Continue lesson"
    }

    private var supportingLine: String {
        if isFirstSession {
            return "Learn one useful line, say it out loud, and check your meaning."
        }
        return lesson.steps.first?.prompt ?? "Start your next lesson"
    }

    private var primaryActionTitle: String {
        if completed { return "Practice again" }
        return isFirstSession ? "Start speaking" : "Continue speaking"
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
                        ForEach(groupedLessons) { group in
                            VStack(alignment: .leading, spacing: 10) {
                                CourseUnitSectionHeader(unit: group.unit, title: group.title)
                                ForEach(group.lessons) { lesson in
                                    NavigationLink(value: HomeRoute.lessonDetail(lesson)) {
                                        LessonRow(lesson: lesson, isCurrent: state.isCurrent(lesson), isCompleted: state.isCompleted(lesson))
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }

                    LessonToolsMenu(lesson: state.currentLesson, title: "Practice another way", includesCourseModes: true)
                }
                .padding(20)
            }
        }
        .navigationTitle("Course")
    }

    private var groupedLessons: [CourseLessonGroup] {
        let lessonsByUnit = Dictionary(grouping: state.courseLessons, by: \.unit)
        return lessonsByUnit.keys.sorted().map { unit in
            CourseLessonGroup(
                unit: unit,
                title: unitTitle(for: unit),
                lessons: lessonsByUnit[unit] ?? []
            )
        }
    }

    private func unitTitle(for unit: Int) -> String {
        guard state.profile.targetLanguage == .english else {
            return "Beginner essentials"
        }

        switch unit {
        case 1:
            return "First conversations"
        case 2:
            return "Around town"
        case 3:
            return "Work and calls"
        case 4:
            return "Travel and help"
        default:
            return "Conversation practice"
        }
    }
}

private struct CourseLessonGroup: Identifiable {
    let unit: Int
    let title: String
    let lessons: [BeginnerLesson]

    var id: Int { unit }
}

private struct CourseUnitSectionHeader: View {
    let unit: Int
    let title: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Unit \(unit)")
                .font(.caption.weight(.bold))
                .foregroundStyle(Color.primaryBlue)
            Text(title)
                .font(.headline.weight(.semibold))
        }
        .padding(.top, unit == 1 ? 0 : 8)
    }
}

private struct CurrentCourseLessonStart: View {
    @ObservedObject var state: LearningState

    private var lesson: BeginnerLesson {
        state.currentLesson
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
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
                Label(state.isCompleted(lesson) ? "Speak again" : "Start speaking", systemImage: "mic.fill")
            }
            .buttonStyle(PrimaryButtonStyle())
            .accessibilityIdentifier("course-detail-start-button")
        }
        .padding(16)
        .background(Color.claySurface, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

private struct LessonRow: View {
    let lesson: BeginnerLesson
    let isCurrent: Bool
    let isCompleted: Bool

    var body: some View {
        HStack(spacing: 14) {
            AvatarBadge(symbol: lesson.icon, color: lesson.accent.color)
                .frame(width: 38, height: 38)

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
        .frame(minHeight: 56)
        .padding(.horizontal, 8)
        .padding(.vertical, 10)
        .background(isCurrent ? Color.primaryBlue.opacity(0.08) : Color.clear, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(isCurrent ? Color.primaryBlue.opacity(0.28) : Color.clayStroke.opacity(0.42), lineWidth: isCurrent ? 1.25 : 1)
        )
        .contentShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
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

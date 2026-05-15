import SwiftUI

struct CourseHomeView: View {
    @ObservedObject var state: LearningState
    @Binding var activeSheet: ActiveSheet?
    @State private var selectedTrack: LessonTrack = .course

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    CourseHeader(state: state, activeSheet: $activeSheet, selectedTrack: $selectedTrack)
                    if selectedTrack == .course {
                        CourseTrackContent(state: state, activeSheet: $activeSheet)
                    } else {
                        PracticeTrackContent(state: state)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
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
        CourseUnitIntro(language: state.profile.targetLanguage)
        SkillProgressStrip(progress: state.skillProgress)
        CurrentLessonLink(state: state)
        HomeQuickActions(state: state, activeSheet: $activeSheet)
        LessonPath(state: state, lessons: state.courseLessons)
        LockedUnitPreview()
        NavigationLink(value: HomeRoute.tutor) {
            TutorPromptBar()
                .padding(.top, 2)
        }
        .buttonStyle(.plain)
    }
}

private struct PracticeTrackContent: View {
    @ObservedObject var state: LearningState

    var body: some View {
        SectionHeader(title: "Practice", subtitle: "Short drills for recall, speaking, and saved lines.")
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            NavigationLink(value: HomeRoute.vocab) {
                QuickActionCard(title: "Vocab", subtitle: "Translate words", symbol: "character.book.closed.fill", color: .warmAmber, asset: .vocab)
            }
            NavigationLink(value: HomeRoute.verbs) {
                QuickActionCard(title: "Verbs", subtitle: "Fill blanks", symbol: "textformat.abc.dottedunderline", color: .violetAccent, asset: .verbs)
            }
            NavigationLink(value: HomeRoute.speakingDrill(state.currentLesson)) {
                QuickActionCard(title: "Speaking", subtitle: "Say core phrases", symbol: "mic.fill", color: .mintSuccess, asset: .freeTalk)
            }
            NavigationLink(value: HomeRoute.qaLesson(state.currentLesson)) {
                QuickActionCard(title: "Q&A", subtitle: "Answer prompts", symbol: "questionmark.bubble.fill", color: .primaryBlue, asset: .askInfo)
            }
        }
        .buttonStyle(.plain)

        NavigationLink(value: HomeRoute.customLesson) {
            HeroActionCard(title: "Create a practice roleplay", subtitle: "Turn any situation into a speaking drill", symbol: "plus.bubble.fill", color: .mintSuccess, asset: .customLesson)
        }
        .buttonStyle(.plain)

        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Recommended", subtitle: "Practice from your current unit.")
            NavigationLink(value: HomeRoute.lessonDetail(state.currentLesson)) {
                LessonRow(lesson: state.currentLesson, isCurrent: true, isCompleted: state.isCompleted(state.currentLesson))
            }
            .buttonStyle(.plain)
        }
    }
}

private struct CourseHeader: View {
    @ObservedObject var state: LearningState
    @Binding var activeSheet: ActiveSheet?
    @Binding var selectedTrack: LessonTrack

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Button {
                    activeSheet = .level
                } label: {
                    HStack(spacing: 6) {
                        Text(state.profile.currentLevel.code)
                            .font(.footnote.weight(.semibold))
                        Image(systemName: "chevron.down")
                            .font(.caption2.weight(.bold))
                    }
                    .foregroundStyle(.primary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.claySurface, in: Capsule())
                }
                .accessibilityLabel("Current level \(state.profile.currentLevel.rawValue)")

                Spacer()

                Picker("Track", selection: $selectedTrack) {
                    ForEach(LessonTrack.allCases) { track in
                        Text(track.rawValue).tag(track)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 184)

                Spacer()

                HStack(spacing: 5) {
                    ConverlaxAssetBadge(kind: .streak, size: 28)
                    Text("\(state.profile.streak)")
                        .font(.footnote.weight(.bold))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.claySurface, in: Capsule())
                .accessibilityElement(children: .combine)
                .accessibilityLabel("\(state.profile.streak) day streak")
                .onTapGesture {
                    activeSheet = .streak
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(state.profile.targetLanguage.sampleNote)
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
            }
        }
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
    }
}

private struct HomeQuickActions: View {
    @ObservedObject var state: LearningState
    @Binding var activeSheet: ActiveSheet?

    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            NavigationLink(value: HomeRoute.courseDetail) {
                QuickActionCard(title: "Course", subtitle: "Unit path", symbol: "map.fill", color: .primaryBlue, asset: .askDirections)
            }
            NavigationLink(value: HomeRoute.tutor) {
                QuickActionCard(title: "Tutor", subtitle: "Chat practice", symbol: "sparkles", color: .mintSuccess, asset: .customLesson)
            }
            NavigationLink(value: HomeRoute.vocab) {
                QuickActionCard(title: "Vocab", subtitle: "Quick lesson", symbol: "character.book.closed.fill", color: .warmAmber, asset: .vocab)
            }
            NavigationLink(value: HomeRoute.verbs) {
                QuickActionCard(title: "Verbs", subtitle: "Fill blanks", symbol: "textformat.abc", color: .violetAccent, asset: .verbs)
            }
        }
        .buttonStyle(.plain)
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
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                ConverlaxAssetBadge(kind: lesson.visualAsset, size: 58)

                VStack(alignment: .leading, spacing: 4) {
                    Text(completed ? "Review \(lesson.title.lowercased())" : lesson.title)
                        .font(.headline.weight(.semibold))
                    Text(lesson.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.78))
                }

                Spacer()
            }
            .padding(.horizontal, 18)
            .padding(.top, 18)

            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(lesson.steps.first?.prompt ?? "Start your next lesson")
                        .font(.callout.weight(.semibold))
                    Text("\(lesson.minutes) min lesson")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.white.opacity(0.74))
                }

                Spacer()

                Image(systemName: completed ? "arrow.clockwise" : "play.fill")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(Color.primaryBlue)
                    .frame(width: 58, height: 58)
                    .background(.white.opacity(0.95), in: Circle())
                    .accessibilityHidden(true)
            }
            .padding(18)

            Text(completed ? "Practice again" : "Start")
                .font(.headline.weight(.semibold))
                .foregroundStyle(Color.primaryBlue)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.claySurface, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                .padding([.horizontal, .bottom], 10)
        }
        .foregroundStyle(.white)
        .background(
            LinearGradient(colors: [Color.primaryBlue, Color.converlaxTeal, Color.mintSuccess.opacity(0.88)], startPoint: .topLeading, endPoint: .bottomTrailing),
            in: RoundedRectangle(cornerRadius: 26, style: .continuous)
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
                    ForEach(state.courseLessons) { lesson in
                        NavigationLink(value: HomeRoute.lessonDetail(lesson)) {
                            LessonRow(lesson: lesson, isCurrent: state.isCurrent(lesson), isCompleted: state.isCompleted(lesson))
                        }
                        .buttonStyle(.plain)
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Lesson types")
                            .font(.headline.weight(.semibold))
                        NavigationLink(value: HomeRoute.videoLesson(state.currentLesson)) {
                            QuickActionCard(title: "Video lesson", subtitle: "Watch and repeat", symbol: "play.rectangle.fill", color: .primaryBlue, asset: .askInfo)
                        }
                        NavigationLink(value: HomeRoute.speakingDrill(state.currentLesson)) {
                            QuickActionCard(title: "Speaking drill", subtitle: "Practice out loud", symbol: "mic.fill", color: .mintSuccess, asset: .freeTalk)
                        }
                        NavigationLink(value: HomeRoute.qaLesson(state.currentLesson)) {
                            QuickActionCard(title: "Q&A lesson", subtitle: "Answer prompts", symbol: "questionmark.bubble.fill", color: .violetAccent, asset: .askInfo)
                        }
                        NavigationLink(value: HomeRoute.customLesson) {
                            QuickActionCard(title: "Custom lesson", subtitle: "Create from a situation", symbol: "plus.bubble.fill", color: .warmAmber, asset: .customLesson)
                        }
                    }
                }
                .padding(20)
            }
        }
        .navigationTitle("Course")
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

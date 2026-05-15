# Parallel Core Learning Goal Prompts

Date: 2026-05-15

Use these when you want multiple agents to work in parallel after the UI simplification work. These goals are designed for separate git worktrees. They split the big "Core Learning Experience" goal by ownership area so each agent can make progress independently.

Recommended setup:

1. Start from the latest `ui-simplification` branch after simplification is merged.
2. Create one worktree per goal.
3. Run Goals A-D in parallel.
4. Merge in this order: A, B, C, D.
5. After merging all four, run Goal E as the final integration/audit pass.

Do not skip Goal E. Parallel work can produce locally good pieces that still feel disconnected when combined.

## Parallel Goal A: First Session And Onboarding

You are working in `/Users/kego/Projects/converlax`, a SwiftUI iOS app for speaking-focused language learning.

Parallel ownership:

- Primary files:
  - `Converlax/OnboardingView.swift`
  - first-launch copy/content if needed
- Secondary files only if necessary:
  - `Converlax/CourseViews.swift`
  - `Converlax/LearningState.swift`
  - `Converlax/BeginnerContent.swift`

Avoid large edits to:

- `Converlax/PhaseOneViews.swift`
- `Converlax/PracticeViews.swift`
- `Converlax/TutorView.swift`

Goal:

Make the first-session path feel clear, fast, and rewarding from forced onboarding through the first lesson start.

Product outcome:

A new user should be able to:

1. Understand what Converlax helps them do.
2. Choose language and beginner level with low friction.
3. Start learning without seeing too many product modes.
4. Land on Home with one obvious first action.

Implementation requirements:

- Simplify onboarding copy and step hierarchy.
- Remove or demote preferences that do not affect the first session.
- Make onboarding feel like setup for immediate speaking practice, not a questionnaire.
- Ensure first-launch Home state remains compatible with the simplified Home implementation.
- Improve first-lesson setup copy/content only where needed.
- Do not introduce new backend or account requirements.

UX quality bar:

- Onboarding should have one main promise per step.
- A first-time user should not need to understand Free Talk, Roleplay, Review, Profile, and Settings before getting value.
- The first post-onboarding screen should make the next action obvious within five seconds.
- The experience should feel lightweight and encouraging.

Testing and verification:

- Build the app.
- Run forced onboarding.
- Step through every onboarding screen.
- Verify language and level selection still save correctly.
- Verify onboarding completion lands on Home.
- Verify relaunch does not show onboarding unless forced.
- Capture screenshots under `DesignReferences/verification/screenshots/parallel-first-session/`.
- Write a short verification note at `DesignReferences/verification/parallel-first-session.md`.
- Include an enjoyment judgment: does onboarding make the user want to try the first lesson?

Done when:

- Onboarding is simpler and more focused.
- The first post-onboarding action is clear.
- Build and simulator checks pass.

## Parallel Goal B: Course Content And Lesson Quality

You are working in `/Users/kego/Projects/converlax`, a SwiftUI iOS app for speaking-focused language learning.

Parallel ownership:

- Primary files:
  - `Converlax/BeginnerContent.swift`
  - `Converlax/PhaseOneContent.swift`
  - lesson/content-related models in `Converlax/Models.swift` only if necessary
- Secondary files only if necessary:
  - `Converlax/CourseViews.swift`
  - `Converlax/LessonPlayerView.swift`

Avoid large edits to:

- `Converlax/OnboardingView.swift`
- `Converlax/PhaseOneViews.swift`
- `Converlax/TutorView.swift`

Goal:

Make one beginner course path feel practical, coherent, and useful for real conversation.

Suggested course arc:

1. Introduce yourself.
2. Greet and make small talk.
3. Order at a cafe.
4. Ask for directions.
5. Ask for help or clarification.
6. Make plans.
7. Talk about daily routine.
8. Handle shopping/prices.
9. Simple workplace introduction.
10. Review conversation combining earlier phrases.

Implementation requirements:

- Improve lesson titles, goals, prompts, answer options, saved lines, and reviewable phrases.
- Make phrases sound natural and beginner-appropriate.
- Reuse learned phrases across later lessons.
- Connect roleplay/topic content to course lesson themes where content data allows.
- Ensure at least early, middle, and later lessons have meaningful practice steps.
- Keep content data clean and maintainable.

UX/content quality bar:

- Every lesson should have a clear speaking goal.
- Lines should be useful in actual conversation.
- Avoid repetitive or artificial textbook copy.
- Course progression should feel easier-to-harder.
- A user should believe the app has a real learning plan.

Testing and verification:

- Build the app.
- Browse the course path.
- Open early, middle, and later lessons.
- Complete at least one early lesson and one later lesson.
- Verify saved lines/review items from the content are meaningful.
- Capture screenshots under `DesignReferences/verification/screenshots/parallel-course-content/`.
- Write a verification note at `DesignReferences/verification/parallel-course-content.md`.
- Include a content judgment: read the phrases aloud and state whether they sound natural.

Done when:

- One beginner path feels coherent and practical.
- Course content can feed lessons, saved lines, and review.
- Build and simulator checks pass.

## Parallel Goal C: Speaking Feedback Experience

You are working in `/Users/kego/Projects/converlax`, a SwiftUI iOS app for speaking-focused language learning.

Parallel ownership:

- Primary files:
  - `Converlax/PracticeViews.swift`
  - speaking/session parts of `Converlax/PhaseOneViews.swift`
  - `Converlax/TutorView.swift`
- Secondary files only if necessary:
  - `Converlax/Models.swift`
  - `Converlax/LearningState.swift`
  - `Converlax/ThemeAndComponents.swift`

Avoid large edits to:

- `Converlax/OnboardingView.swift`
- broad course content files unless needed for feedback examples

Goal:

Make speaking practice feedback specific, structured, saveable, and motivating.

Product outcome:

After a speaking attempt, the user should see:

- What they attempted or said
- A corrected version
- One more natural phrase
- One pronunciation/rhythm/clarity tip
- A simple confidence or clarity signal
- One saved/reviewable takeaway
- One recommended follow-up action

Implementation requirements:

- Improve feedback states for speaking drill, Free Talk, roleplay, and Tutor where applicable.
- Keep feedback local/mock if no real speech service exists.
- Make feedback specific to the prompt.
- Add reusable feedback UI only if it reduces duplication.
- Ensure feedback can create saved lines or review items where appropriate.
- Handle retry/no-input states if they exist in the current flow.

UX quality bar:

- Feedback should feel useful, not generic.
- Avoid overwhelming users with too many metrics.
- Make one correction and one next step clear.
- The result should encourage another attempt.

Testing and verification:

- Build the app.
- Run speaking drill feedback.
- Run Free Talk feedback.
- Run roleplay feedback.
- Run Tutor save/feedback path if available.
- Verify feedback state is visible and not clipped.
- Verify save/review actions work where included.
- Capture screenshots under `DesignReferences/verification/screenshots/parallel-speaking-feedback/`.
- Write a verification note at `DesignReferences/verification/parallel-speaking-feedback.md`.
- Include an enjoyment judgment: would this feedback help a learner speak better?

Done when:

- Speaking flows provide clear and useful feedback.
- Feedback connects to saved/reviewable material where practical.
- Build and simulator checks pass.

## Parallel Goal D: Learning State, Review, And Recommendations

You are working in `/Users/kego/Projects/converlax`, a SwiftUI iOS app for speaking-focused language learning.

Parallel ownership:

- Primary files:
  - `Converlax/Models.swift`
  - `Converlax/LearningState.swift`
  - review/recommendation portions of `Converlax/PhaseOneViews.swift`
- Secondary files only if necessary:
  - `Converlax/CourseViews.swift`
  - `Converlax/LessonPlayerView.swift`
  - `Converlax/PracticeViews.swift`

Avoid large edits to:

- `Converlax/OnboardingView.swift`
- large content rewrites in `BeginnerContent.swift`

Goal:

Make lessons, speaking practice, saved content, review, progress, activity/history, and next recommendations feel connected.

Core loop:

1. User completes learning or speaking activity.
2. App records progress/activity/history.
3. App creates or updates saved lines/review items when appropriate.
4. Review uses due items from real state.
5. Home or completion screens can recommend the next useful action.

Implementation requirements:

- Audit state models and mutation paths.
- Ensure lesson completion creates progress and reviewable artifacts where appropriate.
- Ensure speaking/session completions create useful summary artifacts where appropriate.
- Ensure saving a line makes it visible in saved content and review.
- Ensure review remembered/needs-practice actions reschedule or update items.
- Add simple deterministic next-action logic if missing.
- Prevent bad duplicate clutter from repeated completions.
- Keep architecture local-first and understandable.

Quality bar:

- The app should feel like it remembers what the learner did.
- Review should not feel disconnected from practice.
- Recommendations should be explainable, not random.
- Avoid overengineering backend-like layers.

Testing and verification:

- Build the app.
- Complete one lesson.
- Complete one speaking session or roleplay if possible.
- Save one line.
- Run Smart Review remembered and needs-practice paths.
- Verify Home recommendation changes with state.
- Verify Profile/activity/history/saved content reflect actions.
- Verify relaunch persistence where supported.
- Capture screenshots under `DesignReferences/verification/screenshots/parallel-learning-state/`.
- Write a verification note at `DesignReferences/verification/parallel-learning-state.md`.
- Include an enjoyment judgment: does the app feel attentive and personal?

Done when:

- Core activities feed into saved content, review, progress, and recommendations.
- State changes are visible and useful.
- Build and simulator checks pass.

## Required Final Goal E: Integration And End-To-End Core Learning Audit

Run this only after Parallel Goals A-D have been merged into the same branch.

You are working in `/Users/kego/Projects/converlax`, a SwiftUI iOS app for speaking-focused language learning.

Goal:

Integrate the parallel work into one coherent core learning experience. Fix seams, duplicated concepts, inconsistent copy, broken routes, and disconnected state.

Required full journey:

1. Force onboarding.
2. Select language and beginner level.
3. Land on Home.
4. Start first lesson.
5. Complete first lesson.
6. See next recommendation.
7. Open Practice and complete a speaking flow.
8. See speaking feedback.
9. Save or review a useful line.
10. Open Review and handle due material.
11. Open Profile/history/saved content and confirm the app remembers the work.

Integration checks:

- Onboarding copy matches the first lesson and Home state.
- Course content feeds saved lines/review naturally.
- Speaking feedback uses natural course/situation language.
- Learning state does not duplicate or lose important artifacts.
- Recommendations route correctly.
- Review items are meaningful.
- Screenshots and verification docs from Goals A-D do not contradict the final app.

Testing and verification:

- Run a clean build.
- Run the full journey above in simulator.
- Capture final screenshots under `DesignReferences/verification/screenshots/core-learning-integrated/`.
- Create `DesignReferences/verification/core-learning-integrated.md`.
- Document:
  - Build result
  - Flows tested
  - Issues found and fixed
  - Remaining UX risks
  - Final enjoyment judgment

Final quality checklist:

- New user can complete first session without confusion.
- First completion creates meaningful state.
- Course content feels coherent.
- Speaking feedback is useful.
- Review is connected to prior activity.
- Home recommendation is sensible.
- Saved content/history reflect actual actions.
- The app feels enjoyable, not just functional.

Done when:

- Goals A-D are merged and integrated.
- End-to-end simulator verification passes.
- Final documentation and screenshots exist.

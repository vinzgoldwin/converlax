# Post-Simplification Long-Running Goal Prompts

Date: 2026-05-15

Use these after completing the UI/UX simplification goals. These are intentionally larger than the previous prompts. Each one is designed for a long-running agent session that can inspect the product, implement meaningful changes, verify with simulator runs, and produce evidence.

Recommended sequence:

1. First-session experience
2. Real learning loop
3. Speaking feedback quality
4. Deep content for one course
5. Personalization and recommendations
6. Retention system
7. Backend/data readiness
8. Membership and monetization UX

Do not run all of these in parallel. Goals 1-4 shape the product experience and should mostly be sequential. Goals 5-8 should build on the learning data and UX patterns from the earlier goals.

## Combined Goal A: Build The Core Learning Experience

Use this instead of running Goals 1-4 separately when you want one long-running agent to work through the whole core product experience sequentially.

You are working in `/Users/kego/Projects/converlax`, a SwiftUI iOS app for speaking-focused language learning.

Long-running objective:

Turn Converlax from a simplified UI prototype into a coherent learning product by building one excellent end-to-end beginner experience:

1. A strong first session
2. A real learning loop
3. Useful speaking feedback
4. One deep, practical beginner course path

This is a large product-quality goal. Work sequentially through the milestones below. Do not jump straight into broad refactors. First understand the current app, then improve the user journey from first launch through repeated learning.

Core product thesis:

The app should help a beginner practice real conversation with low friction. Every major activity should feed the same loop: learn useful language, practice it, receive feedback, save/review weak material, and know what to do next.

Reference context:

- Read `DesignReferences/ui-ux-simplification-review.md`.
- Read `DesignReferences/ui-ux-simplification-goal-prompts.md` if it exists.
- Review current screenshots in `DesignReferences/verification/screenshots/`.
- Review Speak/Mobbin references in `DesignReferences/mobbin/`.
- Inspect the current SwiftUI structure before editing.

Likely code areas:

- `Converlax/OnboardingView.swift`
- `Converlax/CourseViews.swift`
- `Converlax/LessonPlayerView.swift`
- `Converlax/PracticeViews.swift`
- `Converlax/TutorView.swift`
- `Converlax/PhaseOneViews.swift`
- `Converlax/Models.swift`
- `Converlax/LearningState.swift`
- `Converlax/BeginnerContent.swift`
- `Converlax/PhaseOneContent.swift`

### Milestone 1: First Session

Goal:

Make the first 1-3 minutes of the app feel excellent.

Required journey:

1. Force onboarding.
2. Select a language.
3. Select beginner level.
4. Start learning.
5. Land on Home with one obvious first action.
6. Start the first lesson.
7. Complete enough of the lesson to see feedback or completion.
8. See what was learned, what was saved, and what to do next.

Implementation requirements:

- Simplify onboarding so it does not show too much product complexity before value.
- Make the post-onboarding Home state focused on the first useful action.
- Ensure the first lesson content is practical, natural, and beginner-friendly.
- Ensure first completion creates meaningful state: progress, saved line, review item, activity, or next recommendation.
- Avoid dead ends after first completion.

Quality bar:

- A new user should not need to understand the whole app to start.
- The first lesson should feel real, not like placeholder content.
- Completion should feel useful, not just celebratory.
- The user should have a reason to return.

### Milestone 2: Learning Loop

Goal:

Connect lessons, speaking practice, saved lines, review, progress, history, and recommendations into one coherent system.

Required loop:

1. Learn a phrase or pattern.
2. Practice it through a lesson, speaking drill, Free Talk, roleplay, or Tutor.
3. Receive feedback.
4. Save useful material.
5. Review weak material later.
6. Get a recommendation for the next best action.

Implementation requirements:

- Audit models and state mutation paths.
- Ensure lesson completion writes progress and reviewable learning artifacts where appropriate.
- Ensure speaking sessions create session summaries and weak/strong phrase artifacts where appropriate.
- Ensure Tutor saved messages appear in saved content and review.
- Ensure Smart Review reads real due items, not only static fixtures.
- Ensure Profile/history/activity reflects actual user actions.
- Prevent obvious duplicate saved items from repeated flows unless intentional.

Quality bar:

- State changes should feel earned and traceable.
- The app should feel like it remembers what the learner did.
- Home should be able to recommend a next useful action based on state.

### Milestone 3: Speaking Feedback

Goal:

Make speaking practice feel valuable by giving structured, specific, saveable feedback.

Required feedback result:

- What the user attempted or said
- A corrected version
- One more natural phrase
- One pronunciation/rhythm/clarity tip
- A simple confidence or clarity signal
- One saveable/reviewable takeaway
- One recommended follow-up action

Implementation requirements:

- Improve feedback for speaking drill, Free Talk, roleplay, and Tutor where applicable.
- Keep the implementation local/mock if no real speech service exists, but make the structure realistic.
- Add reusable UI components only if they reduce duplication.
- Ensure speaking feedback can create saved lines or review items.
- Handle empty/no-input/retry states if those states exist in the current flows.

Quality bar:

- Feedback must be specific to the prompt.
- Avoid too many metrics.
- Prefer one strong correction over many generic comments.
- The result should encourage another attempt.

### Milestone 4: Deep Beginner Course Path

Goal:

Build one beginner course path that feels coherent, practical, and connected to practice/review.

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

- Improve lesson content in `BeginnerContent.swift` and/or `PhaseOneContent.swift`.
- Ensure each lesson has a clear speaking goal.
- Ensure phrases sound natural and beginner-appropriate.
- Reuse learned phrases in later lessons.
- Connect roleplays to course topics.
- Ensure saved lines and review items are meaningful.
- Ensure the deeper path does not make Home or course detail visually cluttered.

Quality bar:

- Content should sound useful when read aloud.
- Lessons should not feel repetitive.
- Roleplays should reinforce course phrases.
- One course should feel convincing before adding breadth.

### Required Testing And Verification

Build:

- Run a clean simulator build.
- Fix compiler errors and warnings caused by your changes.

Simulator flow verification:

- Forced onboarding through first lesson completion.
- Relaunch after onboarding.
- Home next recommendation after first completion.
- Course path browsing.
- Early lesson and later lesson start/completion smoke checks.
- Speaking drill feedback.
- Free Talk completion feedback.
- Roleplay completion feedback.
- Tutor save or feedback path if available.
- Smart Review remembered and needs-practice paths.
- Saved content after learning.
- Profile/activity/history after learning.

State checks:

- Verify progress updates.
- Verify saved lines or learning objects are created.
- Verify review items are scheduled.
- Verify repeated completion does not create bad duplicate clutter.
- Verify review actions reschedule or update item state.
- Verify relaunch persistence where the app already supports persistence.

Screenshot evidence:

Save screenshots under:

- `DesignReferences/verification/screenshots/core-learning-experience/`

Capture at minimum:

- Onboarding
- Home after onboarding
- First lesson start
- First lesson result
- Home recommendation after completion
- Course path
- Speaking feedback
- Free Talk or roleplay feedback
- Review due items
- Saved content
- Activity/history

Documentation deliverable:

Create:

- `DesignReferences/verification/core-learning-experience.md`

Include:

- What changed
- What flows were tested
- Build result
- Screenshot list
- How the learning loop works
- Known limitations
- Final UX judgment: is the core experience enjoyable to use, and where does it still feel weak?

Final quality checklist:

- A new user can complete the first session without confusion.
- The first completion creates meaningful next-step state.
- Main activities feed into progress/review/history.
- Speaking feedback is specific, structured, saveable, and actionable.
- The beginner course path feels coherent and practical.
- Home can guide the user to a useful next action.
- The app feels calmer and more useful than a collection of feature screens.
- Build and simulator smoke tests pass.

Done when:

- One complete beginner learning experience works end to end.
- Learning, speaking, review, saved content, and recommendations are connected.
- Verification evidence exists.
- The final agent assessment explicitly states whether the app is enjoyable to use.

## Goal 1: Make The First Session Feel Excellent

You are working in `/Users/kego/Projects/converlax`, a SwiftUI iOS app for speaking-focused language learning.

Long-running objective:

Design and implement a polished first-session experience that takes a new user from onboarding into one meaningful learning activity, gives them a useful result, and makes the next step obvious.

This goal is not just about UI. It is about the first emotional proof that the app works.

Product outcome:

A new user should be able to:

1. Choose language and level with low friction.
2. Understand what Converlax will help them do.
3. Start the first lesson quickly.
4. Complete a short practice activity.
5. See a useful result: what they learned, what to review, and what to do next.

Key experience principles:

- Do not show the full product too early.
- Do not ask for preferences that do not affect the first session.
- Do not make the first lesson feel like a demo placeholder.
- Do not end the first session with a dead end.
- Make the user feel: "I can actually practice speaking here."

Implementation scope:

- Review and improve `Converlax/OnboardingView.swift`.
- Review and improve Home first-launch state in `Converlax/CourseViews.swift`.
- Review lesson start/completion states in `Converlax/LessonPlayerView.swift` and related lesson views.
- Update local state in `Converlax/LearningState.swift` if first-session tracking is needed.
- Update beginner content in `Converlax/BeginnerContent.swift` or `Converlax/PhaseOneContent.swift` if the first lesson content is weak.
- Add a first-session completion summary if one does not exist.
- Ensure the result creates or previews saved lines/review items where appropriate.

Required user journey:

1. Force onboarding.
2. Select a language.
3. Select beginner level.
4. Start learning.
5. Land on Home with one obvious first action.
6. Start the first lesson.
7. Complete enough of the lesson to see feedback or completion.
8. See what was saved or what should happen next.

Quality bar:

- The first session should be understandable without reading documentation.
- The first lesson should take 1-3 minutes in mock/local form.
- The app should avoid feature overload until after the first result.
- Completion should feel useful, not merely celebratory.
- The user should have a reason to return: a due review, next lesson, streak, or saved phrase.

Testing and verification:

- Build the app successfully.
- Run forced onboarding.
- Capture screenshots for each onboarding step.
- Capture Home immediately after onboarding.
- Capture first lesson start.
- Capture first lesson completion/result.
- Verify local state after completion: progress, saved lines, review items, activity/history if applicable.
- Verify relaunch state: user should not be returned to onboarding unless forced.
- Verify there is no broken route, clipped text, or confusing empty state.
- Perform a five-second comprehension test on Home after onboarding.
- Perform an enjoyment pass: would a real learner feel rewarded enough to continue?

Deliverables:

- Code changes.
- Updated or new verification note under `DesignReferences/verification/`.
- Screenshots under `DesignReferences/verification/screenshots/first-session/`.
- A short final assessment: what improved, what remains weak, and whether the first session is enjoyable.

Done when:

- A new user can complete the first session without confusion.
- The first completion creates meaningful next-step state.
- Build and simulator verification pass.

## Goal 2: Build A Real Learning Loop

You are working in `/Users/kego/Projects/converlax`, a SwiftUI iOS app for speaking-focused language learning.

Long-running objective:

Connect lessons, speaking practice, saved lines, review, progress, history, and recommendations into one coherent learning loop.

The app should stop feeling like separate screens and start feeling like a system that remembers what the learner did and tells them what to do next.

Product outcome:

After a user completes any meaningful activity, the app should update:

- Progress
- Saved lines or learning objects
- Review schedule
- Activity history
- Weak/strong phrase signals
- Next recommended action

Core loop:

1. Learn a phrase or pattern.
2. Practice it by speaking or answering.
3. Receive feedback.
4. Save useful material.
5. Review weak material later.
6. Get a recommendation for the next best action.

Implementation scope:

- Audit data models in `Converlax/Models.swift`.
- Audit persistence and mutation paths in `Converlax/LearningState.swift`.
- Audit content sources in `Converlax/BeginnerContent.swift` and `Converlax/PhaseOneContent.swift`.
- Audit lesson flows in `Converlax/LessonPlayerView.swift`, `Converlax/PracticeViews.swift`, `Converlax/TutorView.swift`, and `Converlax/PhaseOneViews.swift`.
- Ensure lesson completion, Free Talk completion, roleplay completion, Tutor saved messages, and Review outcomes all write consistent learning artifacts.
- Improve or add a `nextRecommendedAction` style concept if needed.
- Ensure Review uses real due items from the learning loop, not only static fixtures.
- Ensure Profile/history surfaces reflect actual user actions.

Required behaviors:

- Completing a lesson creates progress and at least one reviewable object where appropriate.
- Completing speaking practice creates a session summary and reviewable weak phrase where appropriate.
- Saving a tutor line makes it visible in saved content and review.
- Marking a review item remembered/needs practice changes its future schedule.
- Home can show a context-aware next recommendation.
- Profile/history can show recent learning events.

Quality bar:

- Avoid fake-feeling state updates.
- Avoid duplicate saved items when repeating a lesson unless duplication is intentional.
- Keep local/mock architecture simple and inspectable.
- Do not overbuild backend abstractions yet.
- Make state transitions understandable from code.

Testing and verification:

- Build the app.
- Run and complete representative flows:
  - First lesson
  - Speaking drill
  - Free Talk
  - Roleplay
  - Tutor save action
  - Smart review remembered/needs-practice actions
- Verify state changes in UI after each flow.
- Verify relaunch persistence if local persistence already exists.
- Capture screenshots for Home recommendation, Review due items, Saved content, Activity/history.
- Check edge cases:
  - No review items
  - Repeating completed lesson
  - Removing saved line
  - Completing multiple sessions
- Perform an enjoyment pass: does the app feel like it is paying attention to the learner?

Deliverables:

- Code changes.
- Updated verification note under `DesignReferences/verification/learning-loop.md`.
- Screenshots under `DesignReferences/verification/screenshots/learning-loop/`.
- A short explanation of the learning loop and where data is written/read.

Done when:

- Core activities feed into review/progress/history.
- Home recommendation reacts to user state.
- Review feels connected to previous practice.
- Build and representative simulator checks pass.

## Goal 3: Improve Speaking Feedback Quality

You are working in `/Users/kego/Projects/converlax`, a SwiftUI iOS app for speaking-focused language learning.

Long-running objective:

Make speaking practice feel valuable by improving transcript, correction, phrase, confidence, and follow-up feedback after a speaking attempt.

This app's core promise is conversation practice. Speaking feedback must feel more useful than a generic "good job."

Product outcome:

After a speaking activity, the user should see:

- What they said or attempted
- A corrected version
- One better/natural phrase
- One pronunciation or rhythm tip
- A confidence or clarity signal
- One saved/reviewable takeaway
- One recommended follow-up action

Implementation scope:

- Audit speaking-related models in `Converlax/Models.swift`.
- Improve local feedback generation in `Converlax/LearningState.swift`, `Converlax/PhaseOneContent.swift`, or relevant helper code.
- Update speaking drill, Free Talk, roleplay session, and Tutor voice states in:
  - `Converlax/PracticeViews.swift`
  - `Converlax/PhaseOneViews.swift`
  - `Converlax/TutorView.swift`
- Add reusable UI components for feedback if appropriate.
- Keep the implementation local/mock if no real speech service exists, but make the feedback structure realistic.

Required feedback states:

- Before speaking: clear prompt and goal
- Recording/attempting: clear active state
- Processing/mock analysis: brief state if needed
- Feedback: structured, useful, saveable
- Follow-up: retry, review later, next prompt, or start roleplay

Quality bar:

- Feedback should be specific to the prompt.
- Do not overwhelm with too many metrics.
- Prefer one strong correction over five weak comments.
- Make saved/reviewable takeaway obvious.
- The result should encourage another attempt.

Testing and verification:

- Build the app.
- Run speaking drill.
- Run Free Talk.
- Run roleplay session.
- Run Tutor voice/text feedback path if available.
- Verify feedback creates or updates saved lines/review items.
- Capture screenshots for each feedback state.
- Verify empty/no-input and retry states if available.
- Check that feedback cards do not overflow on small screens.
- Perform an enjoyment pass: would a learner feel the feedback helped them speak better?

Deliverables:

- Code changes.
- Screenshots under `DesignReferences/verification/screenshots/speaking-feedback/`.
- Verification note under `DesignReferences/verification/speaking-feedback.md`.
- Brief explanation of the feedback model and limitations.

Done when:

- Speaking feedback is specific, structured, saveable, and actionable.
- Speaking flows feel more valuable than simple completion screens.
- Build and simulator checks pass.

## Goal 4: Build One High-Quality Beginner Course Path

You are working in `/Users/kego/Projects/converlax`, a SwiftUI iOS app for speaking-focused language learning.

Long-running objective:

Make one beginner course path feel real, coherent, and useful instead of broad but shallow. Pick the current primary course path already used by the app and deepen it.

Product outcome:

The app should have a beginner path with enough quality content that a user can believe the product can teach them useful conversation.

Course quality requirements:

- Clear progression from easier to harder.
- Realistic situations.
- Useful phrases, not artificial textbook lines.
- Mix of listen/read/speak/review.
- Reuse of learned phrases in later lessons.
- Saved lines and review items generated from course content.
- Roleplays connected to lesson topics.

Implementation scope:

- Audit `Converlax/BeginnerContent.swift`.
- Audit `Converlax/PhaseOneContent.swift`.
- Improve lesson data models only if needed.
- Add or refine course units, lessons, steps, saved words/lines, review prompts, and roleplay connections.
- Ensure Home/course detail can display the deeper path without becoming visually cluttered.
- Ensure Review and Practice can use the improved content.

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

Quality bar:

- Lines should sound natural.
- Lessons should have a clear speaking goal.
- Avoid content that is too similar across lessons.
- Keep beginner level realistic.
- Make roleplays use the same phrases learned in lessons.

Testing and verification:

- Build the app.
- Browse Home/course detail.
- Open multiple lessons across the beginner path.
- Complete at least one early lesson and one later lesson.
- Verify saved lines/review items are meaningful.
- Verify roleplays align with course topics.
- Capture screenshots for course path, lesson detail, lesson player, saved lines, and review.
- Do a content quality pass: read the phrases aloud and judge whether they sound useful in real conversation.
- Do an enjoyment pass: would a beginner feel they are learning practical language?

Deliverables:

- Code/content changes.
- Verification note under `DesignReferences/verification/course-content-quality.md`.
- Screenshots under `DesignReferences/verification/screenshots/course-content/`.
- Summary of the course arc and remaining content gaps.

Done when:

- One beginner path feels coherent and practical.
- Content connects across lessons, practice, and review.
- Build and simulator checks pass.

## Goal 5: Add Personalization And Next-Best Action Recommendations

You are working in `/Users/kego/Projects/converlax`, a SwiftUI iOS app for speaking-focused language learning.

Long-running objective:

Make the app choose a useful next action for the learner based on their recent activity, due reviews, saved lines, mistakes, unfinished lessons, streak state, and speaking history.

Product outcome:

Home and key completion screens should answer: "What should I do next?"

Recommendation inputs:

- Current lesson progress
- Due review items
- Saved lines
- Weak phrases or mistakes
- Recent practice session type
- Streak/daily goal
- User level
- Repeated skipped/unfinished actions if tracked

Implementation scope:

- Add or improve recommendation logic in `Converlax/LearningState.swift` or a small dedicated helper.
- Update Home in `Converlax/CourseViews.swift`.
- Update completion screens in `Converlax/LessonPlayerView.swift`, `Converlax/PracticeViews.swift`, and `Converlax/PhaseOneViews.swift`.
- Update Review/Practice entry points if recommendations should deep-link there.
- Keep algorithm simple, deterministic, and explainable.

Recommended priority logic:

1. If user has not completed first session: continue first lesson.
2. If due review items exist: review due items.
3. If current lesson is unfinished: continue lesson.
4. If weak speaking phrase exists: speaking drill.
5. If daily goal not met: shortest useful practice.
6. Otherwise: next course lesson or suggested roleplay.

Quality bar:

- Avoid random recommendations unless explicitly framed as suggestions.
- Recommendation copy should explain why this action is suggested.
- Do not show too many recommendations at once.
- Recommendations should deep-link correctly.

Testing and verification:

- Build the app.
- Test states:
  - New user
  - After first lesson
  - With due review
  - After Free Talk
  - After weak phrase feedback
  - After daily goal complete
- Verify Home recommendation changes appropriately.
- Verify recommended action routes work.
- Capture screenshots for each state if feasible.
- Add deterministic launch/test hooks only if they fit the existing project pattern.
- Do an enjoyment pass: does the app feel helpful, or bossy/confusing?

Deliverables:

- Code changes.
- Verification note under `DesignReferences/verification/recommendations.md`.
- Screenshots under `DesignReferences/verification/screenshots/recommendations/`.
- Short explanation of recommendation priority rules.

Done when:

- Home and completion screens guide the learner intelligently.
- Recommendations are state-based and route correctly.
- Build and simulator checks pass.

## Goal 6: Improve Retention Without Making The App Annoying

You are working in `/Users/kego/Projects/converlax`, a SwiftUI iOS app for speaking-focused language learning.

Long-running objective:

Improve the app's retention mechanics: streak, daily goal, reminders, progress summaries, and comeback states. The goal is to make return visits feel worthwhile, not manipulative.

Product outcome:

The learner should know:

- What they accomplished today
- What remains for their daily goal
- What they should do tomorrow
- What streak/progress means
- Where to continue after returning

Implementation scope:

- Audit streak/daily-goal models in `Converlax/Models.swift` and `Converlax/LearningState.swift`.
- Improve Home streak/progress display in `Converlax/CourseViews.swift`.
- Improve Profile/streak display in `Converlax/PhaseOneViews.swift`.
- Improve completion summaries after lessons/review/practice.
- Improve reminder settings only if they are meaningful in the local/mock app.
- Avoid deep notification implementation unless already supported.

Retention states to support:

- No streak yet
- First day complete
- Daily goal partially complete
- Daily goal complete
- Returning after recent activity
- Returning with due review
- Streak risk/missed day if model supports it

Quality bar:

- Retention copy should encourage, not shame.
- Streak should not dominate learning quality.
- Daily goal should be visible but not noisy.
- Progress summaries should be short and useful.

Testing and verification:

- Build the app.
- Simulate or create states for no streak, partial daily goal, complete daily goal, and due review.
- Verify Home, Profile, and completion screens reflect those states.
- Verify settings/reminder copy is honest if reminders are mock-only.
- Capture screenshots for retention states.
- Do an enjoyment pass: does the app make returning feel rewarding without pressure?

Deliverables:

- Code changes.
- Verification note under `DesignReferences/verification/retention.md`.
- Screenshots under `DesignReferences/verification/screenshots/retention/`.
- Summary of retention mechanics and remaining backend needs.

Done when:

- Streak/daily goal/progress are clearer and less noisy.
- Return states guide the user back into useful practice.
- Build and simulator checks pass.

## Goal 7: Prepare Data And Backend Boundaries

You are working in `/Users/kego/Projects/converlax`, a SwiftUI iOS app for speaking-focused language learning.

Long-running objective:

Prepare the app's local data and service boundaries so future backend/auth/sync work can be added without rewriting the product logic.

This is not a request to build a backend. It is a request to cleanly define what should eventually sync, what remains local, and how the app should be structured for that future.

Product/data outcome:

The app should have clear boundaries for:

- User profile
- Course progress
- Saved lines/learning objects
- Review schedule
- Practice history
- Activities
- Favorites
- Settings/preferences
- Membership/account placeholders

Implementation scope:

- Audit `Converlax/Models.swift`.
- Audit `Converlax/LearningState.swift`.
- Audit all places that mutate learning state.
- Improve model naming, Codable structures, IDs, and persistence boundaries if needed.
- Add lightweight service/protocol boundaries only where they remove real complexity.
- Document future backend sync assumptions.
- Do not introduce a real backend dependency.

Quality bar:

- State mutation should be easy to trace.
- Models should avoid accidental duplication.
- IDs should be stable.
- Persistence should be robust against missing/older fields where practical.
- Avoid overengineering.

Testing and verification:

- Build the app.
- Exercise flows that write state.
- Relaunch and verify persisted state still loads.
- If model migrations are needed, handle old/missing data safely.
- Check reset progress/restart onboarding behavior.
- Verify no data-loss surprises from normal use.
- Do a developer-experience pass: can a future backend agent understand where sync belongs?

Deliverables:

- Code changes.
- Documentation under `Documentation/` or `DesignReferences/verification/data-boundaries.md`.
- A list of future backend API/resource candidates.
- Build and simulator evidence.

Done when:

- Local product state has clear ownership and future backend boundaries.
- Existing app behavior still works.
- Build and representative simulator checks pass.

## Goal 8: Design Membership And Monetization UX After Value Is Clear

You are working in `/Users/kego/Projects/converlax`, a SwiftUI iOS app for speaking-focused language learning.

Long-running objective:

Design and implement a mock/local membership UX that fits the simplified app and communicates value without interrupting the learning loop too early.

Important:

Do not add aggressive paywalls. The goal is to design responsible membership UX after the app has demonstrated value.

Product outcome:

The app should clearly explain:

- What is free
- What membership unlocks
- Why membership is useful
- How to manage membership
- How to restore purchases later
- Where login/account will fit

Implementation scope:

- Audit membership/account placeholders in `Converlax/PhaseOneViews.swift`.
- Improve Settings/Profile membership surfaces.
- Add mock membership state if needed.
- Add paywall/value screen only at appropriate moments.
- Keep purchase actions mocked unless a real payment framework is explicitly requested later.
- Ensure copy is honest that billing is not connected if still local/mock.

Potential membership value areas:

- More speaking sessions
- Personalized lesson generation
- Advanced feedback
- Unlimited saved-line review
- Progress sync
- Community roleplays

UX quality bar:

- Membership should not block the first successful learning session.
- Paywall timing should happen after value, not before value.
- Copy should be concrete and tied to learning outcomes.
- Account/membership screens should feel credible even if mocked.

Testing and verification:

- Build the app.
- Test Profile -> Settings -> Membership.
- Test any membership entry points from feature limits if added.
- Test free and member mock states.
- Verify no accidental dead-end purchase buttons.
- Capture screenshots for membership screens.
- Do an enjoyment/trust pass: does the monetization feel fair and understandable?

Deliverables:

- Code changes.
- Screenshots under `DesignReferences/verification/screenshots/membership/`.
- Verification note under `DesignReferences/verification/membership-ux.md`.
- Summary of monetization assumptions and future real billing needs.

Done when:

- Membership UX is understandable and non-invasive.
- Mock account/billing surfaces feel cleaner and more credible.
- Build and simulator checks pass.

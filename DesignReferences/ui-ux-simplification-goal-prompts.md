# UI/UX Simplification Goal Prompts

Date: 2026-05-15

Use these prompts one at a time. Each goal is scoped so an implementation agent can make changes, test them, and judge whether the resulting flow feels simpler and more enjoyable to use.

## Goal 1: Simplify The App Navigation Around User Jobs

You are working in `/Users/kego/Projects/converlax`, a SwiftUI iOS app.

Goal:

Simplify the primary navigation so users no longer need to choose between overlapping feature categories. The current tabs are Home, Free Talk, Review, Roleplays, and Profile. Replace this with a clearer user-job structure:

- Home: continue learning, current course progress, streak
- Practice: speaking practice, free talk, roleplays, tutor, custom practice
- Review: review due items and saved lines
- Profile: learner progress, saved content, history, settings

Context:

- Review `DesignReferences/ui-ux-simplification-review.md`.
- Compare the current app screenshots in `DesignReferences/verification/screenshots/`.
- Compare the saved Speak references in `DesignReferences/mobbin/`, especially home, free-talk, topics, profile, and settings.

Implementation requirements:

- Update `AppTab` in `Converlax/Models.swift`.
- Update `MainTabView` in `Converlax/ContentView.swift`.
- Merge the current Free Talk and Roleplays root concepts into a new Practice root screen.
- Keep existing deep flows available, but stop exposing duplicate top-level entries.
- Ensure launch arguments still work or update them cleanly if tab names/routes change.
- Keep code localized to navigation and root screen structure unless a supporting model change is necessary.

UX quality requirements:

- The tab bar should answer four questions clearly: learn, practice, review, profile.
- A first-time user should not see both Free Talk and Roleplays as separate global destinations.
- The Practice tab should feel like one coherent place for speaking, not a collection of unrelated utilities.
- No root tab should feel like a placeholder or duplicate of another tab.

Testing and verification:

- Build the app for simulator using the existing Xcode project.
- Run the app to each root tab with launch arguments or manual simulator navigation.
- Capture screenshots for Home, Practice, Review, and Profile.
- Verify no broken navigation destinations after merging Free Talk and Roleplays.
- Verify back navigation still works from nested Practice routes.
- Check the accessibility tree or simulator UI snapshot to confirm tab labels are correct.
- Do a usability pass: open the app cold and judge whether the next place to tap is obvious within five seconds.

Done when:

- The app has a simpler tab model.
- All previous Free Talk and Roleplay functionality remains reachable.
- The root navigation feels less crowded and more purposeful.
- Build and simulator smoke tests pass.

## Goal 2: Rebuild Home Into A Single Next-Action Screen

You are working in `/Users/kego/Projects/converlax`, a SwiftUI iOS app.

Goal:

Redesign the Home screen so it focuses on one obvious next learning action instead of showing many equal-weight choices.

Current problem:

Home currently shows level, Course/Practice segmented control, streak, progress, unit text, a large lesson card, quick action tiles, and bottom tabs. It feels like a dashboard, but this app should feel like guided learning.

Target hierarchy:

1. Compact greeting or course status
2. One dominant Continue lesson card
3. One streak/progress row
4. One small secondary row for extra practice or course path

Implementation requirements:

- Update `Converlax/CourseViews.swift`, especially `CourseHomeView`, `CourseHeader`, `HomeQuickActions`, and `FeaturedLessonCard`.
- Remove or demote the Course/Practice segmented control.
- Remove the four quick-action tiles from the first viewport.
- Keep the current lesson/start flow intact.
- Keep course detail reachable, but not as a competing primary action.
- Use the existing Converlax visual language, but reduce same-weight cards.

UX quality requirements:

- The first viewport should have one unmistakable primary CTA.
- Secondary choices should not visually compete with Continue/Start.
- The user should understand their current lesson and progress without reading long paragraphs.
- The screen should feel calm, focused, and inviting to start.

Testing and verification:

- Build the app.
- Launch directly to Home.
- Capture a Home screenshot.
- Verify tapping the primary Continue/Start action begins or opens the correct lesson.
- Verify course detail/progress is still reachable.
- Test on at least one smaller simulator viewport if available, or inspect that the first viewport does not feel cramped.
- Check text truncation and overlap.
- Do an enjoyment pass: pretend you are a tired learner opening the app for a two-minute practice session. Confirm the screen gives you a clear, low-effort next step.

Done when:

- Home no longer looks like a feature menu.
- One primary action dominates.
- Existing lesson functionality still works.
- Visual hierarchy is noticeably simpler than the previous screenshot.

## Goal 3: Create A Focused Practice Screen

You are working in `/Users/kego/Projects/converlax`, a SwiftUI iOS app.

Goal:

Create one focused Practice screen that combines Free Talk, Roleplays, Tutor, and Custom Roleplay without overwhelming the user.

Current problem:

Free Talk currently shows Start Free Talk, Create roleplay, Topics, History, Community, Topics list, and Recent usage. Roleplays also exists as its own root tab. This creates duplicated entry points and too many choices.

Target hierarchy:

1. Primary CTA: Start speaking
2. Secondary CTA: Choose a situation
3. Small action: Create custom roleplay
4. Tutor entry as a clearly secondary option
5. History/Favorites/Community moved to filters, menus, or Profile

Implementation requirements:

- Update or replace `FreeTalkHomeView` and `RoleplaysHomeView` in `Converlax/PhaseOneViews.swift`.
- Create a coherent `PracticeHomeView` or equivalent.
- Keep Free Talk session, roleplay detail, topic browser, create roleplay, community, favorites, and history available through sensible paths.
- Remove duplicate roleplay lists from root-level navigation.
- Convert Community and Favorites from separate primary cards into filters or profile/menu destinations.
- Avoid adding new major components unless needed.

UX quality requirements:

- The Practice screen should immediately communicate: "speak now or pick a scenario."
- Avoid presenting management actions like History as first-class practice choices.
- Roleplay, topic, community, and favorites should feel like variants of choosing a situation, not separate product areas.
- The screen should feel actionable, not archival.

Testing and verification:

- Build the app.
- Launch to Practice.
- Capture screenshots of Practice root, choose-situation/browser, roleplay detail, and active Free Talk session.
- Verify Start speaking works.
- Verify Choose a situation works.
- Verify custom roleplay creation still works.
- Verify favorited/community roleplays are still discoverable.
- Verify practice history remains reachable from Profile or a menu.
- Do a usability pass: a new user should be able to start speaking in one tap and choose a roleplay in two taps.
- Do an enjoyment pass: check whether Practice feels like a confident speaking surface rather than a directory of features.

Done when:

- Free Talk and Roleplays are unified into one Practice experience.
- No major practice feature is lost.
- Duplicate entry points are reduced.
- The root Practice screen is simple enough to scan quickly.

## Goal 4: Simplify Lesson And Course Detail Flow

You are working in `/Users/kego/Projects/converlax`, a SwiftUI iOS app.

Goal:

Make lesson and course detail screens help the user start learning instead of presenting another menu of modes.

Current problem:

Lesson detail currently shows a lesson card plus Start lesson, Lesson lines, and Speaking drill as equal rows. Course detail also exposes multiple lesson modes. This makes lessons feel complicated before the learner starts.

Target hierarchy for lesson detail:

1. Lesson title and learning goal
2. One primary Start button
3. Compact "what you will practice" preview
4. Lesson lines and speaking drill available after start, after completion, or in a secondary menu

Implementation requirements:

- Update `LessonDetailView` in `Converlax/PhaseOneViews.swift`.
- Review `CourseDetailView` in `Converlax/CourseViews.swift`.
- Ensure Start lesson remains the dominant action.
- Demote Lesson lines and Speaking drill.
- Keep lesson lines accessible because they are useful, but avoid making them compete with Start.
- Keep current lesson player routes functional.

UX quality requirements:

- A lesson detail screen should reduce uncertainty, not increase it.
- The user should not need to understand all lesson modes before starting.
- The screen should feel like a clear doorway into the lesson.
- Secondary learning tools should be discoverable but not loud.

Testing and verification:

- Build the app.
- Launch to Home, open a lesson detail, start the lesson, and complete or smoke-test the lesson start.
- Open lesson lines from the new secondary location and verify content still appears.
- Open speaking drill if it remains available and verify it works.
- Capture screenshots for course detail and lesson detail.
- Check that primary and secondary button styling are visually distinct.
- Do an enjoyment pass: ask whether a learner would hesitate on this screen or naturally tap Start.

Done when:

- Lesson detail has one clear primary action.
- Course/lesson supporting tools remain reachable.
- The route feels simpler and more confidence-building.
- Build and route smoke tests pass.

## Goal 5: Clean Up Profile, History, Saved Content, And Settings

You are working in `/Users/kego/Projects/converlax`, a SwiftUI iOS app.

Goal:

Make Profile the home for learner state and management tasks, while reducing noise from learning/practice root screens.

Current problem:

Profile shows stats plus Saved lines, Activities, Copy referral link, and Settings as equal rows. Other management surfaces like History, Favorites, and Community also appear too prominently in practice flows.

Target hierarchy:

- Profile header: learner identity, streak, core progress
- Main rows: Saved content, Practice history, Activity
- Settings row
- Referral, membership, notification, voice recognition, support, and placeholder/backend-dependent items should live inside Settings or lower-priority sections

Implementation requirements:

- Update `SpeakProfileHomeView`, `SettingsView`, `HistoryUsageView`, `FavoritesView`, `SavedLinesView`, and `ActivitiesView` in `Converlax/PhaseOneViews.swift` as needed.
- Move practice history into Profile if it is removed from Practice root.
- Move Favorites into Saved content or a filter inside roleplay browsing.
- Demote Copy referral link from primary Profile hierarchy.
- Avoid pushing users into very thin settings screens unless there is meaningful configuration.
- If notification or voice-recognition services are placeholders, show that inline or in Settings rather than as prominent destinations.

UX quality requirements:

- Profile should feel like "my learning and account," not another feature launcher.
- Settings should feel organized and honest about placeholder features.
- Saved content and history should be easy to find later, but should not interrupt first-session practice.
- Rows should have clear priority and grouping.

Testing and verification:

- Build the app.
- Launch to Profile.
- Verify Saved content, Practice history, Activities, and Settings are reachable.
- Verify any moved History/Favorites links still have a path.
- Verify Settings subroutes work or are intentionally demoted inline.
- Capture screenshots of Profile, Saved content, Practice history, and Settings.
- Check text truncation and row density.
- Do a usability pass: after finishing a practice session, confirm it is obvious where to find history and saved material.
- Do an enjoyment pass: Profile should feel calm and useful, not like a miscellaneous drawer.

Done when:

- Management features are grouped under Profile/Settings.
- Practice and Home have less clutter.
- Placeholder settings do not feel like broken product areas.
- Build and simulator checks pass.

## Goal 6: Reduce Visual Noise And Equal-Weight Cards Across The App

You are working in `/Users/kego/Projects/converlax`, a SwiftUI iOS app.

Goal:

Refine the shared component system so screens have clearer visual hierarchy and fewer same-looking cards.

Current problem:

Many screens use similar white cards, colored badges, and asset illustrations. Primary, secondary, and tertiary actions often look equally important.

Target component rules:

- Maximum one large primary card per screen.
- Secondary actions should usually be list rows.
- Tertiary actions should be compact text/icon rows, menus, filters, or inline controls.
- Asset illustrations should be used for primary moments, empty states, or high-value surfaces, not every row.
- Section headers should guide action and avoid repeating the navigation title.

Implementation requirements:

- Audit and update shared UI components in:
  - `Converlax/PhaseOneViews.swift`: `HeroActionCard`, `MiniFlowCard`, `SettingsLikeRow`, `RoleplayRow`, `SectionHeader`
  - `Converlax/CourseViews.swift`: `QuickActionCard`, `FeaturedLessonCard`, `LessonRow`
  - `Converlax/ThemeAndComponents.swift` if needed
- Apply changes across Home, Practice, Review, Profile, Settings, and key detail screens.
- Avoid unrelated restyling or a full visual redesign.
- Preserve Converlax branding and existing assets, but use them more selectively.

UX quality requirements:

- Users should immediately see what is primary, secondary, and optional.
- Root screens should not look like grids of equally important choices.
- Screens should feel lighter, calmer, and easier to scan.
- Repeated card patterns should not make the app feel generic or mechanically generated.

Testing and verification:

- Build the app.
- Capture screenshots for Home, Practice, Review, Profile, Lesson detail, and Roleplay detail.
- Compare before/after screenshots against `DesignReferences/verification/screenshots/ui-audit-contact-sheet.jpg`.
- Check all tappable rows still have adequate hit areas.
- Check dynamic text and smaller viewport behavior where practical.
- Check that visual changes do not break navigation links.
- Do an enjoyment pass: scroll through root screens and judge whether the interface feels calmer and more guided.

Done when:

- Primary actions are visually obvious.
- Secondary actions are lighter.
- Repeated card density is reduced.
- The app feels simpler without removing important functionality.

## Goal 7: Tighten Copy, Labels, And Onboarding For Clarity

You are working in `/Users/kego/Projects/converlax`, a SwiftUI iOS app.

Goal:

Make app copy more action-oriented and reduce repeated labels, especially on root screens and onboarding.

Current problems:

- Some screens repeat the page title as a section title.
- Some labels describe product features instead of user intent.
- Onboarding introduces several product modes before the user has experienced value.

Recommended copy direction:

- Free Talk or Practice root: "Start speaking"
- Roleplays/topics browser: "Choose a situation"
- Review root: "Due today" or "Review due items"
- Saved lines review: "Practice saved lines"
- History & usage: "Practice history"
- Roleplays: consider "Situations" when shown to users

Implementation requirements:

- Update visible copy in Home, Practice, Review, Profile, Settings, lesson detail, and onboarding.
- Update `OnboardingView.swift` so each onboarding step has one main promise.
- Move nonessential setup preferences out of onboarding if they do not affect the first session.
- Avoid adding explanatory instructional text inside the app unless it directly helps the current action.
- Keep strings concise and natural.

UX quality requirements:

- Copy should tell the user what they can do, not just name a feature.
- Avoid repeating navigation titles in section headers.
- Onboarding should feel fast and value-focused.
- New labels should make navigation easier, not cleverer.

Testing and verification:

- Build the app.
- Step through onboarding from a forced onboarding launch argument.
- Capture onboarding screenshots.
- Capture root screen screenshots after copy changes.
- Check text fit on buttons, cards, and rows.
- Check that accessibility labels still make sense if they exist.
- Do a five-second comprehension test: from each root screen, identify the intended next action without opening another screen.
- Do an enjoyment pass: onboarding should feel like setup for an immediate useful session, not a questionnaire.

Done when:

- Root screen copy is less repetitive.
- Onboarding feels shorter and clearer.
- Labels map to user intent.
- No text overflow or awkward truncation is introduced.

## Goal 8: Final End-To-End UX Quality Audit

You are working in `/Users/kego/Projects/converlax`, a SwiftUI iOS app.

Goal:

Perform a final quality audit after the simplification work. Do not start with new feature work. First inspect the app as a user, find friction, then make only small fixes needed to meet the simplification goals.

Audit flow:

1. Fresh launch and onboarding
2. Home to first lesson
3. Practice to free speaking
4. Practice to roleplay/situation
5. Review due items
6. Saved content and history from Profile
7. Settings

Quality checklist:

- Can a new user identify the next action on Home within five seconds?
- Can a new user start speaking within one tap from Practice?
- Can a new user choose a roleplay/situation within two taps from Practice?
- Are management/history actions findable but not distracting?
- Are there fewer duplicate entry points than before?
- Does every root screen have one clear purpose?
- Are primary and secondary actions visually distinct?
- Are placeholder/backend-dependent features demoted appropriately?
- Does the UI feel calm and enjoyable to use?
- Does any screen still feel like a feature inventory?

Testing requirements:

- Run a clean simulator build.
- Run representative launch routes for Home, Practice, Review, Profile, onboarding, lesson detail, roleplay detail, saved content, history, and settings.
- Capture final screenshots into `DesignReferences/verification/screenshots/`.
- Create or update a short verification note under `DesignReferences/verification/`.
- Include any known remaining UX risks.
- Confirm there are no compiler warnings or errors.
- Confirm no obvious navigation dead ends.
- Confirm no visible text overlap, clipped primary buttons, or broken safe-area layout.

Implementation requirements:

- Fix small issues found during the audit.
- Do not re-expand the app surface area.
- Do not add new features unless required to repair a broken flow.
- Preserve user data/local state behavior where possible.

Done when:

- The app passes build and simulator smoke tests.
- Final screenshots show a simpler root hierarchy.
- The verification note documents what was tested.
- The final agent judgment explicitly states whether the app is enjoyable to use, where it still feels heavy, and what should be improved next.

# UI/UX Simplification Review

Date: 2026-05-15

## Scope

This review focuses on reducing cognitive load across Converlax after the Speak-parity Phase 1 expansion.

Evidence used:

- Current Converlax screenshots in `DesignReferences/verification/screenshots/`
- Current Speak/Mobbin references in `DesignReferences/mobbin/`
- Speak reference manifest in `DesignReferences/mobbin/reference-manifest.md`
- Main SwiftUI entry points in `Converlax/ContentView.swift`, `Converlax/CourseViews.swift`, and `Converlax/PhaseOneViews.swift`

The main issue is not missing functionality. The issue is that too many features are presented as equal choices, so users have to understand the app structure before they can start practicing.

## Overall Diagnosis

Converlax currently feels like a full feature inventory. Speak generally feels like a guided practice product: one dominant next action, a small number of secondary choices, and deeper features tucked into profile, settings, course detail, or contextual menus.

The app should move from "show everything the app can do" to "show the best next thing to do."

## P0 Fixes

### 1. Reduce Primary Tabs From Five Concepts To Four User Jobs

Current tabs are Home, Free Talk, Review, Roleplays, and Profile. This makes Free Talk and Roleplays compete even though both are speaking practice.

Recommended structure:

- Home: next lesson, streak, current course progress
- Practice: free talk, roleplay, tutor, custom practice
- Review: smart review, saved lines
- Profile: progress, saved content, settings

Why:

- Users should not need to choose between Free Talk and Roleplays at the navigation level.
- Speak exposes Free Talk, Challenge, and Profile as high-level modes, but the reference also keeps many roleplay/topic actions inside one practice surface.
- Converlax's current Roleplays tab duplicates actions already available from Free Talk.

Likely code areas:

- `Converlax/Models.swift`: `AppTab`
- `Converlax/ContentView.swift`: `MainTabView`
- `Converlax/PhaseOneViews.swift`: merge `FreeTalkHomeView` and `RoleplaysHomeView` into a simpler `PracticeHomeView`

### 2. Make Home A Single Next-Action Screen

Current Home shows level, course/practice segmented control, streak, progress, unit text, a large lesson card, quick actions, and bottom tabs. It asks the user to parse the product model before starting.

Recommended Home hierarchy:

1. Greeting or compact course status
2. One dominant "Continue" lesson card
3. One streak/progress row
4. One small "More practice" row or carousel

Remove or demote from Home:

- Course/Practice segmented control
- Four quick action tiles
- Repeated course/tutor entry cards
- Long unit descriptions
- Multiple visible lesson paths before the user has started

Why:

- The Speak home reference has a clear "Next up in course" card and a single Start CTA.
- Secondary items such as Word Smart and Verb Master are smaller jump-in rows.
- Converlax gives too much visual weight to secondary routes.

Likely code area:

- `Converlax/CourseViews.swift`: `CourseHomeView`, `CourseHeader`, `HomeQuickActions`, `FeaturedLessonCard`

### 3. Collapse Free Talk, Topics, Community, Favorites, And History Into One Practice Surface

Current Free Talk shows Start Free Talk, Create roleplay, Topics, History, Community, Topics list, and Recent usage. This is too many destinations for a new user.

Recommended Practice hierarchy:

1. Primary CTA: Start speaking
2. Secondary CTA: Choose a roleplay
3. Small row: Create custom roleplay
4. History and favorites hidden behind top-right menu or Profile
5. Community as a filter within roleplays, not a separate card

Why:

- History, Favorites, and Community are management/discovery tools, not first-session actions.
- The user intent on this screen is "practice speaking now."

Likely code area:

- `Converlax/PhaseOneViews.swift`: `FreeTalkHomeView`, `quickActions`, `TopicsBrowserView`, `CommunityView`, `FavoritesView`, `HistoryUsageView`

### 4. Remove Duplicate Roleplay Entry Points

Roleplay-related actions appear in:

- Free Talk quick actions
- Free Talk topics list
- Dedicated Roleplays tab
- Community screen
- Favorites screen
- Topic detail
- Create roleplay

Recommended model:

- One roleplay browser
- Filters inside it: Recommended, Community, Favorites, Recent
- Detail screen only after a roleplay is chosen

Why:

- Repeated entry points make the app feel bigger than it is.
- Users may wonder whether Topics, Roleplays, Community, and Favorites are different lesson types.

Likely code area:

- `Converlax/PhaseOneViews.swift`: `RoleplaysHomeView`, `TopicsBrowserView`, `TopicDetailView`, `CommunityView`, `FavoritesView`

### 5. Simplify Lesson Detail Into A Start Screen

Current lesson detail shows lesson card, Start lesson, Lesson lines, and Speaking drill. This turns a lesson into another menu.

Recommended hierarchy:

1. Lesson title and goal
2. One primary Start button
3. Expandable "What you will practice"
4. Lines and speaking drill available after starting or after completion

Why:

- A detail screen should reduce uncertainty before starting.
- Lesson lines and speaking drill are useful, but they should not compete with the main start action.

Likely code area:

- `Converlax/PhaseOneViews.swift`: `LessonDetailView`

## P1 Fixes

### 6. Move Saved Lines, Activities, Referral, And Settings Under A Cleaner Profile Hierarchy

Current Profile shows stats plus four equal rows: Saved lines, Activities, Copy referral link, Settings.

Recommended Profile hierarchy:

- Top: learner identity and streak/progress
- Main list:
  - Saved content
  - Activity history
  - Settings
- Referral should be in Settings or a small secondary row, not a primary row.

Why:

- "Copy referral link" is not a core learning task.
- Speak's profile groups saved lines, saved words, referral, courses, and activity with clearer spacing and softer priority.

Likely code area:

- `Converlax/PhaseOneViews.swift`: `SpeakProfileHomeView`

### 7. Make Review More Action-Oriented

Current Review has Smart review, Saved lines review, and How review works. It is simple, but still sounds like a feature menu.

Recommended copy and hierarchy:

- Primary: Review due items
- Secondary: Practice saved lines
- Move "How review works" to an info icon or bottom sheet

Why:

- The screen should answer "what should I review now?"
- "How review works" is helpful but not a primary action.

Likely code area:

- `Converlax/PhaseOneViews.swift`: `ReviewHomeView`

### 8. Reduce Card Density And Repeated Visual Treatment

Many screens use similar white cards with colored asset badges. This makes primary, secondary, and tertiary actions look equally important.

Recommended visual system:

- One large primary card per screen maximum
- Secondary rows should be list rows, not cards
- Tertiary actions should be text/icon rows or menus
- Use asset illustrations only for primary or empty states

Why:

- The current UI has many same-weight containers, so users cannot easily scan priority.
- Speak uses card weight selectively: the main action is visually stronger, utility rows are lighter.

Likely code areas:

- `Converlax/PhaseOneViews.swift`: `HeroActionCard`, `MiniFlowCard`, `SettingsLikeRow`, `RoleplayRow`
- `Converlax/CourseViews.swift`: `QuickActionCard`, `FeaturedLessonCard`, `LessonRow`

### 9. Make Screen Titles And Section Titles Less Repetitive

Examples:

- Free Talk screen title: "Free Talk"; section title: "Free Talk"
- Review screen title: "Review"; section title: "Review"
- Roleplays screen title: "Roleplays"; section title: "Roleplays"

Recommended:

- Keep navigation title short.
- Use section title to describe the user's next action, not repeat the page name.

Examples:

- Free Talk -> "Start speaking"
- Review -> "Due today"
- Roleplays -> "Choose a situation"

Why:

- Repeated labels waste valuable screen space and make the app feel more complex.

Likely code area:

- `Converlax/PhaseOneViews.swift`: section headers across root screens

### 10. Demote Settings Branches That Are Currently Placeholder-Like

Notification and voice recognition screens are extremely thin. They should not feel like major product destinations until real services exist.

Recommended:

- Keep notification and voice recognition as settings rows.
- Show inline status text or a disabled row when the backend/service is not connected.
- Avoid pushing to a mostly empty screen unless there is meaningful configuration.

Why:

- Thin screens make the product feel unfinished and increase navigation cost.

Likely code area:

- `Converlax/PhaseOneViews.swift`: `SettingsView`, `VoiceRecognitionSettingsView`

## P2 Fixes

### 11. Tighten Onboarding To One Main Promise Per Step

Current onboarding is mostly clear, but the intro lists three product modes immediately.

Recommended:

- Step 1: one promise, one visual, one CTA
- Step 2: language choice
- Step 3: level choice
- Step 4: optional preferences only if they affect the first session

Consider moving reminders and text-mode settings to Settings after onboarding.

Why:

- New users need to start practicing quickly.
- Preferences before value can feel like setup work.

Likely code area:

- `Converlax/OnboardingView.swift`

### 12. Create Progressive Disclosure Rules

Use these rules when deciding whether a feature belongs on a root screen:

- First-session action: visible on Home or Practice
- Repeated daily action: visible on Home, Practice, or Review
- Management/history action: Profile or menu
- Explanation/help action: info icon, sheet, or Settings
- Placeholder/backend-dependent action: Settings only

This would move History, Activities, Referral, settings branches, and some favorites/community affordances away from the main paths.

### 13. Rename Some Navigation Concepts Around User Intent

Potential naming changes:

- Free Talk -> Speak
- Roleplays -> Situations
- Smart review -> Review due items
- Saved lines review -> Practice saved lines
- History & usage -> Practice history

Why:

- Product labels like "Free Talk" and "Roleplays" can be clear after learning the app, but intent labels are easier for first-time users.

## Recommended Implementation Order

1. Merge Free Talk and Roleplays into a single Practice tab.
2. Rebuild Home around one Continue card and remove the Course/Practice segment.
3. Simplify Practice to Start speaking, Choose a situation, and Create custom roleplay.
4. Move History, Favorites, Community, Activities, and Referral into Profile, filters, or menus.
5. Simplify Lesson detail so Start is the only primary action.
6. Reduce repeated card styles and make secondary actions lighter.
7. Tighten copy and remove repeated section titles.
8. Revisit onboarding after the main app hierarchy is simpler.

## Success Criteria

The redesign is successful if a new user can answer these questions within five seconds:

- What should I do next?
- Where do I go to speak?
- Where do I review saved material?
- Where do I find my history/settings later?

The current UI answers these questions, but only after presenting too many parallel options. The next iteration should make the default path obvious and let advanced paths appear when the user needs them.

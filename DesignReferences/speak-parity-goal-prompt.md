# Converlax Phase 1 Speak-Parity Goal Prompt

## Objective

Implement Converlax iOS Phase 1 Speak-parity using the plan in `/Users/kego/Projects/converlax/DesignReferences/speak-flow-gap-plan.md` and the Speak iOS Mobbin reference flows.

Reference URL:
https://mobbin.com/apps/speak-ios-4d06786f-324a-4f57-8f7b-4bdff0f213b2/9ec2d4e8-446d-49d4-8d04-9ed5363e8d05/flows

Converlax must not copy Speak branding, copy, assets, or exact proprietary visual treatment. Preserve Converlax branding and original content while matching the requested Speak-like flow coverage, navigation structure, interaction depth, and learning-product UX expectations.

## Product Verdict To Act On

Converlax is not currently exactly the same as Speak. It has a compact learning prototype, while Speak has a broader mobile learning system with many connected flows across onboarding, home, course content, tutor chat, free talk, review, roleplays, community, profile, saved content, usage, activities, and settings.

The goal is not a pixel-perfect clone. The goal is Phase 1 functional and UX parity for the requested flows: every requested flow must have an implemented screen sequence, a visible navigation entry, primary controls, relevant local/mock state, empty/result states where applicable, and copy hierarchy comparable to the reference.

## Required Flow Coverage

Implement and verify these flows:

- Onboarding
- Home
- Course
- Chatting with Tutor
- Completing a vocab lesson
- Completing verb lesson
- Selecting a level
- Streak
- Free Talk
- Creating a roleplay lesson
- Topics
- Roleplay detail
- History & usage
- Favorites
- Community
- Profile
- Saved lines
- Activities
- Settings

## Implementation Scope

### 1. App Navigation And Information Architecture

Move the primary app structure toward Speak-like learning navigation:

- Home
- Free Talk
- Review
- Roleplays or Community
- Profile

Preserve useful existing Converlax code for Course, Tutor, Practice, Progress, and Profile by refactoring it into reusable surfaces. Add explicit route enums and `NavigationStack` destinations for all requested flows so every flow can be opened deterministically and verified in the simulator.

Add launch arguments for deterministic QA where useful:

- Initial tab selection
- Initial nested route selection
- Forced onboarding

### 2. Local Data And State

Add fixture-backed local models and state for:

- Saved lines
- Saved words or phrases where needed
- Activities
- Roleplay topics
- Roleplay scenarios
- Favorite roleplays/topics/lines
- Usage history
- Tutor/chat history
- Review items
- Membership placeholders
- Settings preferences

Keep backend, auth, billing, community publishing, and generated lesson services mocked/local for this phase unless an existing backend contract already exists.

### 3. Home, Course, Level, And Streak

Upgrade Home to include:

- Level chip
- Course/Practice segmented control
- Streak entry
- Current unit path
- Lesson cards
- Locked states
- Tutor entry
- Clear continuation path

Expand Course into separate routes and screens for:

- Course detail
- Lesson detail
- Lesson lines
- Video lesson placeholder
- Speaking drill placeholder
- Q&A lesson placeholder
- Custom lesson or roleplay lesson entry

Upgrade Selecting a level:

- Group levels into parts
- Show current level
- Show course-change/reset consequences
- Support onboarding and in-app level changes

Upgrade Streak:

- Full streak detail sheet or screen
- Daily goal/progress display
- Completion or celebration state where applicable

### 4. Lesson Players

Upgrade lesson experiences so vocab and verb completion feel like complete product flows.

Vocab lesson must include:

- Multi-step prompt or card sequence
- Audio placeholder/control
- Answer selection
- Check/feedback state
- Save-line action
- Completion/result screen

Verb lesson must include:

- Blank or conjugation prompt
- Choices or answer controls
- Correct/wrong state
- Save-line action
- Completion/result screen

The generic lesson player should support:

- Step count
- Current lesson line
- Audio placeholder/control
- Save action
- Progression
- Completion

Separate saved words from saved lines where the app needs different review/profile behavior.

### 5. Tutor Chat

Expand Tutor into a Speak-like chat surface:

- Chat history
- Tutor menu
- Text input mode
- Voice input mode
- Recording, cancel, submit, loading, and response states
- Audio toggle
- Saved messages
- Message-level save actions
- Word or phrase detail actions
- Personalized lesson suggestions

Avoid nested navigation stacks that conflict with parent route paths.

### 6. Free Talk, Topics, Roleplays, And Community

Add Free Talk:

- Root entry
- Session start
- Active session state
- Completion/end state
- Usage history hook

Add Topics:

- Topic browser
- Categories or filters
- Topic detail
- Related roleplays

Add Roleplays:

- Create roleplay form
- Generated roleplay state
- Roleplay detail
- Start session action
- Favorite/unfavorite
- Session usage recording

Add Community:

- Community roleplay list
- Sorting/filtering where practical
- Community roleplay detail
- Favorite actions

### 7. Review, Saved Lines, Favorites, History, And Activities

Add Review:

- Review home
- Smart review
- Saved-lines review
- Listening or mode switch where useful
- Review completion/result state
- Review information screen

Add Saved Lines:

- Dedicated saved-lines screen
- Search or filter
- Review route
- Save/remove hooks from lessons and tutor

Add Favorites:

- Dedicated favorites screen
- Favorite roleplays/topics/lines where available
- Empty state if no favorites exist

Add History & Usage:

- Session history
- Usage counters
- Recent activity from free talk and roleplay sessions

Add Activities:

- Activity feed
- Events generated from lessons, streaks, reviews, saved lines, roleplays, and favorites

### 8. Profile And Settings

Expand Profile into a hierarchy with:

- Learner header
- Current course/level
- Saved lines
- Activities
- Membership placeholder
- Referral/share placeholder
- Settings entry

Expand Settings with:

- Notification preferences
- App language placeholder
- Course language/change course
- Voice recognition setting
- Audio/sound/haptics where relevant
- Support placeholder
- Login/logout placeholder
- Password reset placeholder
- Reset progress
- Restart onboarding

Auth, membership, and billing must remain local/mock placeholders in Phase 1 unless explicit backend requirements are provided.

## Verification Requirements

Use the Build iOS Apps plugin and `xcodebuildmcp` for development verification.

Required verification:

- Run `build_sim` after implementation changes.
- Run representative `build_run_sim` flows using launch arguments for each primary tab and key nested route.
- Capture simulator screenshots for representative requested flows under `/Users/kego/Projects/converlax/DesignReferences/verification/screenshots/`.
- Maintain an audit document at `/Users/kego/Projects/converlax/DesignReferences/verification/phase-one-speak-parity-audit.md`.

Use Chrome/Mobbin reference checks when the Chrome capability is available. If the callable Chrome tool is unavailable in the session, use the Mobbin MCP search capability as the fallback and document that limitation in the audit. Save available reference evidence under `/Users/kego/Projects/converlax/DesignReferences/mobbin/`.

Do not mark the goal complete until the audit confirms:

- Every requested flow has a corresponding implementation artifact.
- Every requested flow has navigation access.
- Every requested flow has representative simulator verification or a documented reason why only code inspection was possible.
- Build succeeds after the latest changes.
- Mobbin/Speak reference evidence is captured or the verification limitation is explicitly documented.

## Recommended Execution Order

1. Home, Course, Selecting a level, and Streak.
2. Vocab lesson, Verb lesson, and Chatting with Tutor.
3. Saved lines, Review, Favorites, and History & usage.
4. Free Talk, Topics, Roleplay detail, Creating a roleplay lesson, and Community.
5. Profile, Activities, Settings, Login, and membership placeholders.

## Completion Criteria

The goal is complete only when Converlax has Phase 1 Speak-like coverage for all requested flows with working local state, deterministic simulator routes, build evidence, screenshot evidence, and a final prompt-to-artifact audit. The implementation should be production-shaped SwiftUI code, scoped to this phase, without unrelated refactors or backend commitments.

# Converlax Learning Feature Goal Prompt

## Objective

Upgrade Converlax from a Speak-inspired Phase 1 flow prototype into a usable language-learning app with real learning depth.

Use the Speak iOS Mobbin flow reference checked in Chrome on 2026-05-14:

https://mobbin.com/apps/speak-ios-4d06786f-324a-4f57-8f7b-4bdff0f213b2/9ec2d4e8-446d-49d4-8d04-9ed5363e8d05/flows

Do not copy Speak branding, proprietary copy, exact visual treatment, characters, or assets. Preserve Converlax identity while matching the product expectations exposed by Speak's learning flows.

## Current Read

Converlax already covers many Phase 1 surfaces: Home, Course, Tutor, Practice, Review, Free Talk, Roleplays, Profile, Settings, saved lines, activities, and local/mock state.

What is still missing is not mostly more screens. The main missing layer is learning behavior and real learning content: lessons should teach, listen, score, adapt, save, review, and resume like a real language-learning product, using authored language-learning material that a learner can actually practice.

## Missing Learning Capabilities To Add

### 0. Asset Cutout Cleanup

Remove the embedded box background from Converlax visual assets wherever practical so illustrations render as clean transparent cutouts on cards, rows, and badges.

Use the existing no-box-background assets as the quality target. For each asset in `Converlax/Assets.xcassets`:

- Inspect whether the PNG includes a visible square/cream/white box behind the illustration.
- Preserve the actual character/object artwork.
- Remove only the unwanted flat box/background area when it can be done without damaging the illustration.
- Keep assets that already render cleanly unchanged.
- Verify affected assets in common UI placements such as Home cards, Settings rows, Profile rows, Practice cards, Roleplay rows, and Review cards.

Do not redesign the asset style in this pass. The goal is transparent/background-free presentation, not new artwork.

### 1. Real Lesson Lifecycle

Implement lessons as structured sessions instead of mostly static route flows.

Each lesson should support:

- Intro or goal screen
- Step-by-step prompt progression
- Listening/audio prompt
- Learner response
- Check/feedback state
- Retry or continue decision
- Save-line or save-word action
- Completion summary
- Next recommended action

Apply this lifecycle to:

- Video-style lesson placeholder
- Speaking drill
- Q&A lesson
- Vocab lesson
- Verb lesson
- Custom lesson
- Roleplay lesson

### 1.1 Real Curriculum Content

Add useful, authored lesson content that can be learned from immediately. Do not leave the learning experience as empty placeholders or generic mock copy.

Prioritize English content first so the app can be tried as an English-learning product.

English curriculum should include:

- Beginner introductions and self-introduction
- Small talk and follow-up questions
- Cafe ordering and polite requests
- Asking for directions
- Hotel or travel check-in
- Work introductions and job talk
- Daily routines
- Shopping and prices
- Making plans
- Health or help requests
- Review lessons that combine previous material into realistic mini conversations

Each lesson should include real:

- Teaching explanation
- Target phrase
- Translation or plain-English meaning
- Multiple-choice check
- Speaking prompt
- Saved words/phrases
- Example sentence
- Natural correction or better phrasing

Prefer concise, practical phrases over filler text. Content should be appropriate for beginner learners and useful in real conversations.

French content can remain as existing starter content for now, but English should be expanded enough to validate the product experience.

### 2. Speech And Audio Practice

Add a production-shaped local abstraction for speech/audio even if the first implementation uses mock results.

Required states:

- Mic permission needed
- Ready to record
- Recording
- Paused or cancelable recording
- Processing
- Recognized transcript
- Pronunciation or fluency feedback
- Retry
- Accepted answer
- Error state

Required learner controls:

- Start/stop recording
- Replay prompt audio
- Slow audio speed
- Toggle transcript/translation
- Switch between speak mode and text mode

### 3. Feedback And Scoring

Move beyond binary correct/wrong feedback.

Add feedback models for:

- Pronunciation
- Grammar
- Vocabulary usage
- Fluency
- Meaning accuracy
- Confidence score
- Suggested correction
- Better native-style phrasing

Show feedback inline after speaking drills, Q&A lessons, Free Talk, roleplays, vocab, and verb practice.

### 4. Adaptive Review System

Upgrade Review into a real spaced-practice system.

Implement local scheduling for:

- Saved lines
- Saved words
- Mistakes
- Weak grammar patterns
- Recent lesson items
- Roleplay phrases

Each review item should track:

- Last reviewed date
- Next due date
- Ease or confidence score
- Mistake count
- Source lesson/session
- Listening-first mode availability
- Speaking retry availability

Smart Review should mix due items, weak items, and recent mistakes.

### 5. Saved Learning Objects

Separate saved content into distinct learning objects.

Implement:

- Saved lines
- Saved words
- Saved phrases
- Saved tutor messages
- Saved mistakes
- Saved roleplay phrases

Each saved object should support:

- Source context
- Translation
- Audio/replay placeholder
- Review action
- Remove action
- Search/filter
- Detail screen

### 6. Tutor As Learning Coach

Tutor should become a learning coach, not only a chat surface.

Add:

- Tutor-generated correction cards
- Follow-up drills from mistakes
- Personalized lesson suggestions
- Saved-message actions
- Word/phrase detail from chat
- Voice input result flow
- Chat history grouped by session
- Continue previous conversation

Keep AI/network calls behind interfaces or mock services for this phase.

### 7. Roleplay And Free Talk Learning Loop

Free Talk and roleplay sessions should generate learning artifacts.

After each session, create:

- Transcript
- Corrections
- Strong phrases
- Weak phrases
- Suggested review items
- Suggested next roleplay
- Usage history event
- Activity event

Roleplay detail should show:

- Scenario goal
- Learner role
- AI role
- Target phrases
- Difficulty
- Estimated time
- Start/resume action
- Previous attempt summary if available

### 8. Progress And Curriculum Intelligence

Add learner progress that reflects actual skill growth.

Track:

- Completed lessons
- Skill progress by topic
- Speaking confidence
- Listening confidence
- Vocabulary growth
- Grammar weak points
- Review due count
- Streak and daily goal
- Recent mistakes resolved

Home should use this data to recommend the next best action.

### 9. Persistence And Testability

Keep the implementation local-first, deterministic, and testable.

Add or preserve:

- Fixture-backed learning data
- Mock speech scoring service
- Mock audio service
- Mock tutor recommendation service
- Launch arguments for key flows
- Stable accessibility identifiers
- SwiftUI previews where useful

Do not introduce backend, billing, real community publishing, or real AI service dependencies unless explicitly requested.

## Verification Requirements

Use the Build iOS Apps plugin and XcodeBuildMCP.

Required checks:

- Build succeeds after changes.
- Simulator can launch directly into representative lesson flows.
- Screenshots are captured for:
  - Speaking drill recording state
  - Speaking drill feedback state
  - Vocab completion
  - Verb completion
  - Smart Review due item
  - Saved line detail
  - Tutor correction card
  - Free Talk completion summary
  - Roleplay completion summary
  - Representative asset rows/cards after box-background cleanup
- Audit document notes which services are mocked and which are real.

## Recommended Execution Order

1. Clean removable box backgrounds from asset PNGs and verify representative UI placements.
2. Expand English curriculum content with real beginner lessons, saved phrases, review material, and roleplay phrases.
3. Introduce learning-session, review-item, saved-object, feedback, and speech-state models.
4. Upgrade vocab and verb lessons to use the session lifecycle.
5. Upgrade speaking drill and Q&A with speech/text mode, feedback, and save actions.
6. Upgrade Smart Review with due scheduling and saved-object review.
7. Upgrade Tutor with correction cards and personalized lesson suggestions.
8. Upgrade Free Talk and roleplay completion summaries to generate review items and activities.
9. Connect Home progress/recommendations to the new learning state.
10. Verify with simulator routes, screenshots, and an audit.

## Completion Criteria

The goal is complete only when Converlax has a coherent local-first learning loop:

lesson or conversation -> learner response -> feedback -> saved learning object -> scheduled review -> progress update -> next recommendation.

The implementation should include real authored English learning content, remain SwiftUI-native, deterministic in the simulator, visually consistent with Converlax, and scoped to learning behavior rather than unrelated profile, billing, or community expansion.

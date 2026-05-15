# Speak Flow Gap Plan

Checked with Chrome against:
https://mobbin.com/apps/speak-ios-4d06786f-324a-4f57-8f7b-4bdff0f213b2/9ec2d4e8-446d-49d4-8d04-9ed5363e8d05/flows

Date: 2026-05-14

## Verdict

Converlax is **not exactly the same** as Speak.

The current app has a compact SwiftUI learning prototype:

- Tabs: Home, Tutor, Practice, Progress, Profile.
- Onboarding: language selection and level selection.
- Home/Course: one course unit, current lesson card, lesson rows, locked unit preview.
- Tutor: basic chat, suggestions, text input, simple voice-input panel.
- Practice: vocab and verb mini-lessons.
- Progress/Profile: streak card, daily goal, saved words, basic settings.

Speak's Mobbin reference is much broader. The live Mobbin page shows 95 flows, with major sections for Onboarding, Home, Free Talk, Review, Challenge, Profile, Login, and Widgets. The requested flows are either missing, simplified, or only loosely represented in Converlax.

## Current Coverage By Requested Flow

| Requested Speak flow | Converlax status | What exists now | Main gap to Speak parity |
| --- | --- | --- | --- |
| Onboarding | Partial | 2-step language and level setup in `OnboardingView`. | Speak has a long branded onboarding with switching-to-text and subscription branches. |
| Home | Partial | Home tab is `CourseHomeView` with level chip, Course/Practice segmented control, streak chip, unit intro, lesson card, path rows, tutor prompt. | Needs Speak-like screen sequence, richer lesson states, bottom-tab structure, tutor entry behavior, and unit/path density. |
| Course | Partial | Course path and generic `LessonPlayerView`. | Missing video lesson, speaking drill, Q&A lesson, custom lesson, lesson detail, lesson lines, captions, saved lines, report controls, playback/speak controls. |
| Chatting with Tutor | Partial | `TutorView` has text chat, suggestion chips, simple voice panel, translation card. | Missing voice-state sequence, tutor menu, audio toggle, saved messages, saved words/phrases, personalized lessons, chat history, dictionary detail, message actions. |
| Completing a vocab lesson | Partial | `VocabLessonView` with choice answer, settings sheet, completion state. | Missing Speak-style multi-step flow, audio, save/review actions, answer feedback, pronunciation/listening options, richer completion result. |
| Completing verb lesson | Partial | `VerbLessonView` with blank prompt, choices, check result. | Missing full lesson progression, explicit wrong/correct states, result cards, saved-line actions, audio states, completion celebration. |
| Selecting a level | Partial | Level picker exists in onboarding and a Home sheet. | Missing Speak's grouped levels/parts, progress per level, course-reset/change consequences, and full route from Home. |
| Streak | Partial | Progress tab has a streak card; Home has a streak chip. | Missing streak modal, streak goal configuration, warnings, and post-lesson streak celebration. |
| Free Talk | Missing | No Free Talk tab or flow. | Add free-form speaking session entry, session states, history/usage hooks. |
| Creating a roleplay lesson | Missing | No roleplay creation UI or data model. | Add topic/prompt form, generated roleplay state, lesson-start route. |
| Topics | Missing | No topics browser. | Add topic categories, topic detail, roleplay list, filtering/sorting. |
| Roleplay detail | Missing | No roleplay detail screen. | Add detail, favorite, start, usage/history, and community variants. |
| History & usage | Missing | No session history or usage analytics. | Add history list, usage counters, and detail drilldowns. |
| Favorites | Missing/partial | Saved words exist in Profile. | Add first-class favorites for roleplays/topics/lines, not just saved vocabulary. |
| Community | Missing | No community surface. | Add community roleplay topics, detail, sorting, and favorite actions. |
| Profile | Partial | `ProfileView` has learner header, course row, saved words, learning settings. | Missing Speak-style profile hierarchy: membership, referral, activities, saved lines, edit profile, support, settings branches. |
| Saved lines | Missing/partial | Saved words/phrases list exists. | Add dedicated saved lines screen, search, review flow, line detail, and saved-line actions from lessons/chat. |
| Activities | Missing | No activity feed. | Add activity list and source events from lessons, roleplays, reviews, streaks. |
| Settings | Partial | Course picker, daily goal, sound, haptics, reset progress, restart onboarding. | Missing membership, edit profile, notifications, support center, app language, course change flow, voice recognition, logout/login/reset password. |

## Goal Plan

### 1. Lock The Speak-Compatible App Map

- Change primary tabs toward Speak's information architecture: Home, Free Talk, Review, Roleplays or Community, Profile.
- Keep current Course, Tutor, Practice, Progress, and Profile code as reusable pieces while adding route enums for all Speak-like flows.
- Add placeholder data models for saved lines, activities, roleplays, topics, favorites, usage history, membership, and settings.

### 2. Match Home, Course, Level, And Streak First

- Rebuild Home around Speak's visible structure: level chip, Course/Practice segment, streak entry, current unit path, lesson cards, locked states, and tutor entry.
- Expand Course into separate lesson routes: video lesson, speaking drill, Q&A lesson, custom lesson, lesson lines, and lesson detail.
- Turn the current streak chip/card into a full streak flow with modal, daily goal, warnings, and post-lesson celebration.
- Extend level selection with grouped level parts, current progress, and course-change/reset confirmation.

### 3. Upgrade Lesson Players

- Convert `LessonPlayerView`, `VocabLessonView`, and `VerbLessonView` into a shared lesson-player shell with step count, audio control, save action, answer state, and completion state.
- Add Speak-like vocab and verb lesson sequences: prompt, answer, feedback, optional listening/pronunciation controls, saved-line affordance, and result screen.
- Split saved words from saved lines in persistence so Review and Profile can treat them separately.

### 4. Bring Tutor Closer To Speak

- Add tutor chat history, menu, text/voice switching, audio toggle, saved messages, saved words/phrases, dictionary word detail, and message-level save actions.
- Model voice states explicitly: idle, recording, cancel, submit, loading, response, and back-to-keyboard.
- Add personalized lesson suggestions and generated suggestion chips based on saved content/history.

### 5. Add Free Talk, Topics, Roleplays, And Community

- Add a Free Talk tab/entry with session start, active session, and end state.
- Add topics browser, topic detail, roleplay creation, generated roleplay detail, and roleplay session start.
- Add community roleplay list, community roleplay detail, sorting, and favorite/unfavorite.
- Store usage events from Free Talk and roleplay sessions for History & Usage.

### 6. Build Review, Saved Lines, Favorites, History, And Activities

- Add Review home, smart review completion, listening-mode switch, saved-lines review, saved-line search, and review information.
- Add dedicated Saved Lines and Favorites areas.
- Add History & Usage with session history and counters.
- Add Activities feed generated from lesson completions, streaks, reviews, roleplays, and favorites.

### 7. Expand Profile And Settings

- Split Profile and Settings into separate navigation surfaces.
- Add membership management, edit profile, referral link copy, notification preferences, support center, app language, language course change, voice recognition, logout, login, and password reset.
- Keep auth/membership as mock/local services until backend requirements are defined.

### 8. Verification Standard

For each flow, capture side-by-side evidence before marking it done:

- Mobbin reference screens saved under `DesignReferences/mobbin/<flow>/`.
- Simulator screenshots for the matching Converlax flow.
- A checklist for screen sequence, navigation entry, primary controls, empty/loading/result states, and copy hierarchy.

## Recommended Implementation Order

1. Home, Course, Selecting a level, Streak.
2. Vocab lesson, Verb lesson, Chatting with Tutor.
3. Saved lines, Review, Favorites, History & usage.
4. Free Talk, Topics, Roleplay detail, Creating a roleplay lesson, Community.
5. Profile, Activities, Settings, Login and membership branches.

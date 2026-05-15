# Learning State, Review, And Recommendations Verification

Date: May 15, 2026  
Simulator: iPhone 17, iOS 26.2  
Bundle: `com.kego.converlax`

## Build

- Passed: `xcodebuild -project Converlax.xcodeproj -scheme Converlax -configuration Debug -destination 'generic/platform=iOS Simulator' build`
- Passed after the final review-queue patch: XcodeBuildMCP `build_run_sim`

## Simulator Checks

- Completed the first lesson, "Introduce yourself".
  - Home moved from `0/10` to `1/10`.
  - Current lesson advanced to `english-small-talk`.
  - Lesson completion created saved words, persisted learning objects, review items, a session summary, a usage session, feedback, and recent activity.
  - Evidence: `screenshots/parallel-learning-state/12-current-lesson-complete.jpg`, `13-current-home-after-lesson.jpg`.
- Saved a lesson line.
  - The line became saved in the lesson UI and contributed a persisted learning object/review item.
  - Saved content showed saved lines and profile counts.
  - Evidence: `05-lesson-saved-line-feedback.jpg`, `18-saved-content-lines.jpg`.
- Verified speaking/session artifacts already present in the live profile from the simulator pass.
  - Practice history shows Free Talk and Meet someone new sessions.
  - Recent activity includes speaking session review artifacts.
  - Evidence: `08-free-talk-session-saved.jpg`, `19-recent-activity-review-lesson-save.jpg`, `20-practice-history-sessions.jpg`.
- Ran Smart Review grading paths.
  - `Remembered` moved `Retry: I study English in night.` out to `2026-05-17` with increased ease.
  - `Need practice` rescheduled `Retry: I'm from Indonesia. How about you?` to `2026-05-16`, increased its mistake count, and left it as a weak item.
  - The next due card advanced without skipping.
  - Evidence: `14-current-review-answer-actions.jpg`, `15-current-review-after-remembered-and-needs-practice.jpg`.
- Verified home recommendation changes with state.
  - After lesson completion and review grading, Home showed `1/10`, the next lesson, and `Review 14 due items`.
  - Evidence: `16-relaunch-home-persisted-state.jpg`.
- Verified Profile, Recent Activity, Practice History, and Saved Content.
  - Profile showed `1/10 lessons`, saved count, and session count.
  - Recent Activity listed review grading, lesson completion, saved lines, and speaking sessions.
  - Practice History listed Smart Review, completed lesson, roleplay/free-talk sessions, and seeded history.
  - Evidence: `17-profile-progress-history-saved.jpg`, `18-saved-content-lines.jpg`, `19-recent-activity-review-lesson-save.jpg`, `20-practice-history-sessions.jpg`.
- Verified relaunch persistence.
  - Relaunched with no arguments after completing/grading.
  - App returned directly to Home with persisted onboarding, lesson progress, due review count, and streak.
  - Profile JSON exists at `Library/Application Support/Converlax/learning-profile-v3.json`.

Persisted profile spot check after review grading:

```text
completedLessonIDs: ["english-introductions"]
currentLessonID: english-small-talk
savedWords: 3
savedLines: 2
savedLearningObjects: 16
scheduledReviews: 16
feedbackEvents: 7
sessionSummaries: 3
usageSessions: 4 persisted, 7 visible with seeded history
activities: 7 persisted, 10 visible with seeded history
```

## Implementation Notes

- Lesson completion now writes course progress, saved words, reviewable lesson phrases, feedback, summary, usage history, skill progress, and activity with deterministic IDs.
- Speaking, roleplay, tutor correction, and lesson practice paths now create feedback and reviewable saved learning objects where useful.
- Saving a word or line now guarantees a learning object and review item even if the saved content already existed.
- Smart Review updates review schedule, ease, retry flags, usage, skills, and activity for both remembered and needs-practice actions.
- Next recommendations are deterministic and explainable: first lesson, due personal review, continue/start next lesson, weakest active skill, then saved lines.
- Review now prioritizes persisted learner-created review items and stops mixing standalone demo review prompts into the active queue after the learner has real history.
- Duplicate clutter is limited by deterministic IDs and upserts for daily lesson, review, and session artifacts.

## Enjoyment Judgment

The app now feels more attentive and personal. Completing a lesson, saving a line, speaking, and grading review all leave visible traces in Home, Review, Profile, Practice History, and Recent Activity. The recommendation text explains why it appears, so it feels guided by the learner's actions rather than random.

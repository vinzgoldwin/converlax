# End-to-End Usability QA

Date: 2026-05-16
Simulator: iPhone 17, iOS 26.2

## Verified

- First launch onboarding opens with one clear next action.
- English course can be selected and Home opens to the next speaking lesson.
- Home, Practice, Review, and Profile root screens keep one dominant action and avoid seeded stats.
- Microphone or Speech Recognition denial is recoverable with text input.
- Backend offline state falls back to local speaking feedback and shows a short notice.
- Empty Review state routes the learner to speaking instead of showing demo review items.
- Profile shows level, title, one progress bar, recent journey, and compact navigation rows.
- Custom practice now creates a playable roleplay instead of stopping at a generated-looking row.

## Screenshots

- `Documentation/Screenshots/qa/onboarding-first-launch.jpg`
- `Documentation/Screenshots/qa/home-next-lesson.jpg`
- `Documentation/Screenshots/qa/practice-root.jpg`
- `Documentation/Screenshots/qa/review-empty.jpg`
- `Documentation/Screenshots/qa/profile-journey-empty.jpg`

## Remaining Risks

- Full real microphone recognition still needs physical-device or simulator audio validation with permissions allowed.
- AI feedback quality depends on a configured backend key and should be checked with live OpenRouter responses before release.
- Long feedback cards can push the next action below the fold on small screens; it remains scrollable but should be watched in future UI passes.
- Lesson completion was spot-checked through the voice/text feedback path, but a full manual pass through every lesson turn should be repeated with live microphone input.

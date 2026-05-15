# Parallel Course Content Verification

Date: 2026-05-15

## Scope

Updated the English beginner path into a practical conversation arc:

1. Introduce yourself.
2. Greet and make small talk.
3. Order at a cafe.
4. Ask for directions.
5. Ask for help or clarification.
6. Make plans.
7. Talk about daily routine.
8. Handle shopping and prices.
9. Introduce yourself at work.
10. Review a combined starter conversation.

The course content now feeds lesson goals, prompts, answer options, saved words/phrases, roleplay topics, roleplay lines, saved lines, and review items.

## Build

Passed with XcodeBuildMCP on iPhone 17 simulator:

- Project: `/Users/kego/Projects/converlax/Converlax.xcodeproj`
- Scheme: `Converlax`
- Bundle ID: `com.kego.converlax`
- Latest build/run check: succeeded with no diagnostics warnings or errors.

## Simulator Checks

Screenshots were captured in:

`DesignReferences/verification/screenshots/parallel-course-content/`

Captured states:

- `course-path-top.jpg`: course path with the revised beginner arc.
- `early-lesson-introduction.jpg`: first lesson opened.
- `early-lesson-complete.jpg`: early introduction lesson completed.
- `middle-lesson-help-detail.jpg`: middle clarification/help lesson opened.
- `later-lesson-work-start.jpg`: later workplace introduction lesson opened.
- `later-lesson-work-complete.jpg`: later workplace lesson completed.
- `saved-lines-review.jpg`: saved lines list showing course-aligned phrases.
- `smart-review-content.jpg`: smart review item and answer from the revised content seed.

## Content Judgment

I read the revised lesson lines aloud. The phrases sound natural and beginner-appropriate:

- "Hi, I'm Maya. Nice to meet you."
- "Pretty good, thanks. How about you?"
- "Could I have a small coffee, please?"
- "Excuse me, where is the nearest station?"
- "Could you say that again, please?"
- "Let's meet at six near the station."
- "I usually study English after work."
- "How much is this? Can I pay by card?"
- "Hi, I'm Maya. I work in product."
- "Nice to meet you. I look forward to working with you."

The arc now progresses from first-meeting basics into small errands, clarification, planning, routine, shopping, work, and a combined review. Later lessons reuse earlier language, especially "nice to meet you", "how about you", "station", "let's meet", and workplace introduction phrasing.

Saved lines and review items are meaningful enough to practice outside the lesson flow. I reset only the simulator app install before the final smart-review check so persisted old development data did not mask the current content seed.

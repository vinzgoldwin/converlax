# Agent Notes

Converlax is a speaking-practice iOS app with a small AI feedback backend. Keep the product calm, direct, and easy to use. Simplicity is the first requirement.

## Product Shape

- One root screen, one job:
  - Home: continue the next lesson.
  - Practice: start speaking.
  - Review: review what is due.
  - Profile: appreciate the learner's journey.
- Prefer one dominant action per screen. Secondary actions should be quiet rows or small tool buttons.
- Do not turn root screens into feature menus. Put advanced or uncommon paths behind intentional detail screens, or omit them.
- Do not show two actions that do nearly the same thing on the same screen.
- Empty states should route learners to the next useful action.

## UI Rules

- Use cards sparingly. One primary card per screen is usually enough.
- Do not nest cards inside cards or give every row a heavy card treatment. Use plain rows, dividers, or compact grouped rows.
- Keep copy natural and short. Avoid literal UX-framework headings such as "What should I do now?"
- Avoid duplicate verbs, counts, headings, subtitles, and explanations. If the primary card explains the action, the surrounding header usually should not.
- Do not add low-value stats or controls just because data exists. Progress, counts, XP, and metadata should help the learner decide what to do next.
- Never use sparkle icons.
- Use existing Converlax illustration assets before generic SF Symbol-only cards; see `Documentation/ConverlaxVisualIdentity.md` for mascot, palette, and asset names. New app illustration assets should be transparent PNGs, not opaque square backplates.

## Journey And Motion

- Profile should feel emotional, not analytical.
- Keep the main Profile screen limited to current level/title, one compact progress bar, recent journey items, and rows for saved content, practice history, and settings.
- Do not show XP source breakdowns, full title catalogs, or full milestone lists on the main Profile screen.
- Completion moments should be brief: acknowledge progress, show a small reward, then offer the next action.
- Use animation only to clarify local state changes: gentle lift/fade, compact progress movement, listening feedback, and row removal transitions are appropriate.
- Avoid confetti, screen-wide particles, excessive bouncing, and distracting loops.

## SwiftUI Implementation

- Follow the existing patterns in `Converlax/*.swift`; prefer shared UI in `ThemeAndComponents.swift` before adding new components.
- Keep views small and local. Add a view model only when local `@State`/`@ObservedObject` patterns are no longer enough.
- Remove dead state, handlers, computed properties, routes, and reset code when removing a UI path.
- Tutor practice is voice-first. Do not reintroduce text-input tutor flows or alternate primary lesson modes on root paths.
- Preserve existing accessibility identifiers used by `ConverlaxUITests`, or update the tests in the same change.

## Backend

- Backend code lives in `backend/` and uses Node 20+, Fastify, Wrangler, and `node --test`.
- Keep OpenRouter secrets on the server side. Do not commit `.env` values or add API keys to the iOS app.
- Keep logs at metadata level; do not log transcript contents.
- Maintain the structured response contracts used by `AIFeedbackService.swift`, `TutorAIService.swift`, and `backend/src/schema.js`.

## Verification

- After UI changes, build the app and visually check the affected root screen in the simulator.
- Run focused XCTest/UI tests when changing Swift flows covered by `ConverlaxTests` or `ConverlaxUITests`.
- Run `cd backend && npm test` after backend schema, endpoint, or Worker changes.

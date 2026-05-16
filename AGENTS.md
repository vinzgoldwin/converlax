# Agent Notes

Converlax is a speaking-practice iOS app. Keep the product calm, direct, and easy to use. Simplicity is the first requirement.

## Product Principles

- One screen, one job:
  - Home: continue the next lesson.
  - Practice: start speaking.
  - Review: review what is due.
  - Profile: appreciate the learner's journey.
- Prefer one dominant action per screen. Secondary actions should be light rows or small tool buttons.
- Do not turn screens into feature menus. Hide advanced or less common actions behind detail screens.
- Keep journey/game mechanics quiet and motivating. Show current level/title, one progress bar, one next step, and recent accomplishments. Avoid analytics-style breakdowns on root screens.

## UI Rules

- Use cards sparingly. One primary card per screen is usually enough.
- Do not nest cards inside cards.
- Do not give every row a heavy card treatment. Use plain rows, dividers, or compact grouped rows.
- Avoid repeated counts and duplicate explanations. If the card says the count, the header does not need it.
- Avoid literal UX-framework headings such as "What should I do now?" Use natural app copy like "Continue from here", "Start speaking", "Due today", and "Your journey".
- Keep subtitles short or remove them when the primary card already explains the action.
- Make empty states useful: route users to the next productive action, not a dead screen.

## Journey UX

- Profile should feel emotional, not analytical.
- Keep visible journey content limited to:
  - Current level and title.
  - A compact progress bar.
  - Recent journey items.
  - Saved content, practice history, and settings rows.
- Do not show XP source breakdowns, full title catalogs, or full milestone lists on the main Profile screen.
- Completion moments should be brief: acknowledge progress, show a small reward, then offer the next action.

## SwiftUI Implementation

- Follow existing SwiftUI patterns in `Converlax/*.swift`.
- Keep views small and local; avoid introducing new view models unless there is a clear need.
- Use existing shared components before creating new ones.
- After UI changes, build the app and visually check the affected root screen in the simulator.

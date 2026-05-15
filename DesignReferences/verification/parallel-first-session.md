# Parallel First Session Verification

Date: 2026-05-15

## Build

- Passed: XcodeBuildMCP `build_run_sim`, scheme `Converlax`, Debug, iPhone 17 simulator.
- Latest successful build log: `/Users/kego/Library/Developer/XcodeBuildMCP/workspaces/converlax-bb2032375660/logs/build_run_sim_2026-05-15T09-03-00-383Z_pid96581_49cbd54e.log`

## Screenshots

Saved under `DesignReferences/verification/screenshots/parallel-first-session/`:

- `01-onboarding-intro.jpg`
- `02-onboarding-language.jpg`
- `02b-onboarding-language-selected.jpg`
- `03-onboarding-level.jpg`
- `03b-onboarding-level-selected.jpg`
- `04-home-first-session.jpg`
- `05-relaunch-no-onboarding.jpg`
- `06-first-lesson-start.jpg`

## Checks

- Forced onboarding shows the simplified three-step setup: first speaking promise, course language, starting level.
- Language and level rows update selection state; French and Elementary selected states were captured.
- Onboarding completion can land on the simplified first-session Home state with one obvious lesson card.
- First-session Home suppresses secondary Home actions until learning has started.
- The first lesson starts directly from the primary Home lesson card.
- Relaunch after a completed profile did not show onboarding.

## Enjoyment Judgment

Onboarding now feels lightweight enough to make me want to try the first lesson. The strongest part is that the first screen promises a concrete 4-minute speaking win instead of explaining product modes. The post-onboarding Home screen also makes the next action obvious within a few seconds.

## Notes

- Simulator coordinate taps near the bottom of the device were unreliable, so verification used XcodeBuildMCP screenshots plus Computer Use element-targeted stepping where possible.
- An advance lock was added to the onboarding primary button to prevent rapid repeated activation while the button position stays fixed across steps.

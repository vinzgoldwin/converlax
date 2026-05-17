# Converlax Visual Identity

## Mascot

Converlax uses a rounded teal clay companion named Melo. Melo has a cream face and belly, a small sprout on top, soft mitten arms, mint feet, and a plain belly with no icon marks. The character should feel warm, encouraging, and voice-practice native without copying Speak's ghost mascot or the original reference character.

Use Melo for onboarding, tutor/chat moments, speaking/listening states, success, completion, profile, streak encouragement, and empty states. Keep the mascot large enough to read as tactile 3D clay; avoid placing text or badges over the cream belly.

## Palette

- Deep teal: primary actions, progress, active states.
- Teal and mint: learning surfaces, completion, listening and speaking energy.
- Cream and ivory: app background, cards, mascot face and belly.
- Papaya and coral: streak, highlights, alerts, small celebrations.
- Violet: secondary variety for review, history, and advanced practice.
- Ink: main text.

The app should avoid bright royal-blue dominance. Blue may appear only as a legacy compatibility accent where replacement would reduce clarity.

## Typography

Use rounded San Francisco styling through `.fontDesign(.rounded)` at the app root. Pair bold rounded headings with compact body copy. Keep cards calm and readable so the clay assets carry the playful tone.

## Asset Categories

Production assets live in `Converlax/Assets.xcassets` as transparent PNG image sets so they can sit directly on cream app surfaces, cards, gradients, and sheets without a square backdrop:

- `ClxMascot*`: mascot states used by `ConverlaxMascotView`.
- `ClxAssetAskInfo`, `ClxAssetBookAccommodation`, `ClxAssetAskDirections`: task and roleplay categories.
- `ClxAssetVocab`, `ClxAssetVerbs`, `ClxAssetReview`, `ClxAssetSavedLines`: learning and review assets.
- `ClxAssetFreeTalk`, `ClxAssetCustomLesson`, `ClxAssetRoleplay`: practice entry points.
- `ClxAssetHistoryUsage`, `ClxAssetSettings`, `ClxAssetStreak`: profile and system surfaces.

## Motion

`ConverlaxMascotView` maps product moments to reusable animation states:

- `idle`: slow float.
- `waving`: onboarding greeting.
- `encouraging`: calm float for tutor prompts.
- `thinking`: subtle tilt.
- `celebrating`: spring bounce.
- `avatar`: static profile identity.

Use `ConverlaxAssetBadge` for illustrated category cards and rows. Do not fall back to generic SF Symbol-only cards when a matching Converlax asset exists.

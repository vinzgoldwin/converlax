# Melo sprite animations

This folder is generated output for frame-by-frame transparent PNG animations.

Run:

python3 -m pip install Pillow
python3 Scripts/generate_melo_sprite_frames.py

Default output is Converlax/Assets/MeloSprites.

Animations:

- idle_breathe: 12 frames, 12 FPS, loops. Subtle breathing and bobbing.
- encouraging_nod: 14 frames, 14 FPS, plays once. Gentle nod with small lift.
- celebrate_pop: 16 frames, 16 FPS, plays once. Brief happy completion pop.
- saved_ack: 12 frames, 16 FPS, plays once. Quick saved-line acknowledgement.
- review_cleared: 14 frames, 14 FPS, plays once. Calm all-clear reaction.
- thinking_loop: 16 frames, 10 FPS, loops. Slow thoughtful tilt and bob.
- wave: 16 frames, 16 FPS, loops. Compact wave using the approved waving pose.

Output shape:

- Transparent PNG frames only.
- Square canvas, 256 px by default.
- Numbered frames use 000.png, 001.png, and so on.
- Mascot is centered with a stable visual baseline.
- No background, backplate, particles, confetti, sparkle effects, or exaggerated bounce.

Use --canvas 512 when a larger export is needed.

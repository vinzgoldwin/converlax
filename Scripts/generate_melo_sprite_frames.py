#!/usr/bin/env python3
"""Generate transparent frame-by-frame Melo mascot sprite animations.

This intentionally derives every frame from the existing Converlax mascot PNGs in
Assets.xcassets. Do not redraw Melo here; transform the approved source poses so
proportions, colors, face, outline, and app style remain consistent.

Usage:
    python3 Scripts/generate_melo_sprite_frames.py
    python3 Scripts/generate_melo_sprite_frames.py --canvas 256 --output Converlax/Assets/MeloSprites

Requires Pillow:
    python3 -m pip install Pillow
"""

from __future__ import annotations

import argparse
import json
import math
from dataclasses import dataclass
from pathlib import Path
from typing import Callable

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
ASSET_ROOT = ROOT / "Converlax" / "Assets.xcassets"
DEFAULT_OUTPUT = ROOT / "Converlax" / "Assets" / "MeloSprites"


@dataclass(frozen=True)
class FrameSpec:
    scale: float = 1.0
    rotate: float = 0.0
    x: float = 0.0
    y: float = 0.0


@dataclass(frozen=True)
class AnimationSpec:
    name: str
    source_asset: str
    frame_count: int
    fps: int
    loops: bool
    note: str
    curve: Callable[[int, int], FrameSpec]


def ease_in_out_sine(t: float) -> float:
    return -(math.cos(math.pi * t) - 1) / 2


def sine_loop(i: int, count: int, phase: float = 0.0) -> float:
    return math.sin((math.tau * i / count) + phase)


def idle_breathe(i: int, count: int) -> FrameSpec:
    s = sine_loop(i, count)
    return FrameSpec(scale=1.0 + 0.012 * s, y=-2.0 * s)


def encouraging_nod(i: int, count: int) -> FrameSpec:
    t = i / (count - 1)
    # Down, lift, then settle. Compact enough to read at small UI sizes.
    y = -4.0 * math.sin(math.pi * t)
    rotate = 2.2 * math.sin(math.tau * t) - 1.2 * math.sin(2 * math.tau * t)
    scale = 1.0 + 0.014 * math.sin(math.pi * t)
    return FrameSpec(scale=scale, rotate=rotate, y=y)


def celebrate_pop(i: int, count: int) -> FrameSpec:
    t = i / (count - 1)
    if t < 0.38:
        p = ease_in_out_sine(t / 0.38)
        scale = 1.0 + 0.07 * p
        y = -8.0 * p
    else:
        p = ease_in_out_sine((t - 0.38) / 0.62)
        scale = 1.07 - 0.07 * p
        y = -8.0 + 8.0 * p
    rotate = 1.8 * math.sin(math.tau * t)
    return FrameSpec(scale=scale, rotate=rotate, y=y)


def saved_ack(i: int, count: int) -> FrameSpec:
    t = i / (count - 1)
    pop = math.sin(math.pi * t)
    return FrameSpec(scale=1.0 + 0.035 * pop, rotate=2.0 * pop, y=-5.0 * pop)


def review_cleared(i: int, count: int) -> FrameSpec:
    t = i / (count - 1)
    lift = math.sin(math.pi * t)
    return FrameSpec(scale=1.0 + 0.025 * lift, rotate=-1.2 * math.sin(math.tau * t), y=-4.0 * lift)


def thinking_loop(i: int, count: int) -> FrameSpec:
    s = sine_loop(i, count)
    return FrameSpec(scale=1.0 + 0.006 * s, rotate=2.0 * s, y=-2.0 * sine_loop(i, count, math.pi / 2))


def wave(i: int, count: int) -> FrameSpec:
    s = sine_loop(i, count)
    return FrameSpec(scale=1.0 + 0.006 * abs(s), rotate=4.0 * s, x=1.0 * s, y=-1.5 * abs(s))


ANIMATIONS: tuple[AnimationSpec, ...] = (
    AnimationSpec(
        name="idle_breathe",
        source_asset="ClxMascotIdle",
        frame_count=12,
        fps=12,
        loops=True,
        note="Subtle breathing/bobbing loop with stable baseline and centered anchor.",
        curve=idle_breathe,
    ),
    AnimationSpec(
        name="encouraging_nod",
        source_asset="ClxMascotEncouraging",
        frame_count=14,
        fps=14,
        loops=False,
        note="Gentle nod with a small lift, then returns to neutral without bounce.",
        curve=encouraging_nod,
    ),
    AnimationSpec(
        name="celebrate_pop",
        source_asset="ClxMascotCelebrating",
        frame_count=16,
        fps=16,
        loops=False,
        note="Brief happy completion pop; no particles, confetti, or exaggerated bounce.",
        curve=celebrate_pop,
    ),
    AnimationSpec(
        name="saved_ack",
        source_asset="ClxMascotCelebrating",
        frame_count=12,
        fps=16,
        loops=False,
        note="Quick saved-line acknowledgement: tiny lift, soft tilt, and settle.",
        curve=saved_ack,
    ),
    AnimationSpec(
        name="review_cleared",
        source_asset="ClxMascotEncouraging",
        frame_count=14,
        fps=14,
        loops=False,
        note="Calm all-clear reaction: small relieved lift and steady return.",
        curve=review_cleared,
    ),
    AnimationSpec(
        name="thinking_loop",
        source_asset="ClxMascotThinking",
        frame_count=16,
        fps=10,
        loops=True,
        note="Slow thoughtful tilt/bob loop, compact enough for 34-90 px UI usage.",
        curve=thinking_loop,
    ),
    AnimationSpec(
        name="wave",
        source_asset="ClxMascotWaving",
        frame_count=16,
        fps=16,
        loops=True,
        note="Compact wave/sway loop using the approved waving pose.",
        curve=wave,
    ),
)


def image_path_for_asset(asset_name: str) -> Path:
    path = ASSET_ROOT / f"{asset_name}.imageset" / f"{asset_name}.png"
    if not path.exists():
        raise FileNotFoundError(f"Missing mascot asset: {path}")
    return path


def alpha_bbox(image: Image.Image) -> tuple[int, int, int, int]:
    bbox = image.getbbox()
    if bbox is None:
        raise ValueError("Mascot source image is fully transparent")
    return bbox


def prepare_source(path: Path, canvas: int) -> Image.Image:
    image = Image.open(path).convert("RGBA")
    image = image.crop(alpha_bbox(image))

    max_side = int(canvas * 0.78)
    ratio = min(max_side / image.width, max_side / image.height)
    size = (max(1, round(image.width * ratio)), max(1, round(image.height * ratio)))
    return image.resize(size, Image.Resampling.LANCZOS)


def render_frame(source: Image.Image, spec: FrameSpec, canvas: int) -> Image.Image:
    scaled_size = (
        max(1, round(source.width * spec.scale)),
        max(1, round(source.height * spec.scale)),
    )
    transformed = source.resize(scaled_size, Image.Resampling.LANCZOS)
    if abs(spec.rotate) > 0.001:
        transformed = transformed.rotate(spec.rotate, resample=Image.Resampling.BICUBIC, expand=True)

    frame = Image.new("RGBA", (canvas, canvas), (0, 0, 0, 0))

    # Stable anchor: keep the mascot centered and its baseline visually locked.
    baseline_y = canvas * 0.88
    x = round((canvas - transformed.width) / 2 + spec.x)
    y = round(baseline_y - transformed.height + spec.y)
    frame.alpha_composite(transformed, (x, y))
    return frame


def write_manifest(output: Path, canvas: int) -> None:
    payload = {
        "version": 1,
        "canvas": {"width": canvas, "height": canvas},
        "format": "transparent_png_sequence",
        "anchor": "centered_stable_baseline",
        "animations": [
            {
                "name": animation.name,
                "sourceAsset": animation.source_asset,
                "frames": animation.frame_count,
                "fps": animation.fps,
                "loops": animation.loops,
                "path": f"{animation.name}/%03d.png",
                "note": animation.note,
            }
            for animation in ANIMATIONS
        ],
    }
    (output / "melo_sprite_manifest.json").write_text(json.dumps(payload, indent=2) + "\n")


def generate(output: Path, canvas: int, clean: bool) -> None:
    output.mkdir(parents=True, exist_ok=True)

    for animation in ANIMATIONS:
        animation_dir = output / animation.name
        animation_dir.mkdir(parents=True, exist_ok=True)
        if clean:
            for old_frame in animation_dir.glob("*.png"):
                old_frame.unlink()

        source = prepare_source(image_path_for_asset(animation.source_asset), canvas)
        for index in range(animation.frame_count):
            frame = render_frame(source, animation.curve(index, animation.frame_count), canvas)
            frame.save(animation_dir / f"{index:03d}.png", optimize=True)

    write_manifest(output, canvas)


def main() -> None:
    parser = argparse.ArgumentParser(description="Generate Melo transparent PNG sprite frames.")
    parser.add_argument("--canvas", type=int, default=256, help="Square output canvas size in pixels.")
    parser.add_argument("--output", type=Path, default=DEFAULT_OUTPUT, help="Output folder for sprite frames.")
    parser.add_argument("--no-clean", action="store_true", help="Do not delete old PNGs from animation folders before generating.")
    args = parser.parse_args()

    generate(args.output, args.canvas, clean=not args.no_clean)
    print(f"Generated Melo sprite frames in {args.output}")


if __name__ == "__main__":
    main()

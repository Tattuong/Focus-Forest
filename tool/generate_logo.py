"""Generate Focus Forest square app logo (1024x1024, sharp corners)."""
from __future__ import annotations

import math
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter

SIZE = 1024
OUT = Path(__file__).resolve().parents[1] / "assets" / "logo.png"

FOREST_DARK = (15, 46, 28)
FOREST = (22, 101, 52)
FOREST_LIGHT = (34, 197, 94)
SKY = (134, 239, 172)
GOLD = (251, 191, 36)
TRUNK = (120, 72, 36)
WHITE = (255, 255, 255)


def lerp(a: int, b: int, t: float) -> int:
    return int(a + (b - a) * t)


def square_gradient(size: int) -> Image.Image:
    img = Image.new("RGB", (size, size))
    px = img.load()
    for y in range(size):
        for x in range(size):
            t = x / size * 0.35 + y / size * 0.65
            r = lerp(FOREST_DARK[0], FOREST[0], t * 0.85)
            g = lerp(FOREST_DARK[1], SKY[1], t * 0.9)
            b = lerp(FOREST_DARK[2], FOREST_LIGHT[2], t * 0.75)
            px[x, y] = (r, g, b)
    return img


def draw_tree(draw: ImageDraw.ImageDraw) -> None:
    # Trunk
    draw.rounded_rectangle((470, 560, 554, 780), radius=18, fill=TRUNK + (255,))
    draw.rounded_rectangle((470, 560, 554, 780), radius=18, outline=(90, 55, 25, 200), width=6)

    # Foliage layers
    layers = [
        (512, 520, 240, FOREST),
        (512, 420, 200, FOREST_LIGHT),
        (512, 330, 160, SKY),
    ]
    for cx, cy, r, color in layers:
        draw.ellipse((cx - r, cy - r, cx + r, cy + r), fill=color + (240,))
        draw.ellipse((cx - r + 20, cy - r + 10, cx + r - 20, cy + r - 10), fill=WHITE + (30,))

    # Small sprout at base
    draw.ellipse((430, 740, 470, 780), fill=FOREST_LIGHT + (200,))
    draw.ellipse((554, 735, 594, 775), fill=FOREST_LIGHT + (200,))


def draw_timer_ring(draw: ImageDraw.ImageDraw) -> None:
    bbox = (180, 180, 844, 844)
    draw.arc(bbox, start=200, end=340, fill=GOLD + (220,), width=28)
    draw.arc(bbox, start=340, end=200, fill=WHITE + (80,), width=14)


def draw_leaf_particles(draw: ImageDraw.ImageDraw) -> None:
    for cx, cy, r in [(780, 260, 18), (220, 320, 14), (760, 720, 12), (240, 680, 16)]:
        draw.ellipse((cx - r, cy - r, cx + r, cy + r), fill=FOREST_LIGHT + (180,))


def main() -> None:
    base = square_gradient(SIZE).convert("RGBA")
    overlay = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    draw = ImageDraw.Draw(overlay)
    draw_timer_ring(draw)
    draw_tree(draw)
    draw_leaf_particles(draw)

    glow = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    glow_draw = ImageDraw.Draw(glow)
    glow_draw.ellipse((300, 180, 724, 620), fill=(255, 255, 255, 35))
    glow = glow.filter(ImageFilter.GaussianBlur(55))

    composed = Image.alpha_composite(base, glow)
    composed = Image.alpha_composite(composed, overlay)
    OUT.parent.mkdir(parents=True, exist_ok=True)
    composed.convert("RGB").save(OUT, format="PNG", optimize=True)
    print(f"Saved Focus Forest logo: {OUT} ({SIZE}x{SIZE})")


if __name__ == "__main__":
    main()

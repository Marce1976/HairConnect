#!/usr/bin/env python3
"""Generate HairConnect app icon using exact Material Icons content_cut.
- Tips pointing DOWN (verified: 270° rotation)
- Blurred/diffused scissors behind text
- "HairConnect" integrated, all in white
"""

from PIL import Image, ImageDraw, ImageFont, ImageFilter
import os

SIZE = 1024
OUTPUT = "assets/app_icon.png"

PRIMARY = (42, 81, 115)    # #2a5173
GOLD = (200, 151, 74)      # #c8974a
WHITE = (255, 255, 255)

img = Image.new("RGBA", (SIZE, SIZE), PRIMARY + (255,))
draw = ImageDraw.Draw(img)

# --- Gold rounded border ---
draw.rounded_rectangle([(16, 16), (SIZE - 16, SIZE - 16)],
                       radius=130, outline=GOLD, width=16)

# ------------------------------------------------------------------
# Render exact Material Icons content_cut (U+E191)
# Finger holes at TOP → tips point DOWN (270° rotation)
# ------------------------------------------------------------------
mat_font = ImageFont.truetype(
    "/Users/marce/develop/flutter/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf",
    720
)

icon_layer = Image.new("RGBA", (SIZE * 2, SIZE * 2), (0, 0, 0, 0))
il_draw = ImageDraw.Draw(icon_layer)

ib = il_draw.textbbox((0, 0), chr(0xe191), font=mat_font)
iw = ib[2] - ib[0]
ih = ib[3] - ib[1]

ix = (SIZE * 2 - iw) // 2
iy = -ib[1] + (SIZE * 2 - ih) // 2

# Gold at low opacity for blurred/diffused effect
il_draw.text((ix, iy), chr(0xe191), fill=GOLD + (130,), font=mat_font)

# 270° rotation → finger holes at TOP → tips point DOWN
icon_layer = icon_layer.rotate(270, expand=True, center=(SIZE, SIZE))

# Gaussian blur
icon_layer = icon_layer.filter(ImageFilter.GaussianBlur(radius=14))

# Crop centered
cw, ch = icon_layer.size
left = (cw - SIZE) // 2
top = (ch - SIZE) // 2
icon_layer = icon_layer.crop((left, top, left + SIZE, top + SIZE))

img = Image.alpha_composite(img, icon_layer)
draw = ImageDraw.Draw(img)

# ------------------------------------------------------------------
# Text: "Hair" and "Connect" close together, all white
# H and C feel connected by tight spacing
# ------------------------------------------------------------------
def load_font(path, size):
    try:
        return ImageFont.truetype(path, size)
    except:
        return None

font_h = load_font("/System/Library/Fonts/Supplemental/Arial Bold.ttf", 280)
if not font_h:
    font_h = load_font("/System/Library/Fonts/Helvetica.ttc", 280)

font_c = load_font("/System/Library/Fonts/Supplemental/Arial Bold.ttf", 280)
if not font_c:
    font_c = load_font("/System/Library/Fonts/Helvetica.ttc", 280)

# Measure words
bh = draw.textbbox((0, 0), "Hair", font=font_h)
ww_hair = bh[2] - bh[0]
hh_hair = bh[3] - bh[1]

bc = draw.textbbox((0, 0), "Connect", font=font_c)
ww_conn = bc[2] - bc[0]
hh_conn = bc[3] - bc[1]

# Gap tight to connect them as one brand
gap = 6
total_h = hh_hair + gap + hh_conn
start_y = (SIZE - total_h) // 2

# Both centered, all white
draw.text(((SIZE - ww_hair) // 2, start_y), "Hair", fill=WHITE, font=font_h)
draw.text(((SIZE - ww_conn) // 2, start_y + hh_hair + gap), "Connect", fill=WHITE, font=font_c)

os.makedirs("assets", exist_ok=True)
img.save(OUTPUT, "PNG")
print(f"✅ Icon generated: {OUTPUT} ({SIZE}x{SIZE})")
print(f"   Rotation: 270° → tips DOWN")
print(f"   Text: Hair + Connect (gap={gap}px), all white")

"""Generate booth badge PNGs for the public Booths page.

Reads unique booth numbers + dominant programme code directly from
`lib/core/data/excel_data.dart` so the badges match the app's data 1:1.
Outputs one square rounded-corner badge per booth into `web/booth_images/`.

Mirrors the style helpers used by `generate_project_images.py`.
"""

import os
import re
from collections import Counter
from PIL import Image, ImageDraw, ImageFont

DATA_PATH = r'D:\MobileAppDev\FYPExpoHub\lib\core\data\excel_data.dart'
OUTPUT_DIR = r'D:\MobileAppDev\FYPExpoHub\web\booth_images'

SIZE = 400
RADIUS_RATIO = 0.28

# Matches the UI badge colors in booths_page.dart (`_venueBadgeColor`).
VENUE_COLORS = {
    'DS5': '#607D8B',  # blueGrey
    'DS6': '#607D8B',
    'DS7': '#FFC107',  # amber
    'DS8': '#FFC107',
    'BK1': '#4CAF50',  # green
    'BK2': '#4CAF50',
    'BK3': '#4CAF50',
    'BK4': '#4CAF50',
    'BK5': '#9C27B0',  # purple
    'BK6': '#9C27B0',
    'BK7': '#9C27B0',
    'BK8': '#9C27B0',
}

# A slightly darker shade per venue for the badge border / depth.
VENUE_DARK = {
    'DS5': '#455A64',
    'DS6': '#455A64',
    'DS7': '#FFA000',
    'DS8': '#FFA000',
    'BK1': '#388E3C',
    'BK2': '#388E3C',
    'BK3': '#388E3C',
    'BK4': '#388E3C',
    'BK5': '#7B1FA2',
    'BK6': '#7B1FA2',
    'BK7': '#7B1FA2',
    'BK8': '#7B1FA2',
}


def try_font(size, bold=False):
    candidates = [
        ("C:\\Windows\\Fonts\\segoeuib.ttf" if bold else "C:\\Windows\\Fonts\\segoeui.ttf"),
        ("C:\\Windows\\Fonts\\arialbd.ttf" if bold else "C:\\Windows\\Fonts\\arial.ttf"),
        ("C:\\Windows\\Fonts\\calibrib.ttf" if bold else "C:\\Windows\\Fonts\\calibri.ttf"),
    ]
    for fp in candidates:
        if os.path.exists(fp):
            try:
                return ImageFont.truetype(fp, size)
            except Exception:
                pass
    return ImageFont.load_default()


def hexrgb(h):
    h = h.lstrip('#')
    return tuple(int(h[i:i + 2], 16) for i in (0, 2, 4))


def parse_booths():
    """Return {booth_number: dominant_programme_code} in data-file order."""
    entries = []  # list of dicts: {booth, prog}
    cur = {}
    with open(DATA_PATH, 'r', encoding='utf-8') as f:
        for line in f:
            m = re.search(r'"booth_number": \'([A-Z0-9]+-[0-9]+)\'', line)
            if m:
                cur['booth'] = m.group(1)
            m = re.search(r'"programme_code": \'([A-Z0-9]+)\'', line)
            if m:
                cur['prog'] = m.group(1)
            if re.match(r'^\s*\},\s*$', line):
                if cur.get('booth') and cur.get('prog'):
                    entries.append(cur)
                cur = {}

    # Dominant programme per booth (most frequent, alphabetical tie-break).
    by_booth = {}
    for e in entries:
        by_booth.setdefault(e['booth'], []).append(e['prog'])
    result = {}
    for booth, progs in by_booth.items():
        counter = Counter(progs)
        most = max(counter.keys(), key=lambda p: (counter[p], -ord(p[0])))
        result[booth] = most
    return result


# Safe text area inside the ring: keep a comfortable margin from the border.
MAX_TEXT_W = SIZE - 2 * 48
MAX_TEXT_H = SIZE - 2 * 56
FONT_MIN = 40
FONT_MAX = 130


def fit_font(draw, booth):
    """Largest bold font size whose bounding box fits the safe text area."""
    for size in range(FONT_MAX, FONT_MIN - 1, -2):
        f = try_font(size, bold=True)
        bb = draw.textbbox((0, 0), booth, font=f)
        w = bb[2] - bb[0]
        h = bb[3] - bb[1]
        if w <= MAX_TEXT_W and h <= MAX_TEXT_H:
            return f, bb
    return try_font(FONT_MIN, bold=True), draw.textbbox((0, 0), booth, font=try_font(FONT_MIN, bold=True))


def draw_badge(booth):
    zone = booth.split('-')[0]
    base = hexrgb(VENUE_COLORS.get(zone, '#3B82F6'))
    dark = hexrgb(VENUE_DARK.get(zone, '#1D4ED8'))

    img = Image.new('RGBA', (SIZE, SIZE), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    radius = int(SIZE * RADIUS_RATIO)

    # Badge body with subtle vertical depth: darker on top, base below.
    draw.rounded_rectangle([0, 0, SIZE - 1, SIZE - 1], radius=radius, fill=base)
    draw.rounded_rectangle(
        [0, 0, SIZE - 1, int(SIZE * 0.55)], radius=radius, fill=dark
    )
    # Re-round the lower corners of the top overlay (draw a base-colored cap).
    draw.rounded_rectangle(
        [0, int(SIZE * 0.45), SIZE - 1, SIZE - 1], radius=radius, fill=base
    )

    # Inner ring.
    ring = (255, 255, 255, 90)
    draw.rounded_rectangle(
        [18, 18, SIZE - 19, SIZE - 19], radius=radius - 10, outline=ring, width=3
    )

    # Booth number, auto-fitted to stay well inside the border.
    f_num, bb = fit_font(draw, booth)
    num_w = bb[2] - bb[0]
    num_h = bb[3] - bb[1]
    num_x = (SIZE - num_w) / 2 - bb[0]
    num_y = (SIZE - num_h) / 2 - bb[1]
    draw.text((num_x, num_y), booth, fill='white', font=f_num)

    out = Image.new('RGB', (SIZE, SIZE), (255, 255, 255))
    out.paste(img, (0, 0), img)
    return out


def main():
    booths = parse_booths()
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    total = 0
    for booth in booths:
        img = draw_badge(booth)
        out_path = os.path.join(OUTPUT_DIR, f'booth-{booth}.png')
        img.save(out_path, quality=92, optimize=True)
        total += 1
    print(f'\nDone! Generated {total} booth badges.')
    print(f'Output: {OUTPUT_DIR}')


if __name__ == '__main__':
    main()

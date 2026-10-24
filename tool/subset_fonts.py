"""Subset the bundled fonts to the characters the app uses.

The original Inter, Fraunces and JetBrains Mono files carry Cyrillic, Greek
extended, Vietnamese and many stylistic alternates the app never shows; the
subset keeps every weight and the Latin text, punctuation and symbols used
in lib/ and the bundled data (checked 2026-10-24: Latin, a few accented
letters, Greek capitals, dashes, quotes, bullets, ellipsis, arrows, >=).
1.85 MB -> 0.75 MB.

Usage (fonttools needed: pip install fonttools):
    python tool/subset_fonts.py ORIGINALS_DIR
ORIGINALS_DIR holds the full upstream .ttf files (also in git history before
this change); the subsets are written to assets/fonts/.
A character outside these ranges still renders: Flutter web falls back to a
downloaded Noto font for missing glyphs.
"""
import pathlib
import subprocess
import sys

UNICODES = ",".join([
    "U+0000-024F",  # Basic Latin to Latin Extended-B
    "U+0300-036F",  # combining marks
    "U+0370-03FF",  # Greek (e.g. the sigma in rubric formulas)
    "U+2000-206F",  # general punctuation: dashes, quotes, bullet, ellipsis
    "U+20A0-20CF",  # currency
    "U+2100-218F",  # letterlike symbols, number forms
    "U+2190-21FF",  # arrows
    "U+2200-22FF",  # maths operators
    "U+2500-257F",  # box drawing
    "U+25A0-27BF",  # shapes, misc symbols, dingbats
    "U+FEFF",
])
FEATURES = "kern,liga,clig,calt,ccmp,locl,mark,mkmk,tnum,lnum,pnum,case"


def main() -> None:
    src = pathlib.Path(sys.argv[1])
    out = pathlib.Path(__file__).resolve().parent.parent / "assets" / "fonts"
    for font in sorted(src.glob("*.ttf")):
        subprocess.run([
            sys.executable, "-m", "fontTools.subset", str(font),
            f"--unicodes={UNICODES}", f"--layout-features={FEATURES}",
            "--no-hinting", "--desubroutinize",
            f"--output-file={out / font.name}",
        ], check=True)
        print(font.name, (out / font.name).stat().st_size)


if __name__ == "__main__":
    main()

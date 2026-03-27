#!/usr/bin/env python3
"""Compose a thumbnail image with metadata text below it for ranger previews.

Usage (ranger mode):
  preview_composite.py <image_path> <output_path> <pv_width> <pv_height> [metadata_cmd...]

  - image_path:    Path to the thumbnail image (or "-" to skip, showing only metadata)
  - output_path:   Where to write the composite PNG (IMAGE_CACHE_PATH)
  - pv_width:      Preview pane width in characters
  - pv_height:     Preview pane height in characters
  - metadata_cmd:  Command to run to get metadata text (e.g. "exiftool /path/to/file")

Usage (interactive preview mode):
  preview_composite.py --preview <media_file> [output_path]

  Opens a Pillow window showing the composite preview for the given media file.
  Automatically detects file type and runs the appropriate metadata command.
  If output_path is provided, the composite image is also saved there.

The composite image has the thumbnail scaled to fit the top portion of the
preview pane, with metadata text rendered below it in a monospace font.
"""

import subprocess
import sys
import os

try:
    from PIL import Image, ImageDraw, ImageFont
except ImportError:
    # Pillow not in current environment — re-exec under nix-shell with it
    # Also pull in exiftool and mediainfo so metadata commands work.
    os.execvp("nix-shell", [
        "nix-shell", "-p", "python3Packages.pillow", "exiftool", "mediainfo",
        "--run", "python3 " + " ".join(f'"{a}"' for a in sys.argv),
    ])


# --- Configuration -----------------------------------------------------------
FONT_SIZE = 14
LINE_SPACING = 3
TEXT_COLOR = (200, 200, 200)
BG_COLOR = (30, 30, 30)
SEPARATOR_COLOR = (80, 80, 80)
WARN_COLOR = (200, 170, 50)
WARN_BG_COLOR = (50, 45, 30)
PADDING = 10
# Fraction of total height reserved for the thumbnail (rest is metadata)
THUMB_FRACTION = 0.50
# Approximate character cell size in pixels for width estimation
CHAR_WIDTH_PX = 8
CHAR_HEIGHT_PX = 18


def get_monospace_font(size):
    """Try to load a monospace font, fall back to Pillow default."""
    font_paths = [
        "/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf",
        "/usr/share/fonts/TTF/DejaVuSansMono.ttf",
        "/usr/share/fonts/dejavu-sans-mono-fonts/DejaVuSansMono.ttf",
        "/usr/share/fonts/truetype/liberation/LiberationMono-Regular.ttf",
        "/usr/share/fonts/liberation-mono/LiberationMono-Regular.ttf",
        "/usr/share/fonts/truetype/noto/NotoSansMono-Regular.ttf",
    ]
    # Also search via fc-match
    try:
        result = subprocess.run(
            ["fc-match", "--format=%{file}", "monospace"],
            capture_output=True, text=True, timeout=2,
        )
        if result.returncode == 0 and result.stdout.strip():
            font_paths.insert(0, result.stdout.strip())
    except Exception:
        pass

    for path in font_paths:
        if os.path.isfile(path):
            try:
                return ImageFont.truetype(path, size)
            except Exception:
                continue
    return ImageFont.load_default()


def _run_cmd(cmd_parts, timeout=10):
    """Run a command, falling back to nix-shell if the binary isn't found."""
    try:
        result = subprocess.run(
            cmd_parts, capture_output=True, text=True, timeout=timeout,
        )
        return result
    except FileNotFoundError:
        # Binary not on PATH — try through nix-shell
        nix_pkg = {"exiftool": "exiftool", "mediainfo": "mediainfo"}.get(cmd_parts[0])
        if nix_pkg:
            shell_cmd = " ".join(f'"{a}"' for a in cmd_parts)
            result = subprocess.run(
                ["nix-shell", "-p", nix_pkg, "--run", shell_cmd],
                capture_output=True, text=True, timeout=30,
            )
            return result
        raise


def get_metadata(cmd_parts):
    """Run a metadata command and return its stdout text."""
    try:
        result = _run_cmd(cmd_parts)
        return result.stdout.strip()
    except Exception:
        return ""


def draw_warning_banner(draw, font, canvas_w, y_start, message):
    """Draw a warning banner with centered text. Returns the banner height."""
    line_h = FONT_SIZE + LINE_SPACING
    banner_h = line_h * 2 + PADDING
    draw.rectangle(
        [(PADDING, y_start), (canvas_w - PADDING, y_start + banner_h)],
        fill=WARN_BG_COLOR,
    )
    draw.rectangle(
        [(PADDING, y_start), (canvas_w - PADDING, y_start + banner_h)],
        outline=WARN_COLOR, width=1,
    )
    # Center the warning symbol and message
    warn_symbol = "⚠"
    try:
        sym_bbox = draw.textbbox((0, 0), warn_symbol, font=font)
        sym_w = sym_bbox[2] - sym_bbox[0]
    except Exception:
        sym_w = FONT_SIZE
    sym_x = (canvas_w - sym_w) // 2
    draw.text((sym_x, y_start + PADDING // 2), warn_symbol, fill=WARN_COLOR, font=font)

    try:
        msg_bbox = draw.textbbox((0, 0), message, font=font)
        msg_w = msg_bbox[2] - msg_bbox[0]
    except Exception:
        msg_w = len(message) * (FONT_SIZE * 6 // 10)
    msg_x = (canvas_w - msg_w) // 2
    draw.text((msg_x, y_start + line_h + PADDING // 2), message, fill=WARN_COLOR, font=font)
    return banner_h


def create_composite(image_path, output_path, pv_width, pv_height, metadata_cmd):
    canvas_w = max(pv_width * CHAR_WIDTH_PX, 320)
    canvas_h = max(pv_height * CHAR_HEIGHT_PX, 240)

    font = get_monospace_font(FONT_SIZE)
    line_h = FONT_SIZE + LINE_SPACING

    # --- Fixed 50/50 layout: upper half = image, lower half = text -----------
    image_area_h = int(canvas_h * THUMB_FRACTION)
    text_area_h = canvas_h - image_area_h

    # --- Get metadata text ---------------------------------------------------
    metadata_text = ""
    if metadata_cmd:
        metadata_text = get_metadata(metadata_cmd)

    # --- Load and scale thumbnail --------------------------------------------
    thumb = None
    thumb_failed = False
    if image_path == "-":
        thumb_failed = True
    elif image_path and os.path.isfile(image_path):
        try:
            thumb = Image.open(image_path)
            try:
                from PIL import ImageOps
                thumb = ImageOps.exif_transpose(thumb)
            except Exception:
                pass
            thumb = thumb.convert("RGBA")

            max_thumb_h = image_area_h - PADDING * 2
            max_thumb_w = canvas_w - PADDING * 2
            thumb.thumbnail((max_thumb_w, max_thumb_h), Image.LANCZOS)
        except Exception:
            thumb = None
            thumb_failed = True
    else:
        thumb_failed = True

    # --- Wrap metadata lines to fit canvas width -----------------------------
    max_text_w = canvas_w - PADDING * 2
    wrapped_lines = []
    if metadata_text:
        chars_per_line = max(max_text_w // (FONT_SIZE * 6 // 10), 20)
        for raw_line in metadata_text.splitlines():
            if not raw_line.strip():
                continue
            while len(raw_line) > chars_per_line:
                wrapped_lines.append(raw_line[:chars_per_line])
                raw_line = raw_line[chars_per_line:]
            wrapped_lines.append(raw_line)

    # Limit lines so they fit in the text area
    meta_avail_h = text_area_h - PADDING * 2
    max_lines = max(meta_avail_h // line_h, 1) if meta_avail_h > 0 else 0
    if len(wrapped_lines) > max_lines:
        wrapped_lines = wrapped_lines[:max_lines]

    # --- Draw composite ------------------------------------------------------
    canvas = Image.new("RGB", (canvas_w, canvas_h), BG_COLOR)
    draw = ImageDraw.Draw(canvas)

    # -- Upper half: image, vertically centered in the image area --
    if thumb:
        x_offset = (canvas_w - thumb.size[0]) // 2
        y_offset = (image_area_h - thumb.size[1]) // 2
        canvas.paste(thumb, (x_offset, y_offset), thumb if thumb.mode == "RGBA" else None)
    elif thumb_failed:
        warn_y = (image_area_h - (line_h * 2 + PADDING)) // 2
        draw_warning_banner(draw, font, canvas_w, max(warn_y, PADDING // 2),
                            "Thumbnail could not be generated")

    # -- Separator line at the boundary --
    has_sep = bool(metadata_text or thumb or thumb_failed)
    if has_sep:
        sep_y = image_area_h
        draw.line([(PADDING, sep_y), (canvas_w - PADDING, sep_y)], fill=SEPARATOR_COLOR, width=1)

    # -- Lower half: metadata text --
    y = image_area_h + PADDING
    for line in wrapped_lines:
        draw.text((PADDING, y), line, fill=TEXT_COLOR, font=font)
        y += line_h

    return canvas


def detect_media_type(filepath):
    """Detect MIME type and return (thumbnail_path_or_dash, metadata_cmd)."""
    import mimetypes
    import tempfile

    mime, _ = mimetypes.guess_type(filepath)
    if not mime:
        try:
            result = subprocess.run(
                ["file", "--dereference", "--brief", "--mime-type", "--", filepath],
                capture_output=True, text=True, timeout=5,
            )
            mime = result.stdout.strip()
        except Exception:
            mime = ""

    thumb_path = tempfile.mktemp(suffix=".png")

    if mime.startswith("image/"):
        return filepath, ["exiftool", filepath]
    elif mime.startswith("video/"):
        try:
            subprocess.run(
                ["ffmpegthumbnailer", "-i", filepath, "-o", thumb_path, "-s", "0"],
                capture_output=True, timeout=15,
            )
            if os.path.isfile(thumb_path):
                return thumb_path, ["mediainfo", filepath]
        except Exception:
            pass
        return "-", ["mediainfo", filepath]
    elif mime.startswith("audio/"):
        try:
            subprocess.run(
                ["ffmpeg", "-y", "-i", filepath, "-map", "0:v", "-map", "-0:V",
                 "-c", "copy", thumb_path],
                capture_output=True, timeout=10,
            )
            if os.path.isfile(thumb_path):
                return thumb_path, ["mediainfo", filepath]
        except Exception:
            pass
        return "-", ["mediainfo", filepath]
    elif mime == "application/pdf":
        return filepath, ["exiftool", filepath]
    else:
        return filepath, ["exiftool", filepath]


def has_chafa():
    """Return True if chafa is available on PATH."""
    import shutil
    return shutil.which("chafa") is not None


def display_image_chafa(image_path):
    """Display an image in the terminal using chafa."""
    try:
        subprocess.run(["chafa", "--animate=off", image_path], timeout=10)
    except Exception:
        pass


def print_metadata_pretty(media_file, metadata_text):
    """Print file metadata to the terminal with pretty formatting."""
    # Terminal colors
    BOLD = "\033[1m"
    DIM = "\033[2m"
    CYAN = "\033[36m"
    YELLOW = "\033[33m"
    GREEN = "\033[32m"
    RESET = "\033[0m"

    try:
        cols = os.get_terminal_size().columns
    except Exception:
        cols = 80

    border = DIM + "─" * cols + RESET
    print()
    print(border)
    print(f"  {BOLD}{CYAN}📄 {os.path.basename(media_file)}{RESET}")
    print(f"  {DIM}{media_file}{RESET}")
    print(border)

    if not metadata_text:
        print(f"  {DIM}(no metadata available){RESET}")
        print(border)
        print()
        return

    for line in metadata_text.splitlines():
        if not line.strip():
            continue
        # exiftool / mediainfo lines are typically "Key : Value"
        if ":" in line:
            key, _, value = line.partition(":")
            key = key.strip()
            value = value.strip()
            print(f"  {YELLOW}{key:<30}{RESET} {DIM}:{RESET} {GREEN}{value}{RESET}")
        else:
            print(f"  {BOLD}{line}{RESET}")

    print(border)
    print()


def main():
    # --- Interactive preview mode ---
    if len(sys.argv) >= 3 and sys.argv[1] == "--preview":
        media_file = sys.argv[2]
        if not os.path.isfile(media_file):
            print(f"Error: file not found: {media_file}", file=sys.stderr)
            sys.exit(1)

        output_path = sys.argv[3] if len(sys.argv) >= 4 else None

        import tempfile

        thumb_path, meta_cmd = detect_media_type(media_file)

        # Build the composite image
        canvas = create_composite(thumb_path, None, 80, 40, meta_cmd)

        # Determine output path (use a temp file if not specified)
        tmp_composite = None
        if not output_path:
            tmp_composite = tempfile.mktemp(suffix=".png", prefix="ranger_preview_")
            output_path = tmp_composite
        canvas.save(output_path, "PNG")

        # Clean up temp thumbnail if it was generated
        if thumb_path not in ("-", media_file) and os.path.isfile(thumb_path):
            os.unlink(thumb_path)

        try:
            if has_chafa():
                # Display the composite image inline via chafa
                display_image_chafa(output_path)
            else:
                # Fall back to text-only metadata output
                metadata_text = get_metadata(meta_cmd) if meta_cmd else ""
                print_metadata_pretty(media_file, metadata_text)
        finally:
            # Clean up temp composite if we created one
            if tmp_composite and os.path.isfile(tmp_composite):
                os.unlink(tmp_composite)

        return

    # --- Ranger mode ---
    if len(sys.argv) < 5:
        print(
            f"Usage: {sys.argv[0]} <image_path> <output_path> <pv_width> <pv_height> [metadata_cmd...]\n"
            f"       {sys.argv[0]} --preview <media_file> [output_path]",
            file=sys.stderr,
        )
        sys.exit(1)

    image_path = sys.argv[1]
    output_path = sys.argv[2]
    pv_width = int(sys.argv[3])
    pv_height = int(sys.argv[4])
    metadata_cmd = sys.argv[5:] if len(sys.argv) > 5 else []

    canvas = create_composite(image_path, output_path, pv_width, pv_height, metadata_cmd)
    canvas.save(output_path, "PNG")


if __name__ == "__main__":
    main()

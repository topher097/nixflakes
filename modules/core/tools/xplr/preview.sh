#!/usr/bin/env bash
set -euo pipefail

path="${1:-}"
pane_width="${2:-80}"
pane_height="${3:-40}"

# Keep one row for safety so the pane doesn't aggressively scroll.
max_lines="$(( pane_height > 1 ? pane_height - 1 : 1 ))"

# Chafa renders best when font ratio roughly matches common terminal cells.
font_ratio="1/2"
image_symbols="block+border+half+vhalf+quad+sextant+braille"

# Keep dimensions sane in case of transient layout values.
if [[ "${pane_width}" -lt 10 ]]; then
  pane_width=10
fi
if [[ "${pane_height}" -lt 4 ]]; then
  pane_height=4
fi

if [[ -z "${path}" ]]; then
  printf 'No file selected.\n'
  exit 0
fi

if [[ ! -e "${path}" ]]; then
  printf 'Path does not exist: %s\n' "${path}"
  exit 0
fi

mime="$(file --dereference --brief --mime-type -- "${path}" 2>/dev/null || true)"

print_header() {
  printf 'Type: %s\n' "${mime:-unknown}"
  printf 'Path: %s\n\n' "${path}"
}

print_directory() {
  print_header
  if command -v tree >/dev/null 2>&1; then
    tree -a -L 2 -- "${path}" | sed -n "1,${max_lines}p"
  else
    ls -la --group-directories-first -- "${path}" | sed -n "1,${max_lines}p"
  fi
}

print_text() {
  print_header
  if command -v bat >/dev/null 2>&1; then
    bat --style=plain --color=always --paging=never --line-range "1:${max_lines}" -- "${path}"
  else
    sed -n "1,${max_lines}p" -- "${path}"
  fi
}

print_image() {
  # Keep the full pane height for image detail (no textual header here).
  # Use symbols mode for xplr preview panes. Kitty protocol escape sequences
  # are rendered as literal text in this context.
  if command -v chafa >/dev/null 2>&1; then
    chafa \
      --format symbols \
      --probe off \
      --passthrough none \
      --animate=off \
      --colors full \
      --work 9 \
      --color-space din99d \
      --color-extractor median \
      --font-ratio "${font_ratio}" \
      --dither diffusion \
      --symbols "${image_symbols}" \
      --size="${pane_width}x${pane_height}" \
      -- "${path}" || true
  else
    printf 'chafa is not installed.\n'
  fi
}

print_video_or_audio() {
  print_header

  if command -v ffmpegthumbnailer >/dev/null 2>&1 && command -v chafa >/dev/null 2>&1; then
    local thumb
    thumb="$(mktemp --suffix=.jpg /tmp/xplr-thumb-XXXXXX)"
    if ffmpegthumbnailer -i "${path}" -o "${thumb}" -s 0 >/dev/null 2>&1; then
      local media_height
      media_height="$(( max_lines > 6 ? max_lines - 6 : max_lines ))"

      chafa \
        --format symbols \
        --probe off \
        --passthrough none \
        --animate=off \
        --colors full \
        --work 9 \
        --color-space din99d \
        --color-extractor median \
        --font-ratio "${font_ratio}" \
        --dither diffusion \
        --symbols "${image_symbols}" \
        --size="${pane_width}x${media_height}" \
        -- "${thumb}" || true
      printf '\n'
    fi
    rm -f -- "${thumb}"
  fi

  if command -v mediainfo >/dev/null 2>&1; then
    mediainfo -- "${path}" | sed -n "1,${max_lines}p"
  else
    printf 'mediainfo is not installed.\n'
  fi
}

print_pdf() {
  print_header
  if command -v pdftotext >/dev/null 2>&1; then
    pdftotext -l 1 -- "${path}" - 2>/dev/null | sed -n "1,${max_lines}p"
  else
    printf 'pdftotext is not installed.\n'
  fi
}

print_archive() {
  print_header
  if command -v bsdtar >/dev/null 2>&1; then
    bsdtar -tf -- "${path}" | sed -n "1,${max_lines}p"
  elif command -v 7z >/dev/null 2>&1; then
    7z l -- "${path}" | sed -n "1,${max_lines}p"
  else
    printf 'No archive lister found (bsdtar/7z).\n'
  fi
}

if [[ -d "${path}" ]]; then
  print_directory
  exit 0
fi

case "${mime}" in
  text/* | */json | */xml | */javascript | */x-sh)
    print_text
    ;;
  image/*)
    print_image
    ;;
  video/* | audio/*)
    print_video_or_audio
    ;;
  application/pdf)
    print_pdf
    ;;
  application/zip | application/x-7z-compressed | application/x-rar | application/x-tar | application/gzip | application/x-bzip2 | application/x-xz)
    print_archive
    ;;
  *)
    print_header
    if command -v file >/dev/null 2>&1; then
      file --dereference --brief -- "${path}"
    else
      printf 'No preview handler for this file type.\n'
    fi
    ;;
esac

#!/usr/bin/env bash
# Compose a thumbnail image with metadata text below it for ranger previews.
#
# Usage (ranger mode):
#   preview_composite.sh <image_path> <output_path> <pv_width> <pv_height> [metadata_cmd...]
#
#   - image_path:    Path to the thumbnail image (or "-" to skip, showing only metadata)
#   - output_path:   Where to write the composite PNG (IMAGE_CACHE_PATH)
#   - pv_width:      Preview pane width in characters
#   - pv_height:     Preview pane height in characters
#   - metadata_cmd:  Command to run to get metadata text (e.g. "exiftool /path/to/file")
#
# Usage (interactive preview mode):
#   preview_composite.sh --preview <media_file> [output_path]
#
#   Displays the composite preview for the given media file.
#   Automatically detects file type and runs the appropriate metadata command.
#   If chafa is available, displays the composite image inline in the terminal.
#   Otherwise, prints pretty-formatted metadata text.
#
# Dependencies: ImageMagick 7 (magick), exiftool, mediainfo, ffmpegthumbnailer, ffmpeg, chafa
# All expected on PATH via ranger extraPackages in default.nix.

set -euo pipefail

# --- Configuration -----------------------------------------------------------
FONT_SIZE=14
LINE_SPACING=3
TEXT_COLOR="rgb(200,200,200)"
BG_COLOR="rgb(30,30,30)"
SEPARATOR_COLOR="rgb(80,80,80)"
WARN_COLOR="rgb(200,170,50)"
WARN_BG_COLOR="rgb(50,45,30)"
PADDING=10
THUMB_FRACTION=50  # percentage of canvas height for the image area
CHAR_WIDTH_PX=8
CHAR_HEIGHT_PX=18

# --- Temp file tracking ------------------------------------------------------
_TMPFILES=()
cleanup() {
    for f in "${_TMPFILES[@]}"; do
        [[ -f "$f" ]] && rm -f "$f"
    done
}
trap cleanup EXIT

mktmp() {
    local f
    f=$(mktemp /tmp/ranger_preview_XXXXXX.png)
    _TMPFILES+=("$f")
    echo "$f"
}

# --- Font discovery (cached) ------------------------------------------------
_FONT_PATH=""
_FONT_RESOLVED=false
get_font_path() {
    if [[ "$_FONT_RESOLVED" == true ]]; then
        echo "$_FONT_PATH"
        return
    fi
    _FONT_RESOLVED=true
    # Try fc-match first
    local font
    font=$(fc-match --format='%{file}' monospace 2>/dev/null || true)
    if [[ -n "$font" && -f "$font" ]]; then
        _FONT_PATH="$font"
        echo "$_FONT_PATH"
        return
    fi
    # Fallback list
    local p
    for p in \
        "/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf" \
        "/usr/share/fonts/TTF/DejaVuSansMono.ttf" \
        "/usr/share/fonts/dejavu-sans-mono-fonts/DejaVuSansMono.ttf" \
        "/usr/share/fonts/truetype/liberation/LiberationMono-Regular.ttf" \
        "/usr/share/fonts/liberation-mono/LiberationMono-Regular.ttf" \
        "/usr/share/fonts/truetype/noto/NotoSansMono-Regular.ttf"; do
        if [[ -f "$p" ]]; then
            _FONT_PATH="$p"
            echo "$_FONT_PATH"
            return
        fi
    done
    echo ""
}

# --- Composite image creation ------------------------------------------------
# Uses a two-stage pipeline with parallel metadata fetching:
#   Stage 1: Resize thumbnail + build canvas + separator (magick → MPC)
#            concurrently with: metadata command + font lookup (background)
#   Stage 2: Overlay text annotations onto the MPC and write final PNG
create_composite() {
    local image_path="$1" output_path="$2" pv_width="$3" pv_height="$4"
    shift 4
    local metadata_cmd=("$@")

    local canvas_w=$(( pv_width * CHAR_WIDTH_PX ))
    local canvas_h=$(( pv_height * CHAR_HEIGHT_PX ))
    (( canvas_w < 320 )) && canvas_w=320
    (( canvas_h < 240 )) && canvas_h=240

    local image_area_h=$(( canvas_h * THUMB_FRACTION / 100 ))
    local text_area_h=$(( canvas_h - image_area_h ))
    local line_h=$(( FONT_SIZE + LINE_SPACING ))

    # --- Check thumbnail ---
    local thumb_failed=false
    if [[ "$image_path" == "-" || -z "$image_path" || ! -f "$image_path" ]]; then
        thumb_failed=true
    fi

    # --- Stage 1: parallel work -----------------------------------------------
    # Background: fetch metadata
    local meta_file
    meta_file=$(mktmp)
    local meta_pid=0
    if [[ ${#metadata_cmd[@]} -gt 0 ]]; then
        "${metadata_cmd[@]}" > "$meta_file" 2>/dev/null &
        meta_pid=$!
    fi

    # Background: resolve font
    local font_file
    font_file=$(mktmp)
    get_font_path > "$font_file" &
    local font_pid=$!

    # Foreground: build canvas + thumbnail + separator into MPC (uncompressed pixel cache)
    local partial_mpc
    partial_mpc=$(mktmp)
    partial_mpc="${partial_mpc%.png}.mpc"
    _TMPFILES+=("$partial_mpc" "${partial_mpc%.mpc}.cache")

    local max_thumb_h=$(( image_area_h - PADDING * 2 ))
    local max_thumb_w=$(( canvas_w - PADDING * 2 ))
    local hint_w=$(( max_thumb_w * 2 ))
    local hint_h=$(( max_thumb_h * 2 ))
    local thumb_geom="${max_thumb_w}x${max_thumb_h}"

    local -a stage1_args=()

    if [[ "$thumb_failed" == false ]]; then
        stage1_args+=(\( -size "${canvas_w}x${canvas_h}" "xc:${BG_COLOR}" \))
        stage1_args+=(\( -define "jpeg:size=${hint_w}x${hint_h}" "$image_path" \
            -auto-orient -thumbnail "${thumb_geom}>" \
            -background "${BG_COLOR}" -gravity center -extent "${canvas_w}x${image_area_h}" \))
        stage1_args+=(-gravity north -composite)
    else
        stage1_args+=(-size "${canvas_w}x${canvas_h}" "xc:${BG_COLOR}")
        # Warning banner (font not needed here — use built-in)
        local warn_banner_h=$(( line_h * 2 + PADDING ))
        local warn_y=$(( (image_area_h - warn_banner_h) / 2 ))
        (( warn_y < PADDING / 2 )) && warn_y=$(( PADDING / 2 ))
        local warn_x2=$(( canvas_w - PADDING ))
        local warn_y2=$(( warn_y + warn_banner_h ))
        stage1_args+=(-fill "$WARN_BG_COLOR" -stroke "$WARN_COLOR" -strokewidth 1)
        stage1_args+=(-draw "rectangle ${PADDING},${warn_y} ${warn_x2},${warn_y2}")
        local sym_y=$(( warn_y + PADDING / 2 + FONT_SIZE ))
        stage1_args+=(-pointsize "$FONT_SIZE" -fill "$WARN_COLOR" -stroke none)
        stage1_args+=(-gravity None -annotate "+$(( canvas_w / 2 - FONT_SIZE / 2 ))+${sym_y}" "⚠")
        local msg="Thumbnail could not be generated"
        local msg_w_est=$(( ${#msg} * FONT_SIZE * 6 / 10 ))
        local msg_x=$(( (canvas_w - msg_w_est) / 2 ))
        local msg_y=$(( warn_y + line_h + PADDING / 2 + FONT_SIZE ))
        stage1_args+=(-annotate "+${msg_x}+${msg_y}" "$msg")
    fi

    # Separator line
    stage1_args+=(-stroke "$SEPARATOR_COLOR" -strokewidth 1)
    stage1_args+=(-draw "line ${PADDING},${image_area_h} $(( canvas_w - PADDING )),${image_area_h}")

    magick "${stage1_args[@]}" "$partial_mpc"

    # --- Wait for background tasks -------------------------------------------
    wait "$font_pid"
    local font_path
    font_path=$(cat "$font_file")
    local font_arg=()
    if [[ -n "$font_path" ]]; then
        font_arg=(-font "$font_path")
    fi

    (( meta_pid > 0 )) && wait "$meta_pid"

    # --- Wrap metadata lines -------------------------------------------------
    local chars_per_line=$(( (canvas_w - PADDING * 2) / (FONT_SIZE * 6 / 10) ))
    (( chars_per_line < 20 )) && chars_per_line=20

    local meta_avail_h=$(( text_area_h - PADDING * 2 ))
    local max_lines=0
    if (( meta_avail_h > 0 )); then
        max_lines=$(( meta_avail_h / line_h ))
        (( max_lines < 1 )) && max_lines=1
    fi

    local -a annot_args=()
    local y=$(( image_area_h + PADDING + FONT_SIZE ))
    local line_count=0

    if [[ -s "$meta_file" ]]; then
        while IFS= read -r raw_line; do
            [[ -z "${raw_line// /}" ]] && continue
            while (( ${#raw_line} > chars_per_line )); do
                if (( line_count >= max_lines )); then break 2; fi
                annot_args+=(-annotate "+${PADDING}+${y}" "${raw_line:0:$chars_per_line}")
                raw_line="${raw_line:$chars_per_line}"
                y=$(( y + line_h ))
                line_count=$(( line_count + 1 ))
            done
            if (( line_count >= max_lines )); then break; fi
            annot_args+=(-annotate "+${PADDING}+${y}" "$raw_line")
            y=$(( y + line_h ))
            line_count=$(( line_count + 1 ))
        done < "$meta_file"
    fi

    # --- Stage 2: overlay text + write final PNG (low compression, 8-bit) ----
    # Force 8-bit depth — MPC preserves ImageMagick's default 16-bit HDRI depth,
    # which the kitty graphics protocol cannot decode.
    if (( ${#annot_args[@]} > 0 )); then
        magick "$partial_mpc" \
            "${font_arg[@]}" -pointsize "$FONT_SIZE" -fill "$TEXT_COLOR" -stroke none -gravity None \
            "${annot_args[@]}" \
            -depth 8 -define png:compression-level=1 \
            PNG:"$output_path"
    else
        magick "$partial_mpc" \
            -depth 8 -define png:compression-level=1 \
            PNG:"$output_path"
    fi
}

# --- Media type detection ----------------------------------------------------
detect_media_type() {
    local filepath="$1"
    local mime
    mime=$(file --dereference --brief --mime-type -- "$filepath" 2>/dev/null || true)

    DETECT_THUMB="-"
    DETECT_META_CMD=()

    local tmp_thumb
    tmp_thumb=$(mktmp)

    case "$mime" in
        image/*)
            DETECT_THUMB="$filepath"
            DETECT_META_CMD=(exiftool "$filepath")
            ;;
        video/*)
            if ffmpegthumbnailer -i "$filepath" -o "$tmp_thumb" -s 0 2>/dev/null && [[ -f "$tmp_thumb" ]]; then
                DETECT_THUMB="$tmp_thumb"
            fi
            DETECT_META_CMD=(mediainfo "$filepath")
            ;;
        audio/*)
            if ffmpeg -y -i "$filepath" -map 0:v -map -0:V -c copy "$tmp_thumb" 2>/dev/null && [[ -f "$tmp_thumb" ]]; then
                DETECT_THUMB="$tmp_thumb"
            fi
            DETECT_META_CMD=(mediainfo "$filepath")
            ;;
        application/pdf)
            DETECT_THUMB="$filepath"
            DETECT_META_CMD=(exiftool "$filepath")
            ;;
        *)
            DETECT_THUMB="$filepath"
            DETECT_META_CMD=(exiftool "$filepath")
            ;;
    esac
}

# --- Pretty terminal output --------------------------------------------------
print_metadata_pretty() {
    local media_file="$1"
    local metadata_text="$2"

    local BOLD=$'\033[1m'
    local DIM=$'\033[2m'
    local CYAN=$'\033[36m'
    local YELLOW=$'\033[33m'
    local GREEN=$'\033[32m'
    local RESET=$'\033[0m'

    local cols
    cols=$(tput cols 2>/dev/null || echo 80)

    local border
    printf -v border '%*s' "$cols" ''
    border="${DIM}${border// /─}${RESET}"

    echo
    echo "$border"
    echo "  ${BOLD}${CYAN}📄 $(basename "$media_file")${RESET}"
    echo "  ${DIM}${media_file}${RESET}"
    echo "$border"

    if [[ -z "$metadata_text" ]]; then
        echo "  ${DIM}(no metadata available)${RESET}"
        echo "$border"
        echo
        return
    fi

    while IFS= read -r line; do
        [[ -z "${line// /}" ]] && continue
        if [[ "$line" == *:* ]]; then
            local key="${line%%:*}"
            local value="${line#*:}"
            key="${key#"${key%%[![:space:]]*}"}"
            key="${key%"${key##*[![:space:]]}"}"
            value="${value#"${value%%[![:space:]]*}"}"
            value="${value%"${value##*[![:space:]]}"}"
            printf "  ${YELLOW}%-30s${RESET} ${DIM}:${RESET} ${GREEN}%s${RESET}\n" "$key" "$value"
        else
            echo "  ${BOLD}${line}${RESET}"
        fi
    done <<< "$metadata_text"

    echo "$border"
    echo
}

# --- Main --------------------------------------------------------------------
main() {
    # --- Interactive preview mode ---
    if [[ "${1:-}" == "--preview" ]]; then
        local media_file="${2:-}"
        if [[ -z "$media_file" || ! -f "$media_file" ]]; then
            echo "Error: file not found: ${media_file:-<none>}" >&2
            exit 1
        fi

        local output_path="${3:-}"

        detect_media_type "$media_file"
        local thumb_path="$DETECT_THUMB"
        local meta_cmd=("${DETECT_META_CMD[@]}")

        # Build the composite image
        local tmp_composite=""
        if [[ -z "$output_path" ]]; then
            tmp_composite=$(mktmp)
            output_path="$tmp_composite"
        fi

        create_composite "$thumb_path" "$output_path" 80 40 "${meta_cmd[@]}"

        if command -v chafa &>/dev/null; then
            chafa --animate=off "$output_path"
        else
            local metadata_text=""
            if [[ ${#meta_cmd[@]} -gt 0 ]]; then
                metadata_text=$("${meta_cmd[@]}" 2>/dev/null || true)
            fi
            print_metadata_pretty "$media_file" "$metadata_text"
        fi

        return
    fi

    # --- Ranger mode ---
    if [[ $# -lt 4 ]]; then
        echo "Usage: $0 <image_path> <output_path> <pv_width> <pv_height> [metadata_cmd...]" >&2
        echo "       $0 --preview <media_file> [output_path]" >&2
        exit 1
    fi

    local image_path="$1"
    local output_path="$2"
    local pv_width="$3"
    local pv_height="$4"
    shift 4
    local metadata_cmd=("$@")

    create_composite "$image_path" "$output_path" "$pv_width" "$pv_height" "${metadata_cmd[@]}"
}

main "$@"

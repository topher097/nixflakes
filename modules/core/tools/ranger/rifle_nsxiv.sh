#!/bin/sh
# Compatible with ranger 1.6.0 through 1.9.*
#
# This script searches image files in a directory, opens them all with nsxiv and
# sets the first argument to the first image displayed by nsxiv.
#
# nsxiv is the maintained fork of sxiv:
# https://github.com/nsxiv/nsxiv

TMPDIR="${TMPDIR:-/tmp}"
tmp="$TMPDIR/nsxiv_rifle_$$"

is_img_extension () {
    grep -iE '\.(jpe?g|png|gif|svg|webp|tiff|heif|avif|ico|bmp)$'
}

listfiles () {
    find -L "///${1%/*}" \( ! -path "///${1%/*}" -prune \) -type f -print |
      is_img_extension | sort | tee "$tmp"
}

open_img () {
    if echo "$1" | is_img_extension >/dev/null 2>&1; then
        trap 'rm -f "$tmp"' EXIT
        count="$(listfiles "$1" | grep -nF "$1")"
    fi
    if [ -n "$count" ]; then
        nsxiv -i -n "${count%%:*}" -- < "$tmp"
    else
        nsxiv -- "$@"
    fi
}

[ "$1" = '--' ] && shift
case "$1" in
    "")
        echo "Usage: ${0##*/} PICTURES" >&2
        exit 1
        ;;
    /*) open_img "$1" ;;
    "~"/*) open_img "$HOME/${1#"~"/}" ;;
    *) open_img "$PWD/$1" ;;
esac

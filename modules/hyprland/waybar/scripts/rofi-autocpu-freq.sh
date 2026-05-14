#!/usr/bin/env bash

set -u

if ! command -v rofi >/dev/null 2>&1; then
  notify-send "auto-cpufreq" "rofi is required"
  exit 1
fi

if ! command -v auto-cpufreq >/dev/null 2>&1; then
  notify-send "auto-cpufreq" "auto-cpufreq not found"
  exit 1
fi

current=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null || echo "unknown")

entries=(
  "Auto (reset override)"
  "Powersave (force)"
  "Performance (force)"
)

current_indicator=""
case "$current" in
  powersave)   current_indicator="Powersave" ;;
  performance) current_indicator="Performance" ;;
  *)           current_indicator="$current" ;;
esac

selection=$(printf '%s\n' "${entries[@]}" | rofi -dmenu -i -p "CPU Mode [now: $current_indicator]" -yoffset -100)

[ -z "$selection" ] && exit 0

case "$selection" in
  "Auto (reset override)")
    cmd="sudo auto-cpufreq --force=reset"
    label="Auto mode"
    ;;
  "Powersave (force)")
    cmd="sudo auto-cpufreq --force=powersave"
    label="Powersave mode"
    ;;
  "Performance (force)")
    cmd="sudo auto-cpufreq --force=performance"
    label="Performance mode"
    ;;
  *)
    echo "Unknown selection: $selection" >&2
    exit 1
    ;;
esac

if $cmd; then
  notify-send "auto-cpufreq" "Switched to $label"
else
  notify-send "auto-cpufreq" "Failed to switch to $label"
  exit 1
fi
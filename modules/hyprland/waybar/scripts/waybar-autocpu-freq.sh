#!/usr/bin/env bash

set -u

governor=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null || echo "unknown")

case "$governor" in
  performance)
    icon=$'\uf0e7'
    text="$icon PERF"
    alt="performance"
    class="performance"
    ;;
  powersave)
    icon=$'\uf06c'
    text="$icon SAVE"
    alt="powersave"
    class="powersave"
    ;;
  balanced|schedutil|conservative|ondemand)
    icon=$'\uf24e'
    text="$icon BAL"
    alt="balanced"
    class="balanced"
    ;;
  *)
    icon=$'\uf2db'
    text="$icon $governor"
    alt="$governor"
    class=""
    ;;
esac

printf '{"text":"%s","alt":"%s","tooltip":"CPU governor: %s","class":"%s"}\n' "$text" "$alt" "$governor" "$class"
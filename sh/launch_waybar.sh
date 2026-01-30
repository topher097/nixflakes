#!/usr/bin/env bash

WAYBAR_CONFIG_FILEPATH="$HOME/.config/waybar/config.jsonc"
WAYBAR_STYLE_FILEPATH="$HOME/.config/waybar/style.css"

# Optionally get the arguments for the config and style file to use for the waybar
# -------- Parse args --------
while [[ $# -gt 0 ]]; do
  case "$1" in
    --config)    WAYBAR_CONFIG_FILEPATH=$(realpath -q "$2"); shift 2;;
    --style)     WAYBAR_STYLE_FILEPATH=$(realpath -q "$2"); shift 2;;
    *)
      echo "Unknown arg: $1" >&2
      exit 1
      ;;
  esac
done

# Check if config file exists
if ! [ -f "$WAYBAR_CONFIG_FILEPATH" ]; then
    echo "Config file does not exist or path is invalid: $WAYBAR_CONFIG_FILEPATH"
fi

# Check if style file exists
if ! [ -f "$WAYBAR_STYLE_FILEPATH" ]; then
    echo "Style file does not exist or path is invalid: $WAYBAR_STYLE_FILEPATH"
fi

# Terminate already running bar instances
# If all your bars have ipc enabled, you can use
# polybar-msg cmd quit
# Otherwise you can use the nuclear option:
if pgrep waybar >/dev/null; then
	pkill waybar
fi

# Launch bar1 and bar2
waybar --config=$WAYBAR_CONFIG_FILEPATH --style=$WAYBAR_STYLE_FILEPATH 2>&1 | tee -a /tmp/waybar.log &
disown

echo "Bars launched..."
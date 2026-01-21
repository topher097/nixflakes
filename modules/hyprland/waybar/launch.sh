#!/usr/bin/env bash

# Optionally get the first argument as the config file to use for the waybar
if [ -z "$1" ]; then
    WAYBAR_CONFIG_FILEPATH="$HOME/.config/waybar/config.jsonc"
else
    WAYBAR_CONFIG_FILEPATH=$(realpath -q "$1")
fi

if ! [ -f "$WAYBAR_CONFIG_FILEPATH" ]; then
    echo "Config file does not exist or path is invalid: $WAYBAR_CONFIG_FILEPATH"
fi

# Terminate already running bar instances
# If all your bars have ipc enabled, you can use
# polybar-msg cmd quit
# Otherwise you can use the nuclear option:
if pgrep waybar >/dev/null; then
	pkill waybar
fi

# Launch bar1 and bar2
waybar --config=$WAYBAR_CONFIG_FILEPATH 2>&1 | tee -a /tmp/waybar.log &
disown

echo "Bars launched..."
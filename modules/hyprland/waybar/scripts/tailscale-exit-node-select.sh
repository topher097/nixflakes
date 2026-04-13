#!/usr/bin/env bash

set -u

if ! command -v tailscale >/dev/null 2>&1; then
  notify-send "Tailscale" "tailscale CLI not found"
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  notify-send "Tailscale" "jq is required for exit-node selector"
  exit 1
fi

if ! command -v rofi >/dev/null 2>&1; then
  notify-send "Tailscale" "rofi is required for exit-node selector"
  exit 1
fi

status_json="$(tailscale status --json 2>/dev/null)"
if [ -z "$status_json" ]; then
  notify-send "Tailscale" "Unable to read tailscale status"
  exit 1
fi

mapfile -t nodes < <(
  jq -r '
    [.Peer[]
      | select(.ExitNodeOption == true)
      | {
          dns: ((.DNSName // "") | sub("\\.$"; "")),
          host: (.HostName // ""),
          online: (.Online // false)
        }
      | .key = (if .dns != "" then .dns else .host end)
      | select(.key != "")
      | "\(.key)|\(.online)"
    ]
    | sort
    | .[]
  ' <<<"$status_json"
)

if [ "${#nodes[@]}" -eq 0 ]; then
  notify-send "Tailscale VPN" "No exit nodes available"
  exit 1
fi

menu_entries=("Disable exit node (direct)")
for node in "${nodes[@]}"; do
  key="${node%%|*}"
  online="${node##*|}"
  if [ "$online" = "true" ]; then
    menu_entries+=("${key}")
  else
    menu_entries+=("${key}  [offline]")
  fi
done

selection="$(printf '%s\n' "${menu_entries[@]}" | rofi -dmenu -i -p "Tailscale Exit Node")"

if [ -z "$selection" ]; then
  exit 0
fi

if [ "$selection" = "Disable exit node (direct)" ]; then
  if tailscale set --exit-node= >/dev/null 2>&1; then
    notify-send "Tailscale VPN" "Exit node disabled"
  else
    notify-send "Tailscale VPN" "Failed to disable exit node"
    exit 1
  fi
  exit 0
fi

selected_node="${selection%%  [offline]}"

if tailscale set --exit-node="${selected_node}" --exit-node-allow-lan-access=true >/dev/null 2>&1; then
  notify-send "Tailscale VPN" "Exit node set to ${selected_node}"
else
  notify-send "Tailscale VPN" "Failed to set exit node to ${selected_node}"
  exit 1
fi

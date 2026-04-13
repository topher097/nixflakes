#!/usr/bin/env bash

set -u

if ! command -v tailscale >/dev/null 2>&1; then
  notify-send "Tailscale" "tailscale CLI not found"
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  notify-send "Tailscale" "jq is required for toggle script"
  exit 1
fi

prefs_json="$(tailscale debug prefs 2>/dev/null)"
if [ -z "$prefs_json" ]; then
  notify-send "Tailscale" "Unable to read tailscale prefs"
  exit 1
fi

status_json="$(tailscale status --json 2>/dev/null || echo '{}')"
active_exit_id="$(jq -r '.ExitNodeStatus.ID // ""' <<<"$status_json")"

if [ -n "$active_exit_id" ]; then
  if tailscale set --exit-node= >/dev/null 2>&1; then
    notify-send "Tailscale VPN" "Exit node disabled (direct mode)"
  else
    notify-send "Tailscale VPN" "Failed to disable exit node"
    exit 1
  fi
  exit 0
fi

suggested_line="$(tailscale exit-node suggest 2>/dev/null | head -n 1)"
suggested_node=""
if [[ "$suggested_line" =~ Suggested[[:space:]]exit[[:space:]]node:[[:space:]]([^[:space:]]+) ]]; then
  suggested_node="${BASH_REMATCH[1]}"
fi

# tailscale CLI prints a trailing dot for FQDNs; keep host valid for --exit-node.
suggested_node="${suggested_node%.}"

if [ -n "$suggested_node" ]; then
  enable_cmd=(tailscale set --exit-node="${suggested_node}" --exit-node-allow-lan-access=true)
else
  enable_cmd=(tailscale set --exit-node=auto:any --exit-node-allow-lan-access=true)
fi

if "${enable_cmd[@]}" >/dev/null 2>&1; then
  status_after="$(tailscale status --json 2>/dev/null || echo '{}')"
  active_name="$(jq -r 'first(.Peer[]? | select(.ExitNode == true) | (.DNSName // .HostName // "")) // ""' <<<"$status_after")"
  active_name="${active_name%.}"

  if [ -n "$active_name" ]; then
    notify-send "Tailscale VPN" "Exit node enabled\n${active_name}"
  else
    notify-send "Tailscale VPN" "Exit node requested; waiting for active connection"
  fi
else
  notify-send "Tailscale VPN" "Failed to enable exit node"
  exit 1
fi

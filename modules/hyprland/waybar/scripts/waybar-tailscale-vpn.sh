#!/usr/bin/env bash

set -u

if ! command -v tailscale >/dev/null 2>&1; then
  echo '{"text":"󰖪 TS n/a","class":"disconnected","tooltip":"tailscale CLI is not installed"}'
  exit 0
fi

if ! command -v jq >/dev/null 2>&1; then
  echo '{"text":"󰦝 TS","class":"degraded","tooltip":"jq is required for tailscale status parsing"}'
  exit 0
fi

status_json="$(tailscale status --json 2>/dev/null)"
status_rc=$?
if [ "$status_rc" -ne 0 ] || [ -z "$status_json" ]; then
  echo '{"text":"󰖪 TS off","class":"disconnected","tooltip":"tailscaled is not reachable"}'
  exit 0
fi

prefs_json="$(tailscale debug prefs 2>/dev/null || echo '{}')"

backend_state="$(jq -r '.BackendState // "Unknown"' <<<"$status_json")"
online="$(jq -r '.Self.Online // false' <<<"$status_json")"
tailnet="$(jq -r '.CurrentTailnet.Name // .MagicDNSSuffix // "unknown"' <<<"$status_json")"
ts_ip="$(jq -r '.Self.TailscaleIPs[0] // "n/a"' <<<"$status_json")"

route_all="$(jq -r '.RouteAll // false' <<<"$prefs_json")"
exit_node_allow_lan="$(jq -r '.ExitNodeAllowLANAccess // false' <<<"$prefs_json")"
exit_node_id="$(jq -r '.ExitNodeID // ""' <<<"$prefs_json")"
exit_node_ip="$(jq -r '.ExitNodeIP // ""' <<<"$prefs_json")"

active_exit_id="$(jq -r '.ExitNodeStatus.ID // ""' <<<"$status_json")"
active_exit_online="$(jq -r '.ExitNodeStatus.Online // false' <<<"$status_json")"
active_exit_name="$(jq -r 'first(.Peer[]? | select(.ExitNode == true) | (.DNSName // .HostName // "")) // ""' <<<"$status_json")"
active_exit_name="${active_exit_name%.}"
active_exit_short="${active_exit_name%.mullvad.ts.net}"
active_exit_is_mullvad="false"
if [[ "$active_exit_name" == *"mullvad.ts.net"* ]]; then
  active_exit_is_mullvad="true"
fi

health_count="$(jq -r '(.Health // []) | length' <<<"$status_json")"
health_text="$(jq -r '(.Health // [])[0:3] | join("\n")' <<<"$status_json")"

exit_node_host=""
if [ -n "$exit_node_id" ]; then
  exit_node_host="$(jq -r --arg id "$exit_node_id" 'first(.Peer[]? | select(.ID == $id) | (.HostName // .DNSName // ""))' <<<"$status_json")"
fi

if [ -z "$exit_node_host" ] && [ -n "$exit_node_ip" ]; then
  exit_node_host="$(jq -r --arg ip "$exit_node_ip" 'first(.Peer[]? | select((.TailscaleIPs // []) | index($ip)) | (.HostName // .DNSName // ""))' <<<"$status_json")"
fi

if [ -n "$exit_node_host" ]; then
  exit_node_host="${exit_node_host%.}"
fi

icon=""
label=""
cr=$'\r'

if [ "$backend_state" != "Running" ] || [ "$online" != "true" ]; then
  class="disconnected"
  icon=$'\uf127'
  label="TS off"
  vpn_line="VPN: unavailable"
elif [ -n "$active_exit_id" ]; then
  class="vpn"
  vpn_target="${active_exit_name:-${exit_node_host:-${exit_node_ip:-unknown}}}"
  vpn_target_short="${active_exit_short:-$vpn_target}"
  icon=$'\uf023'
  label="${vpn_target_short}"
  vpn_line="VPN: ON via ${vpn_target} (online=${active_exit_online})"
  if [ "$active_exit_is_mullvad" != "true" ]; then
    class="degraded"
    icon=$'\uf071'
    label="TS non-Mullvad"
    vpn_line="VPN: ON via non-Mullvad exit node (${vpn_target})"
  fi
elif [ -n "$exit_node_id" ]; then
  class="degraded"
  icon=$'\uf252'
  label="TS exit pending"
  vpn_line="VPN: exit node requested but not active"
else
  class="direct"
  icon=$'\uf0c1'
  label="TS direct"
  vpn_line="VPN: OFF (no exit node configured)"
fi

if [ "$health_count" -gt 0 ] && [ "$class" != "disconnected" ]; then
  icon=$'\uf071'
  label="TS warn"
  class="degraded"
fi

text="${icon} ${label}"

tooltip="<b>Tailscale Status</b>${cr}"
tooltip+="State: ${backend_state}${cr}"
tooltip+="Online: ${online}${cr}"
tooltip+="Tailnet: ${tailnet}${cr}"
tooltip+="IP: ${ts_ip}${cr}"
tooltip+="${vpn_line}${cr}"
tooltip+="Configured ExitNodeID: ${exit_node_id:-none}${cr}"
tooltip+="Exit-node LAN access: ${exit_node_allow_lan}"

if [ "$health_count" -gt 0 ]; then
  health_text="${health_text//$'\n'/$cr}"
  tooltip+="${cr}${cr}<b>Health</b>${cr}${health_text}"
fi

jq -cn \
  --arg text "$text" \
  --arg class "$class" \
  --arg tooltip "$tooltip" \
  '{text: $text, class: $class, tooltip: $tooltip}'

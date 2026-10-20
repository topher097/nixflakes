#!/usr/bin/env bash

set -u

# Output tomat status as waybar JSON. If the daemon is not running, show an
# offline state instead of spamming "Failed to connect to daemon" errors.
status_json="$(tomat status 2>/dev/null)"

if [ -z "$status_json" ]; then
  echo '{"text":"\u23f1 OFF","class":"offline","tooltip":"Tomat daemon not running"}'
  exit 0
fi

echo "$status_json"

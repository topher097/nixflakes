systemctl --user stop ghostty.service 2>/dev/null || true
systemctl --user disable ghostty.service 2>/dev/null || true
pkill -f ghostty-1.2.1 || true
# More thorough:
for pid in $(pgrep -f ghostty); do
  if readlink -f "/proc/$pid/exe" 2>/dev/null | grep -q 'ghostty-1\.2\.1'; then
    kill -9 "$pid"
  fi
done

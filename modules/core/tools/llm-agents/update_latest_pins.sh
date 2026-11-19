#!/usr/bin/env bash
# Refresh the plugin version pins in opencode.json to the latest version
# published on npm.
#
# Usage: modules/core/tools/llm-agents/update_latest_pins.sh
# Rebuild the machine afterwards to roll the new pins out.
set -euo pipefail

config_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
config="$config_dir/opencode.json"

for tool in jq npm; do
  command -v "$tool" >/dev/null || {
    echo "missing required tool: $tool" >&2
    exit 1
  }
done

if ! jq -e '.plugins | type == "array"' "$config" >/dev/null; then
  echo "$config has no plugins array" >&2
  exit 1
fi

trap 'rm -f "$config.tmp"' EXIT

# Package name of a plugin spec: everything before the @version part.
# "@scope/name@1.2.3" -> "@scope/name", "name@1.2.3" -> "name".
spec_package() {
  local spec="$1" pkg="${1%@*}"
  if [[ -z "$pkg" || "$pkg" == "$spec" ]]; then pkg="$spec"; fi
  printf '%s' "$pkg"
}

pins=()
changed=0

while IFS= read -r spec; do
  pkg="$(spec_package "$spec")"

  # Local plugins are paths, not npm packages.
  case "$pkg" in
    /* | .*)
      echo "skip $pkg: not an npm package"
      continue
      ;;
  esac

  latest="$(npm view "$pkg" version --silent 2>/dev/null | tail -n 1 || true)"
  if [[ -z "$latest" ]]; then
    echo "skip $pkg: no version published on npm" >&2
    continue
  fi

  current="${spec#"$pkg"}"
  current="${current#@}"

  if [[ "$current" == "$latest" ]]; then
    echo "keep $pkg@$latest"
    continue
  fi

  pins+=("$pkg" "$pkg@$latest")
  echo "bump $pkg@${current:-<unpinned>} -> $pkg@$latest"
  changed=1
done < <(jq -r '.plugins[] | select(type == "string")' "$config")

if ((changed == 0)); then
  echo "opencode.json already pins the latest plugin versions"
  exit 0
fi

pins_json="$(jq -n --args '$ARGS.positional as $a | ($a | length) as $n | reduce range(0; $n; 2) as $i ({}; .[$a[$i]] = $a[$i + 1])' "${pins[@]}")"

jq --argjson pins "$pins_json" '
  .plugins |= map(
    . as $s
    | if ($s | type) == "string" then
        ([ $pins | to_entries[]
            | . as $e
            | select($s == $e.key or ($s | startswith($e.key + "@")))
            | $e.value ][0] // $s)
      else $s end
  )
' "$config" >"$config.tmp"

mv "$config.tmp" "$config"
echo "updated $config"

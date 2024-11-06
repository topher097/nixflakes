switch:
    sudo nixos-rebuild switch --flake . --show-trace

test:
    sudo nixos-rebuild test --flake . --show-trace

# cachix-push:
#     nix build --json | jq -r '.[].outputs | to_entries[].value' | cachix push topher097

lockfile-pin:
    git add flake.lock
    git commit -m "pin: update flake.lock"
    git push

windows-11:
    quickget windows 11 English
    quickemu --ignore-msrs-always
    quickemu --vm windows-11-English.conf

gadd:
    git add .
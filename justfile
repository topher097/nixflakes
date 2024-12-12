switch:
    sudo nixos-rebuild switch --flake . --show-trace

test:
    sudo nixos-rebuild test --flake . --show-trace

wsl-test:
    sudo nixos-rebuild test --flake .#winix --show-trace

wsl-switch:
    sudo nixos-rebuild switch --flake .#winix --show-trace

update:
    sudo nix-channel --update

# cachix-push:
#     nix build --json | jq -r '.[].outputs | to_entries[].value' | cachix push topher097

lockfile-pin:
    git add flake.lock
    git commit -m "pin: update flake.lock"
    git push

gadd:
    git add .

# https://nix.dev/manual/nix/2.18/package-management/garbage-collection
gc:
    nix-env --delete-generations old
    nix-store --gc
    nix-collect-garbage -d
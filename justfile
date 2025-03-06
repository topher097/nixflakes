user := file_stem(home_directory())

# Own the current directory as the logged in user
own:
    sudo chown -R {{ user }} .

# Set the remote URL for the git repository, useful if the repository is moved to a different location
set-remote:
    git remote set-url origin git@github.com:topher097/nixflakes.git

switch:
    sudo nixos-rebuild switch --flake . --show-trace

test:
    sudo nixos-rebuild test --flake . --show-trace

vm:
    nixos-rebuild build-vm --flake . 
    ./result/bin/run-nixos-vm
    trash put result nixos.qcow2"

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
    nix-collect-garbage --delete-old
    devenv gc

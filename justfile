user := file_stem(home_directory())

# Own the current directory as the logged in user
own:
    sudo chown -R {{ user }} .

# Set the remote URL for the git repository, useful if the repository is moved to a different location
set-remote:
    git remote set-url origin git@github.com:topher097/nixflakes.git

# Reload the waybar with config and style file from repo
waybar:
    bash sh/launch_waybar.sh --config ./modules/hyprland/waybar/config.jsonc --style ./modules/hyprland/waybar/style.css

# NixOS flake test
test:
    sudo nixos-rebuild test --flake . --show-trace
    hyprctl reload
    bash sh/launch_waybar.sh

# NixOS flake
switch:
    sudo nixos-rebuild switch --flake . --show-trace

# NixOS flake build (without switching or adding to GRUB menu)
build:
    sudo nixos-rebuild build --flake . --show-trace

# NixOS flake test when in WSL
wsl-test:
    sudo nixos-rebuild test --flake .#winix --show-trace

# NixOS flake switch when in WSL
wsl-switch:
    sudo nixos-rebuild switch --flake .#winix --show-trace

# Update the flake inputs and the nix channel
update:
    sudo nix-channel --update
    sudo nix flake update

# Pin the lockfile to the current inputs
lockfile-pin:
    git add flake.lock
    git commit -m "pin: update flake.lock"
    git push

# Upgrade the inputs and update the lockfile
upgrade: update test lockfile-pin

# Add all changes to the git repository
gadd:
    git add .

# https://nix.dev/manual/nix/2.18/package-management/garbage-collection
gc:
    nix-env --delete-generations old --profile /nix/var/nix/profiles/system
    nix-store --gc
    nix store gc
    nix-store --optimise
    nix-collect-garbage --delete-old
    devenv gc

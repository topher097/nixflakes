{ home-manager, nixpkgs, pkgs, ... }:
{
  imports = [
    home-manager.nixosModules.home-manager
    { nix.registry.nixpkgs.flake = nixpkgs; }
    ./hosts
    ./modules/core/terminal
    ./modules/core/nix
  ];

  # https://nix-community.github.io/NixOS-WSL/how-to/vscode.html
  environment.systemPackages = [
    pkgs.wget
  ];

  programs.nix-ld = {
    enable = true;
    package = pkgs.nix-ld-rs;
  };

}

{ pkgs, home-manager, user, host, ... }:
{
  imports = [
    home-manager.nixosModules.default
  ];

  home-manager.users.${user} = { pkgs, ... }: {
    /* The home.stateVersion option does not have a default and must be set */
    home.stateVersion = "23.05";
    nixpkgs.config.allowUnfree = true;
  };

  # ---- System Configurations ---   
  # Enable networking - available with nmcli and nmtui
  networking = {
    hostName = "${host}";
  }; 
}
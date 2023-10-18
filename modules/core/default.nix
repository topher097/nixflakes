{ pkgs, home-manager, user, host, ... }:
let
  corePackages = import ./pkgs/core { inherit  pkgs; };
  devPackages = import ./pkgs/dev { inherit pkgs; };
in
{ 
  imports = [
    ../../users/${user}
    ../../hosts/${host}/home
    ./terminal
    ./browsing
    ./obs
    ./security
    ./vscode
  ];

  home-manager.users.${user} = { pkgs, ... }: {
    home.packages = with pkgs; [
      obsidian
      discord
     ];
    programs.gh.enable = true;
  };

  services.gnome.gnome-keyring.enable = true;
  
  # Enable Flakes and nix-commands
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
          
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Bootloader.
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Meshnet
  # services.tailscale.enable = true;

  # Enable networking - available with nmcli and nmtui
  networking = {
    networkmanager.enable = true;
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
   
  # Set your time zone.
  time.timeZone = "America/Toronto";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_CA.UTF-8";
    
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  environment.systemPackages = corePackages ++ devPackages;
  
  # Dont change.
  system.stateVersion = "23.05"; # Did you read the comment?
}
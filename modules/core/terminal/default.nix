{ pkgs, username, ... }:
{
  imports = [
    ./alacritty
    ./cava
    ./fonts
    ./fish
    #./foot
    ./wezterm
    ./starship
    ./tmux
    #./yazi
    ./zsh
    ./bash
    ./lazygit
    ./nvim
  ];

  # ---- Home Configuration ----
  home-manager.users.${username} = {
    programs.git.enable = true;
  };

  # ---- System Configuration ----
  programs = {
    htop.enable = true;
    mtr.enable = true;
  };

  # Allow members of the "wheel" group to sudo:
  security.sudo.enable =  true;
  security.sudo.configFile = ''
    %wheel ALL=(ALL) ALL
  '';

  environment.systemPackages = with pkgs; [
    alacritty
    brightnessctl
    btop
    gh
    mods
    nitch
    pavucontrol
    playerctl
    ripgrep
    todoist
    unzip
    vhs
    zoxide
    fzf
    tree
    wget
    eza
    unstable.devenv
    cachix
    wget
    service-wrapper
    just
  ];
}

{ pkgs, username, ... }:
{
  imports = [
    ./alacritty
    ./bash
    ./fish
    ./ghostty
    ./tmux
    ./wezterm
    ./zsh
  ];

  # Allow members of the "wheel" group to sudo:
  security.sudo.enable =  true;
  security.sudo.configFile = ''
    %wheel ALL=(ALL) ALL
  '';

}

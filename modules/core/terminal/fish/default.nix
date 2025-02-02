{ pkgs, ... }:
{

  # ---- System Configuration ----
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting
      ${pkgs.zoxide}/bin/zoxide init fish | source
    '';
  };
}

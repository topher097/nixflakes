{ pkgs, ... }:
{

  # ---- System Configuration ----
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting
      ${pkgs.zoxide}/bin/zoxide init fish | source
      export EZA_COLORS='da=1;34:gm=1;34:Su=1;34'
      nitch
    '';
  };
}

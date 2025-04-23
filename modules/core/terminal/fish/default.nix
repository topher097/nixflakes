{ pkgs,
  home-manager,
  username,
 ...
}: {

  # ---- System Configuration ----
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting
      ${pkgs.starship}/bin/starship init fish | source
      ${pkgs.zoxide}/bin/zoxide init fish | source
      export EZA_COLORS='da=1;34:gm=1;34:Su=1;34'
      
      if test "$TERM_PROGRAM" = "ghostty"
        set -x TERM xterm-256color
      end

      nitch
    '';
  };
}

{ pkgs, ... }:
{

  # ---- System Configuration ----
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting
      ${pkgs.zoxide}/bin/zoxide init fish | source
      export EZA_COLORS='da=1;34:gm=1;34:Su=1;34'
      ${pkgs.any-nix-shell}/bin/any-nix-shell fish --info-right | source
      
      if [[ "$TERM_PROGRAM" == "ghostty" ]]; then
        export TERM=xterm-256color
      fi

      nitch
    '';
  };
}

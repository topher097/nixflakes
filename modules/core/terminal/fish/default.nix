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

      if not set -q SSH_AUTH_SOCK
        if not set -q PRIVATE_SSH_PATH
          echo "SSH_AUTH_SOCK not set, and no PRIVATE_SSH_PATH found for SSH access."
        else
          eval (ssh-agent -c)
          ssh-add "$PRIVATE_SSH_PATH"
        end
      end

      nitch
    '';
  };
}

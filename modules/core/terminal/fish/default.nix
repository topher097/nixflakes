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
      
      # Automatically set the TERM variable to xterm-256color if using ghostty
      if test "$TERM_PROGRAM" = "ghostty"
        set -x TERM xterm-256color
      end

      # Automatically set the SSH_AUTH_SOCK variable if using ssh-agent and not set
      if not set -q SSH_AUTH_SOCK
        if not set -q PRIVATE_SSH_PATH
          echo "SSH_AUTH_SOCK not set, and no PRIVATE_SSH_PATH found for SSH access."
        else
          eval (ssh-agent -c)
          ssh-add "$PRIVATE_SSH_PATH"
        end
      end

      # Function to load direnv changes and start a new shell
      function direnv_load_and_start_new_shell
        set -l direnv_output (direnv export fish)
        if test -n "$direnv_output"
          eval $direnv_output
          exec fish
        end
      end

      # Wrap the built-in cd command
      function cd --wraps cd
        builtin cd $argv
        direnv_load_and_start_new_shell
      end

      # Wrap Zoxide's z command
      function z
        set -l dir (${pkgs.zoxide}/bin/zoxide query $argv)
        if test $status -eq 0
          builtin cd $dir
          direnv_load_and_start_new_shell
        end
      end

      # Wrap Zoxide's zi command (interactive mode)
      function zi
        set -l dir (${pkgs.zoxide}/bin/zoxide query -i $argv)
        if test $status -eq 0
          builtin cd $dir
          direnv_load_and_start_new_shell
        end
      end

      # https://direnv.net/docs/hook.html#fish
      # direnv hook fish | source

      eval (direnv hook fish)

      nitch
    '';
  };
}

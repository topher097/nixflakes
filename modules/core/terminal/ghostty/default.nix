# Reference LINK: https://nix-community.github.io/home-manager/options.xhtml#opt-programs.ghostty.enable
{
  pkgs,
  home-manager,
  username,
  ...
}: {

  home-manager.users.${username} = {
    programs.ghostty = {
      enable = true;
      #package = pkgs.unstable.ghostty;  
      enableFishIntegration = true;
      installVimSyntax = true;

      settings = {
        # Keep Ghostty's native TERM value.
        #
        # Forcing TERM=xterm-kitty can break ncurses consumers when the kitty
        # terminfo entry is not installed in the runtime environment, leading to
        # errors like:
        #   _curses.error: setupterm: could not find terminal
        #
        # Ghostty ships xterm-ghostty terminfo and sets TERM accordingly.
        term = "xterm-ghostty";

        # Keybindings
        keybind = [
          "ctrl+shift+h=goto_split:left"
          "ctrl+shift+l=goto_split:right"
          "ctrl+shift+j=goto_split:bottom"
          "ctrl+shift+k=goto_split:top"
        ];
      };
    };
  };
}

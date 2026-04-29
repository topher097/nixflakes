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
        font-size = 11;
        term = "xterm-ghostty";

        # Keybindings
        keybind = [
          "ctrl+shift+h=goto_split:left"
          "ctrl+shift:l=goto_split:right"
          "ctrl+shift=j=goto_split:down"
          "ctrl+shift+k=goto_split:up"
        ];
      };
    };
  };
}

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
      package = pkgs.ghostty;  # Use stable version (1.2.3) instead of unstable (1.3.x with kitty protocol bug)
      enableFishIntegration = true;
      installVimSyntax = true;

      settings = {
        # Use xterm-kitty so ranger's kitty graphics protocol probe succeeds.
        # Ghostty supports the protocol but its probe response (EINVAL) is not
        # handled by ranger, which only expects OK or EBADF.
        term = "xterm-kitty";

        # Keybindings
        keybind = [
          "ctrl+shift+h=goto_split:left"
          "ctrl+shift+l=goto_split:right"
          "ctrl+shift+j=goto_split:bottom"
          "ctrl+shift+k=goto_split:top"
        ];
      };
    };
    
    #programs.vim.plugins = [ghostty.vim];
  };
}
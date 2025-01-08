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
      package = pkgs.unstable.ghostty;
      enableFishIntegration = true;
      installVimSyntax = true;

      # settings = {
      #   background-blur-radius = 20;
      #   #theme = "dark:catppuccin-mocha,light:catppuccin-latte";
      #   #window-theme = "dark";
      #   #window-theme = "system"; # TODO make vim and terminal somehow respect this?
      #   background-opacity = 0.8;
      #   minimum-contrast = 1.1;

      #   # # Keybindings
      #   # keybind = [
      #   #   "global:ctrl+shift+`=toggle_quick_terminal"
      #   # ];
      # };
    };
    
    #programs.vim.plugins = [ghostty.vim];
  };
}
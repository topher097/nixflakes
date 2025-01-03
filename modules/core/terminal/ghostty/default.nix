{
  config,
  lib,
  pkgs,
  attrs,
  home-manager,
  username,
  ...
}: {
  home-manager.sharedModules = [
    attrs.ghostty.homeModules.default
  ];

  home-manager.users.${username} = _: {
    programs.ghostty = {
      enable = true;
      package = pkgs.unstable.ghostty;
      shellIntegration.enable = true;

      settings = {
        background-blur-radius = 20;
        theme = "dark:catppuccin-mocha,light:catppuccin-latte";
        window-theme = "dark";
        #window-theme = "system"; # TODO make vim and terminal somehow respect this?
        background-opacity = 0.8;
        minimum-contrast = 1.1;
      };

      keybindings = {
        # keybind = global:ctrl+`=toggle_quick_terminal
        "global:ctrl+`" = "toggle_quick_terminal";
      };
    };
  };


  # home-manager.users.${username} = _: {
  #   home.file = {
  #     ".config/wezterm/wezterm.lua".source = ./wezterm.lua;
  #   };
  # };
}
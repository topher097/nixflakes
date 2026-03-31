{ config, stylix, pkgs, lib, username, ... }:
{
  imports = [ stylix.nixosModules.stylix ];

  stylix = {
    enable = true;
    image = ../../assets/backgrounds/moon.jpg;
    polarity = "dark";

    targets.qt.platform = lib.mkForce "qtct";

    # Can set a custom theme. Find them here: https://tinted-theming.github.io/tinted-gallery/
    base16Scheme = "${pkgs.base16-schemes}/share/themes/rose-pine-moon.yaml";

    # Stylix will automatically enable most targets (or at least try to)
    autoEnable = true;

    # Disable checks for release build number not matching NixOS version
    #enableReleaseChecks = false;

    fonts = {
      serif = {
        package = pkgs.ibm-plex;
        name = "IBM Plex Serif";
      };

      sansSerif = {
        package = pkgs.ibm-plex;
        name = "IBM Plex Sans";
      };

      monospace = {
        package = pkgs.ibm-plex;
        name = "IBM Plex Mono";
      };

      emoji = {
        package = pkgs.noto-fonts-color-emoji;
        name = "Noto Color Emoji";
      };
    };
  };

  home-manager.users.${username}.xresources.properties = {
    # nsxiv uses the Nsxiv Xresources class (not Sxiv).
    "Nsxiv.window.background" = lib.mkForce config.lib.stylix.colors.withHashtag.base00;
    "Nsxiv.window.foreground" = lib.mkForce config.lib.stylix.colors.withHashtag.base05;
  };
}

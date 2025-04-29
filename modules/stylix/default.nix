{ stylix, pkgs, ... }:
{
  imports = [ stylix.nixosModules.stylix ];

  stylix = {
    enable = true;
    image = ../../assets/backgrounds/moon.jpg;
    polarity = "dark";

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
        package = pkgs.noto-fonts-emoji;
        name = "Noto Color Emoji";
      };
    };
  };
}

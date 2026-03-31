{
  pkgs,
  username,
  ...
}:
{
  home-manager.users.${username} = {
    # References used for this setup:
    # - Home Manager xplr module: https://github.com/nix-community/home-manager/blob/master/modules/programs/xplr.nix
    # - xplr configuration docs: https://xplr.dev/en/configuration
    # - xplr awesome plugins: https://xplr.dev/en/awesome-plugins
    # - xplr "Text preview pane" hack pattern: https://xplr.dev/en/awesome-hacks
    # - Ghostty TERM and image protocol behavior: https://ghostty.org/docs/help/terminfo and
    #   https://ghostty.org/docs/features
    programs.xplr = {
      enable = true;
      extraConfig = builtins.readFile ./init.lua;
    };

    # Runtime preview dependencies used by preview.sh.
    home.packages = with pkgs; [
      bat
      chafa
      coreutils
      ffmpegthumbnailer
      file
      libarchive
      mediainfo
      p7zip
      poppler-utils
      tree
      wl-clipboard
    ];

    # Keep helper scripts in dedicated files, similar to ranger module layout.
    home.file = {
      ".config/xplr/preview.sh".source = ./preview.sh;
    };
  };
}

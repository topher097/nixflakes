{
  pkgs,
  username,
  ...
}:
{
  home-manager.users.${username} = {
    programs.ranger = {
      enable = true;

      extraPackages = with pkgs; [
        # Image previews
        python3Packages.pillow
        w3m
        chafa # In-pane image previews in scope.sh
        imagemagick # convert, identify for image rotation
        librsvg # rsvg-convert for SVG previews
        # Maintained fork of sxiv: https://github.com/nsxiv/nsxiv
        nsxiv # X11 image viewer used by rifle for image browsing

        # Video/audio previews
        ffmpegthumbnailer # Video thumbnails
        ffmpeg-full # Embedded thumbnails from video/audio
        mediainfo # Media file info
        exiftool # EXIF metadata

        # Document previews
        poppler-utils # pdftotext, pdftoppm for PDF
        djvulibre # ddjvu, djvutxt for DjVu
        odt2txt # OpenDocument text
        pandoc # Document conversion
        catdoc # RTF/DOC/XLS preview

        # Code/text previews
        bat # Syntax highlighting
        highlight # Syntax highlighting fallback
        python3Packages.pygments # pygmentize fallback
        file # MIME type detection

        # Archive previews
        atool # Archive listing/extraction
        libarchive # bsdtar
        unrar # RAR archives
        p7zip # 7z archives

        # Data previews
        jq # JSON
        sqlite # SQLite databases

        # Misc
        lynx # HTML preview fallback
        transmission_4 # BitTorrent info
      ];

      # Enable file preview
      settings = {
        preview_files = true;
        preview_directories = true;
        preview_images = true;
        # GHOSTTY LIMITATIONS - RANGER IN-PANE IMAGE PROTOCOLS ARE UNRELIABLE:
        # 
        # Ghostty 1.3.x has multiple open ranger compatibility issues:
        # - Kitty image protocol probe can return EINVAL, which ranger rejects
        #   https://github.com/ranger/ranger/issues/3203
        # - Sixel: Not supported by Ghostty (by design)
        #   https://github.com/ghostty-org/ghostty/discussions/2496
        # - w3m: Requires X11, incompatible with Ghostty
        # - ueberzug: Requires X11/Wayland overlay, not compatible
        # 
        # WORKAROUND: Keep preview_images disabled and use scope.sh text previews.
        # For actual image viewing, rifle launches nsxiv in a GUI window.
        open_all_images = true;
        use_preview_script = false;
        preview_script = "$HOME/.config/ranger/scope.sh";
        preview_images_method = "kitty";
      };
    };

    # Ensure ranger's preview dependencies are on PATH at runtime.
    # extraPackages only adds them as propagatedBuildInputs (build-time),
    # which does NOT put them on the user's PATH.
    home.packages = with pkgs; [
      # Image display tools
      imagemagick
      w3m # w3mimgdisplay for image rendering in terminal
      chafa # in-pane image previews (ANSI)
      nsxiv # ranger image opener for Ghostty sessions
      
      # Metadata/info tools
      exiftool
      mediainfo
      
      # Video/audio/document
      ffmpegthumbnailer
      ffmpeg-full
      poppler-utils
      
      # Code/text
      bat
      highlight
      
      # File/font detection
      file
      
      # Archives
      atool
      libarchive
      unrar
      p7zip
    ];

    # Copy ranger command scripts and config files to home directory
    home.file = {
      ".config/ranger/scope.sh".source = ./scope.sh;
      ".config/ranger/rifle_nsxiv.sh".source = ./rifle_nsxiv.sh;
      ".config/ranger/commands.py".source = ./commands.py;
      ".config/ranger/commands_full.py".source = ./commands_full.py;
      ".config/ranger/rifle.conf".source = ./rifle.conf;
    };
  };
}

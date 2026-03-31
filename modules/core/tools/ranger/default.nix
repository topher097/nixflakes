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
        imagemagick # convert, identify for image rotation
        librsvg # rsvg-convert for SVG previews

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
        fontconfig # fc-match for composite preview font discovery
        chafa # Terminal image rendering for composite previews
      ];

      # Enable file preview
      settings = {
        preview_files = true;
        preview_directories = true;
        preview_images = false;
        # GHOSTTY LIMITATIONS - IMAGE PROTOCOLS CURRENTLY UNRELIABLE:
        # 
        # Ghostty 1.3.x has multiple open ranger compatibility issues:
        # - Kitty image protocol probe can return EINVAL, which ranger rejects
        #   https://github.com/ranger/ranger/issues/3203
        # - Sixel: Not supported by Ghostty (by design)
        #   https://github.com/ghostty-org/ghostty/discussions/2496
        # - w3m: Requires X11, incompatible with Ghostty
        # - ueberzug: Requires X11/Wayland overlay, not compatible
        # 
        # WORKAROUND: Disable preview_images and use scope.sh with chafa/text.
        # The composite script still generates
        # PNG files cached to ~/.cache/preview_composite/ for reference.
        use_preview_script = true;
        preview_script = "$HOME/.config/ranger/scope.sh";
        #preview_script = "${./scope.sh}";
      };
    };

    # Ensure ranger's preview dependencies are on PATH at runtime.
    # extraPackages only adds them as propagatedBuildInputs (build-time),
    # which does NOT put them on the user's PATH.
    home.packages = with pkgs; [
      # Image display tools (multiple options for compatibility)
      imagemagick
      w3m # w3mimgdisplay for image rendering in terminal
      chafa # terminal image rendering
      viu # another image viewer option
      
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
      fontconfig
      
      # Archives
      atool
      libarchive
      unrar
      p7zip
    ];

    # Copy ranger command scripts and config files to home directory
    home.file = {
      ".config/ranger/scope.sh".source = ./scope.sh;
      ".config/ranger/preview_composite.sh".source = ./preview_composite.sh;
      ".config/ranger/commands.py".source = ./commands.py;
      ".config/ranger/commands_full.py".source = ./commands_full.py;
      ".config/ranger/rifle.conf".source = ./rifle.conf;
    };
  };
}

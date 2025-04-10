{
  pkgs,
  home-manager,
  username,
  lib,
  ...
}:
let
  gnomeExtensionsList = with pkgs.gnomeExtensions; [
    user-themes
    #blur-my-shell
    #pano
    desktop-cube
    desktop-clock
    # pop-shell
    vitals
    docker
    unblank
    custom-accent-colors
    tailscale-qs
    tailscale-status
    forge   # Tiling manager
  ];
in
{
  environment.systemPackages = with pkgs; [ 
    #nordic
  ];

  # ---- Home Configuration ----
  home-manager.users.${username} = {

    # gtk.theme = lib.mkForce {
    #     name = "Nordic";
    #     package = pkgs.nordic;
    # };

    home.pointerCursor = lib.mkForce {
      gtk.enable = true;
      x11.enable = true;
      #name = "Bibata";
      #package = pkgs.bibata-cursors;
      #size = 20;
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
      size = 24;
    };

    home.packages = gnomeExtensionsList;

    dconf.settings = {
      "org/gnome/shell".enabled-extensions =
        (map (extension: extension.extensionUuid) gnomeExtensionsList)
        ++ [
          "auto-move-windows@gnome-shell-extensions.gcampax.github.com"
          "window-list@gnome-shell-extensions.gcampax.github.com"
          "places-menu@gnome-shell-extensions.gcampax.github.com"
          "workspace-indicator@gnome-shell-extensions.gcampax.github.com"
          "apps-menu@gnome-shell-extensions.gcampax.github.com"
          "window-navigator@gnome-shell-extensions.gcampax.github.com"
          "launch-new-instance@gnome-shell-extensions.gcampax.github.com"
          #"native-window-placement@gnome-shell-extensions.gcampax.github.com"
          "user-theme@gnome-shell-extensions.gcampax.github.com"
        ];

      "org/gnome/shell".disabled-extensions = [ ];

      "org/gnome/shell".favorite-apps = [
        "firefox.desktop"
        "code.desktop"
        "vesktop.desktop"
        #"virt-manager.desktop"
        "ghostty.desktop"
      ];

      "org/gnome/desktop/interface" = {
        enable-hot-corners = false;

        ## Clock
        clock-show-weekday = true;
        clock-show-date = true;

        ## Font stuff
        #monospace-font-name = "RobotoMono Nerd Font 10";
        font-antialiasing = "rgba";
      };

      # Keybindings
      "org/gnome/settings-daemon/plugins/media-keys" = {
        custom-keybindings = [
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
        ];
      };

      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
        binding = "<Super>t";
        command = "ghostty";
        name = "open-terminal";
      };

      "org/gnome/shell/keybindings" = {
        show-screenshot-ui = [ "<Shift><Super>s" ];
      };

      "org/gnome/desktop/wm/preferences" = {
        # Workspace Indicator panel
        # workspace-names = [
        #   "Browser"
        #   "Code"
        #   "Virt"
        # ];
        button-layout = "appmenu:minimize,maximize,close";
      };

      "org/gnome/desktop/wm/keybindings" = {
        toggle-message-tray = "disabled";
        close = [ "<Shift><Super>q" ];
        maximize = "disabled";
        minimize = "disabled";
        move-to-monitor-down = "disabled";
        move-to-monitor-left = "disabled";
        move-to-monitor-right = "disabled";
        move-to-monitor-up = "disabled";
        move-to-workspace-down = "disabled";
        move-to-workspace-up = "disabled";
        move-to-corner-nw = "disabled";
        move-to-corner-ne = "disabled";
        move-to-corner-sw = "disabled";
        move-to-corner-se = "disabled";
        move-to-side-n = "disabled";
        move-to-side-s = "disabled";
        move-to-side-e = "disabled";
        move-to-side-w = "disabled";
        move-to-center = "disabled";
        toggle-maximized = "disabled";
        unmaximize = "disabled";
      };

      # "org/gnome/shell/extensions/pop-shell" = {
      #   tile-by-default = true;
      # };

      # # Configure blur-my-shell
      # "org/gnome/shell/extensions/blur-my-shell" = {
      #   brightness = 0.85;
      #   dash-opacity = 0.25;
      #   sigma = 15; # Sigma means blur amount
      #   static-blur = true;
      # };
      # "org/gnome/shell/extensions/blur-my-shell/panel".blur = true;
      # "org/gnome/shell/extensions/blur-my-shell/appfolder" = {
      #   blur = true;
      #   style-dialogs = 0;
      # };

      # # Configure Pano
      # "org/gnome/shell/extensions/pano" = {
      #   global-shortcut = [ "<Super>comma" ];
      #   incognito-shortcut = [ "<Shift><Super>less" ];
      # };

      # Set the default window for primary applications
      # "org/gnome/shell/extensions/auto-move-windows" = {
      #   application-list = [ "firefox.desktop:1" ];
      # };

      # The open applications bar
      "org/gnome/shell/extensions/window-list" = {
        grouping-mode = "always";
        show-on-all-monitors = true;
        display-all-workspaces = true;
      };

      # "org/gnome/shell/extensions/user-theme" = {
      #   name = "nordic";
      # };
    };
  };

  # ---- System Configuration ----
  services.xserver = {
    enable = true;
    desktopManager.gnome.enable = true;
    displayManager.gdm = {
      enable = true;
      wayland = true;
    };
  };
  services.gnome = {
    evolution-data-server.enable = true;
    gnome-keyring.enable = true;
  };

  programs.dconf.enable = true;

  environment.gnome.excludePackages =
    (with pkgs; [
      gnome-photos
      gnome-tour
      gedit
    ])
    ++ (with pkgs; [
      gnome-music
      #epiphany
      #geary
      #evince
      gnome-characters
      #totem
      tali
      iagno
      hitori
      atomix
    ]);
}

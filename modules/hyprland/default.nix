{
  hyprland,
  hyprpicker,
  pkgs,
  username,
  system,
  ...
}:
{
  imports = [
    hyprland.nixosModules.default
    ./config.nix
  ];

  home-manager.users.${username} = _: {
    # gtk = {
    #   enable = true;
    #   cursorTheme.name = "Adwaita";
    #   cursorTheme.package = pkgs.adwaita-icon-theme;
    # };
    home.pointerCursor = {
      gtk.enable = true;
      x11.enable = true;
      package = pkgs.adwaita-icon-theme;
      name = "Adwaita";
      size = 16;
    };
  };

  ## Fonts for different emojis and text
  #fonts.packages = with pkgs; [                                                                    
  #  noto-fonts                                                                                           
  #  noto-fonts-cjk                                                                                       
  #  noto-fonts-emoji                                                                                     
  #  liberation_ttf
  #  nerdfonts
  #  roboto-mono
  #  font-awesome
  #];

  environment = {
    sessionVariables.NIXOS_OZONE_WL = "1";
    systemPackages = with pkgs; [
      libnotify
      mako
      pamixer
      qt5.qtwayland
      qt6.qtwayland
      hypridle
      hyprlock
      hyprpaper
      hyprshot
      (python3.withPackages (ps: with ps; [requests]))  # for waybar weather script
      xfce.thunar
      pavucontrol
      wlogout
      wl-clipboard
      wofi
      waybar
    ];
  };

  programs.hyprland.enable = true;
  programs.dconf.enable = true;

  services.gnome = {
    gnome-keyring.enable = true;
  };

  services.displayManager.gdm = {
    enable = true;
    wayland = true;
  };

  security.pam.services.login.enableGnomeKeyring = true;

  xdg.portal = {
    enable = true;
    wlr.enable = false;
    xdgOpenUsePortal = false;
    extraPortals = [
      # pkgs.xdg-desktop-portal-hyprland
      pkgs.xdg-desktop-portal-gtk
    ];
  };
  programs.hyprland.portalPackage = pkgs.xdg-desktop-portal-hyprland;   
}

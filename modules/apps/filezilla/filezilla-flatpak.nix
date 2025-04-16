{
    pkgs,
    config,
    ...
}: {
    environment.systemPackages = with pkgs; [
        awscli2
        flatpak
    ];

    services.flatpak.enable = true;

    # Declaratively manage Flatpak app for Filezilla pro
    system.userActivationScripts = {
        setupFlatpaks.text = ''
            # Wait for Flatpak service to be ready
            for i in {1..10}; do
                if systemctl is-active --quiet flatpak-system-helper; then
                break
                fi
                sleep 1
            done

            # Add Flathub remote if not already present
            ${pkgs.flatpak}/bin/flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo --system

            # Install FileZilla Pro from Flathub
            ${pkgs.flatpak}/bin/flatpak install -y --noninteractive --system flathub org.filezillaproject.Filezilla || true
        
            # Update all installed Flatpaks
            ${pkgs.flatpak}/bin/flatpak update -y --noninteractive --system || true
        '';
    };

    # Allow Flatpak to access ~/.aws for credentials
    environment.etc."flatpak/override/org.filezillaproject.Filezilla".text = ''
        [Context]
        filesystems=home
    '';

    environment.shellAliases = {
        filezilla = "flatpak run org.filezillaproject.Filezilla";
    };
}
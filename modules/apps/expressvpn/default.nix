{
    pkgs,
    ...
}: {
    environment.systemPackages = with pkgs; [
        expressvpn
    ];

    services.expressvpn.enable = true;
}
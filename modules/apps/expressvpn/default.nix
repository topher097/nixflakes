{
    pkgs,
    ...
}: {
    environment.systemPackages = with pkgs; [
        unstable.expressvpn
    ];

    services.expressvpn.enable = true;
}

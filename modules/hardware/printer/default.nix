# https://nixos.wiki/wiki/Printing
{
    config,
    pkgs,
    ...
}: {
    services.printing.enable = true;

    # Avahi is a free Zero-configuration networking service, detect printers on network
    services.avahi = {
        enable = true;
        nssmdns4 = true;
        openFirewall = true;
        publish = {
            enable = true;
            userServices = true;
        };
    };

    # Printer sharing, availble on http://localhost:631
    services.printing = {
        listenAddresses = [ "*:631" ];
        allowFrom = [ "all" ];
        browsing = true;
        defaultShared = true;
        openFirewall = true;
    };

    # Include Brother printer drivers; use pkgs.brlaser for many Brother models
    services.printing.drivers = [ pkgs.brlaser ];

    # Enable Avahi for network printer discovery (useful for IPP printers)
    services.avahi = {
        enable = true;
        nssmdns = true;
        openFirewall = true;
    };
}
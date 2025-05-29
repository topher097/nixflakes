{ 
    pkgs,
    ...
}: {
    environment.systemPackages = with pkgs; [
        #unstable.rain-bittorrent
        kdePackages.ktorrent
        webtorrent_desktop
        unstable.qbittorrent-enhanced
    ];

    # Alias for WebTorrent
    environment.shellAliases = {
        webtorrent = "WebTorrent";
    };


}
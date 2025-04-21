{
    pkgs,
    home-manager,
    username,
    ...
}: {
    # Configure Brave with homemanagers
    home-manager.users.${username}.programs.chromium = {
        enable = true;
        package = pkgs.unstable.brave;
        extensions = [
            { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; } # ublock origin
            { id = "cmedhionkhpnakcndndgjdbohmhepckk"; } # adblock for youtube
            { id = "gebbhagfogifgggkldgodflihgfeippi"; } # return youtube dislikes
            { id = "bfogiafebfohielmmehodmfbbebbbpei"; } # keeper password manager
            { id = "eimadpbcbfnmbkopoojfekhnkhdbieeh"; } # dark reader
            { id = "inlikjemeeknofckkjolnjbpehgadgge"; } # distill web monitor
            { id = "jhnleheckmknfcgijgkadoemagpecfol"; } # auto tab discard
        ];
        commandLineArgs = [
            "--disable-features=WebRtcAllowInputVolumeAdjustment"
        ];
    };
}
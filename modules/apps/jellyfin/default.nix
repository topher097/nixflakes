# LINK: https://arne.me/blog/diy-music-streaming-with-nixos-and-jellyfin
{
    pkgs,
    ...
}: {
    environment.systemPackages = with pkgs;[
        jellyfin
        jellyfin-web
        jellyfin-ffmpeg
        caddy
        logrotate
    ];

    services.jellyfin.enable = true;

    services.caddy = {
        enable = true;
        virtualHosts."jellyfin.topher.com".extraConfig = ''
            reverse_proxy 127.0.0.1:8096
        '';
    };
    networking.firewall.allowedTCPPorts = [ 80 443 ];

    services.logrotate.enable = true;
}
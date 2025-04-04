{
    pkgs,
    lib,
    username,
    ...
}: 
let
    ccf-config = builtins.readFile ./ccf/cmendres-ccf.ovpn;
in
{
    services.openvpn.servers = {
        ccfVPN  = {
            autoStart = false;
            config = ''./ccf/cmendres-ccf.ovpn'';
            #authUserPass = ''./ccf/cmendres-ccf-vpn.auth'';
            updateResolvConf = false;
            up = "${pkgs.update-systemd-resolved}/libexec/openvpn/update-systemd-resolved";
            down = "${pkgs.update-systemd-resolved}/libexec/openvpn/update-systemd-resolved";
        };
    };

    # uncomment above if you can't use this because you don't have the update-systemd-resolved flake
    programs.update-systemd-resolved.servers.ccfVPN.includeAutomatically = true;
}

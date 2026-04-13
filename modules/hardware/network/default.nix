{ lib, hostName, username, pkgs, ... }:
{
  systemd.services.NetworkManager-wait-online.enable = lib.mkForce false;

  networking = {
    networkmanager = {
      enable = true;
      dns = "systemd-resolved";
      wifi.powersave = true;
    };
    inherit hostName;
  };

  services.resolved.enable = true;

  users.users.${username} = {
    extraGroups = [ "networkmanager" ];
  };

  environment.systemPackages = with pkgs; [
    iftop
    nload
    unixtools.netstat
    bmon
    speedtest-cli
  ];

}

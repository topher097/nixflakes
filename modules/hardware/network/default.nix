{ lib, hostName, username, pkgs, ... }:
{
  systemd.services.NetworkManager-wait-online.enable = lib.mkForce false;

  networking = {
    networkmanager = {
      enable = true;
      wifi.powersave = true;
    };
    inherit hostName;
  };
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

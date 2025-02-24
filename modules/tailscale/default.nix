# LINK: https://tailscale.com/download/linux/nixos
{ username, hostName, pkgs, ... }:
{
  services.tailscale = {
    enable = true;
    extraUpFlags = [
      # "--shields-up"
      "--operator=${username}"
      "--ssh"
    ];
  };

  # Setup the magic DNS (100.100.100.100) and other DNS namespaces
  networking.nameservers = [ "100.100.100.100" "8.8.8.8" "1.1.1.1" ];
  networking.search = [ "tail8dc3e.ts.net" ];   # Found in the DNS section on tailscale admin console

}

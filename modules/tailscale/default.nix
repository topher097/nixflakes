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

  # davfs2 for mounting taildrive
  # LINK: https://tailscale.com/kb/1369/taildrive?tab=linux#sharing-and-accessing-folders-with-taildrive
  services.davfs2 = {
    enable = true;
  };
  users.users.${username} = {
    extraGroups = [ "davfs2" ];
  };


  # Setup the magic DNS (100.100.100.100) and other DNS namespaces
  networking.nameservers = [ "100.100.100.100" "8.8.8.8" "1.1.1.1" ];
  networking.search = [ "tail8dc3e.ts.net" ];   # Found in the DNS section on tailscale admin console
}

# LINK: https://tailscale.com/download/linux/nixos
{ 
  username,
  home-manager,
  hostName,
  pkgs,
  ... 
}:
{
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
    extraSetFlags = [
      # NOTE: extraUpFlags is only applied when authKeyFile is set (NixOS bug #276912)
      # so all flags must go in extraSetFlags which runs `tailscale set` on every boot
      "--operator=${username}"
      "--ssh"
      "--accept-routes"
      "--exit-node=auto:any"
      "--exit-node-allow-lan-access=true"
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

  # Set the SSH config to allow host forwarding
  home-manager.users.${username}.programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    extraConfig = ''
    Host *.ts.net
      ForwardAgent yes
    '';      
    
    matchBlocks = {
      # Use a wildcard for default settings (typically placed at the end due to SSH config order rules)
      "*" = {
        serverAliveInterval = 120;
        compression = true;
      };
    };
  };
  # home-manager.useGlobalPkgs = true;
  # home-manager.useUserPackages = true;

  # Setup the magic DNS (100.100.100.100) and other DNS namespaces
  networking.nameservers = [ "100.100.100.100" "8.8.8.8" "1.1.1.1" ];
  networking.search = [ "tail8dc3e.ts.net" ];   # Found in the DNS section on tailscale admin console
}

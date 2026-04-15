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
    extraUpFlags = [
      # "--shields-up"
      "--operator=${username}"
      "--ssh"
    ];
    extraSetFlags = [
      # Route all internet traffic through Tailscale's currently suggested exit node,
      # which can be a Mullvad exit node when the add-on is available.
      "--accept-routes"        # Accept subnet routes from peers (required on Linux, default on other OSes)
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

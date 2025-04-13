{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    podman-compose
    podman-tui
    distrobox
  ];

  virtualisation.podman = {
    enable = true;
    #dockerCompat = true;

    defaultNetwork.settings.dns_enabled = true;
  };
}

# Help LINK: https://discourse.nixos.org/t/nvidia-docker-container-runtime-doesnt-detect-my-gpu/51336/2
{ pkgs, username, ... }:
{
  environment.systemPackages = with pkgs; [ docker-compose ];

  # Docker can also be run rootless
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
  };
  # User permissions 
  users.users.${username}.extraGroups = [ "docker" ];

  # Enable for GPU access in docker containers
  hardware.nvidia-container-toolkit.enable = true;
}

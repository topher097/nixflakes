{ 
  pkgs,
  config,
  username,
  home-manager,
  ...
}: {
  # Environment variables
  # ---- I often have these enabled elsewhere but you may still want these if you are having issues ----
  # Force wayland when possible
  # environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # Fix disappearing cursor on Hyprland
  # environment.sessionVariables.WLR_NO_HARDWARE_CURSORS = "1";

  # To fix the issue of suspension being broken on awakening, read this article and copy the contents of the file to /etc/modprobe.d/nvidia-power-management.conf
  # LINK: https://wiki.archlinux.org/title/NVIDIA/Tips_and_tricks#Preserve_video_memory_after_suspend
  # Copy command: sudo mkdir /etc/modprobe.d -p && sudo cp ./modules/hardware/nvidia/nvidia-power-management.conf /etc/modprobe.d/nvidia-power-management.conf 

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Enable NVIDIA
  services.xserver.videoDrivers = [ "nvidia" ];
  services.xserver.enable = true;

  # For gpu use in containers
  hardware.nvidia-container-toolkit.enable = true;

  # Define nvidia settings
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    # https://nixos.wiki/wiki/Nvidia#Running_the_new_RTX_SUPER_on_nixos_stable
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # Include nvtop for GPU usage monitoring
  environment.systemPackages = with pkgs; [
    nvtopPackages.nvidia   # btop for nvidia GPUs
  ];

  # Define the groups to have the user join
  users.users.${username} = {
    extraGroups = [
      "video"
      "render"
      "compute"
    ];
  };
}

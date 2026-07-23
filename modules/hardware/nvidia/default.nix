{
  pkgs,
  config,
  lib,
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

  # Tolerate NVIDIA driver version mismatch during live upgrades.
  # The CDI generator fails when userspace libs (new) don't match the
  # running kernel module (old). Exit 0 with a warning so nixos-rebuild
  # doesn't report a failed service. Resolves after reboot.
  systemd.services.nvidia-container-toolkit-cdi-generator.serviceConfig.ExecStart =
    lib.mkForce
    (let
      generator = pkgs.writeScriptBin "nvidia-cdi-generator-safe" ''
        #!${pkgs.runtimeShell}
        set -euo pipefail
        if ! ${pkgs.nvidia-container-toolkit}/bin/nvidia-ctk cdi generate \
          --format json \
          --discovery-mode auto \
          --device-name-strategy index \
          --disable-hook create-symlinks \
          --ldconfig-path ${pkgs.glibc}/bin/ldconfig \
          --library-search-path ${config.hardware.nvidia.package}/lib \
          --nvidia-cdi-hook-path ${pkgs.nvidia-container-toolkit}/bin/nvidia-cdi-hook \
          > "$RUNTIME_DIRECTORY/nvidia-container-toolkit.json" 2>/tmp/cdi-err; then
          if grep -q "Driver/library version mismatch" /tmp/cdi-err 2>/dev/null; then
            echo "nvidia-cdi-generator: Driver/library version mismatch — reboot required to complete NVIDIA upgrade. Skipping CDI generation."
            exit 0
          fi
          cat /tmp/cdi-err >&2
          exit 1
        fi
      '';
    in
    lib.getExe generator);

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

  # # Include nvtop for GPU usage monitoring
  # environment.systemPackages = with pkgs; [
  #   nvtopPackages.nvidia   # btop for nvidia GPUs
  # ];

  # Define the groups to have the user join
  users.users.${username} = {
    extraGroups = [
      "video"
      "render"
      "compute"
    ];
  };
}

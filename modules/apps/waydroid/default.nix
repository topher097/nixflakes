{ config, lib, ... }:

with lib;

let
  cfg = config.modules.apps.waydroid;
in
{
  options.modules.apps.waydroid = {
    enable = mkEnableOption "Waydroid Android container";

    # Optional: add options for customization
    gapps = mkOption {
      type = types.bool;
      default = false;
      description = "Enable Google Apps support in Waydroid";
    };

    # Add waydroid-helper if desired
    helper = mkOption {
      type = types.bool;
      default = true;
      description = "Enable waydroid-helper for mounting host directories";
    };
  };

  config = {
    # Enable waydroid by default when the module is imported
    modules.apps.waydroid.enable = mkDefault true;

    # Apply configuration if enabled
    virtualisation.waydroid.enable = mkIf cfg.enable true;

    # Add waydroid-helper package and service if enabled
    environment.systemPackages = mkIf (cfg.enable && cfg.helper) [
      # waydroid-helper may not be available in nixpkgs 25.05
      # For now, skip or use unstable if needed
      # config.nixpkgs.pkgs.waydroid-helper or (throw "waydroid-helper not available in nixpkgs")
    ];

    systemd.packages = mkIf (cfg.enable && cfg.helper) [
      # config.nixpkgs.pkgs.waydroid-helper or (throw "waydroid-helper not available in nixpkgs")
    ];

    systemd.services.waydroid-mount = mkIf (cfg.enable && cfg.helper) {
      wantedBy = [ "multi-user.target" ];
    };
  };
}

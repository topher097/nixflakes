{
  # hardware-configuration.nix is generated per machine and is not committed
  # yet; import it only when it exists so this host still evaluates (and
  # still picks up the shared modules, opencode included).
  imports = [
    (if builtins.pathExists ./hardware-configuration.nix then ./hardware-configuration.nix else { })
  ];

  # Stands in for the nixpkgs.hostPlatform the missing hardware config sets.
  nixpkgs.hostPlatform = "x86_64-linux";

}

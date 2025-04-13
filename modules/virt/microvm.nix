{
    pkgs,
    ...
}:
{
    microvm.nixosModules.microvm = import ./microvm.nix { inherit pkgs; };
    networking.hostName = "microvm";
    
}
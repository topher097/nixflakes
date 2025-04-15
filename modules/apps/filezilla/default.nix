{ config, pkgs, ... }:

{
  environment.systemPackages = [
    (import ./filezilla-pro.nix { inherit pkgs; })
  ];
}
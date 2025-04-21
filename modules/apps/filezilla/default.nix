{ config, pkgs, ... }:

{
  environment.systemPackages = [
    (import ./filezilla-pro.nix { inherit pkgs; })
    pkgs.awscli2
  ];
}
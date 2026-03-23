{ system, tophvim, ... }:
{
  environment.variables.EDITOR = "nvim";
  environment.systemPackages = [ tophvim.packages.${system}.default ];
}
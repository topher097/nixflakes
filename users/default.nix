{ username, system, ... }:
{
  imports = [ ./${username} ];

  nix.settings.trusted-users = [ "root" "@wheel" "${username}" ];  
}

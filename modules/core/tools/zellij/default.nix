{
  pkgs,
  home-manager,
  username,
  ...
}:
{
  home-manager.users.${username}.programs.zellij = {
    enable = true;
    package = pkgs.zellij;
    enableFishIntegration = true;
  };
}


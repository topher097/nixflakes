{ pkgs, username, ... }:
{
  services.mullvad-vpn = {
    enable = true;
    package = pkgs.mullvad-vpn;
  };

  home-manager.users.${username}.programs.mullvad-vpn = {
    enable = true;
    package = pkgs.mullvad-vpn;
    # Keep GUI behavior at Mullvad defaults unless explicitly customized.
    settings = { };
  };
}

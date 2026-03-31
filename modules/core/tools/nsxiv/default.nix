{ pkgs, username, ... }:
{
  # Dedicated nsxiv module for high-resolution image viewing from tools like
  # ranger and xplr. Stylix colors are configured globally in modules/stylix.
  home-manager.users.${username}.home.packages = with pkgs; [
    nsxiv
  ];
}

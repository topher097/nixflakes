{
  pkgs,
  home-manager,
  username,
  ...
}:
{
  environment.systemPackages = with pkgs; [ unstable.wezterm ];

  home-manager.users.${username} = _: {
    home.file = {
      ".config/wezterm/wezterm.lua".source = ./wezterm.lua;
    };
  };
}
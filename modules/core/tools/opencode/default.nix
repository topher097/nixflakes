{
  pkgs,
  username,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    unstable.opencode
    bun
    libnotify
  ];

  home-manager.users.${username} = {
    home.file = {
      ".config/opencode/opencode.json".source = ./opencode.json;
      ".config/opencode/opencode-notifier.json".source = ./opencode-notifier.json;
    };
  };
}

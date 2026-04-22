{
  pkgs,
  username,
  caveman,
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
      ".config/opencode/AGENTS.md".source = ./AGENTS.md;
      ".config/opencode/skills/caveman/SKILL.md".source = "${caveman}/skills/caveman/SKILL.md";
    };
  };
}

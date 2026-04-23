{
  pkgs,
  lib,
  username,
  inputs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    python3
    unstable.opencode
    bun
    libnotify
  ];

  home-manager.users.${username} = {
    imports = [
      inputs.agent-skills.homeManagerModules.default
    ];

    programs.agent-skills = {
      enable = true;

      sources.caveman = {
        input = caveman;
        subdir = skills;
        filter.maxDepth = 1;
      };

      skills.enable = [
        caveman
        caveman-commit
        caveman-help
        caveman-review
        compress
      ];

      targets.opencode = {
        dest = $HOME/.config/opencode/skills;
        structure = symlink-tree;
        enable = true;
      };
    };

    home.file = {
      .config/opencode/opencode.json.source = ./opencode.json;
      .config/opencode/opencode-notifier.json.source = ./opencode-notifier.json;
      .config/opencode/AGENTS.md.source = ./AGENTS.md;
    };
  };
}
{
  pkgs,
  lib,
  username,
  inputs,
  ...
}:
let
  opencodeConfig = lib.importJSON ./opencode.json;
  opencodeNotifierConfig = lib.importJSON ./opencode-notifier.json;
in
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
        input = "caveman";
        subdir = "skills";
        filter.maxDepth = 1;
      };

      skills.enable = [
        "caveman"
        "caveman-commit"
        "caveman-help"
        "caveman-review"
        "compress"
      ];

      targets.opencode = {
        dest = "/home/${username}/.config/opencode/skills";
        structure = "symlink-tree";
        enable = true;
      };
    };

    home.file = {
      ".config/opencode/opencode.json".text = builtins.toJSON opencodeConfig;
      ".config/opencode/opencode-notifier.json".text = builtins.toJSON opencodeNotifierConfig;
      ".config/opencode/AGENTS.md".source = ./AGENTS.md;
    };
  };
}

{ home-manager, attrs, ... }:
{
  imports = [
    home-manager.nixosModules.home-manager
    ./users
    ./hosts
    ./modules/core/terminal
    ./modules/core/nix
    ./modules/core/tools/llm-agents
  ];

  # agent-skills and oh-my-opencode-slim read their sources from flake inputs.
  home-manager.extraSpecialArgs = {
    inputs = attrs;
  };
}

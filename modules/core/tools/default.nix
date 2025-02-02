{ 
  pkgs, 
  username,
  home-manager,
  ... 
}:
{ 
  # Independent tool flakes
  imports = [
    ./starship
    ./nvim
  ];

  # Other system tools and packages
  environment.systemPackages = with pkgs; [
    brightnessctl
    htop
    btop
    #gh
    mods          # OpenAI CLI tool
    nitch         # CLI info 
    #pavucontrol
    #playerctl
    ripgrep
    #todoist
    unzip
    #vhs
    zoxide
    fzf
    tree
    wget
    eza
    unstable.devenv
    cachix
    wget
    service-wrapper
    just
    unstable.lazygit
  ];

  # Aliases for different tools

# Git aliases
home-manager.users.${username}.programs.git = {
  enable = true;
  package = pkgs.gitAndTools.gitFull;
  # Prepend these aliases with `git` to use them
  aliases = {
    undo = "reset HEAD~1 --mixed";
  };

  extraConfig = {
      credential.helper = "oauth";
      color = {
        ui = "auto";
      };
      diff = {
        tool = "vimdiff";
        mnemonicprefix = true;
      };
      merge = {
        tool = "splice";
      };
      push = {
        default = "simple";
      };
      pull = {
        rebase = true;
      };
      branch = {
        autosetupmerge = true;
      };
      rerere = {
        enabled = true;
      };
      # include = {
      #   path = "~/.gitconfig.local";
      # };
    };
  };

# Shell-agnostic aliases
environment.interactiveShellInit = ''
  export EZA_COLORS='da=1;34:gm=1;34:Su=1;34'
  alias eza='eza --show-symlinks --almost-all --tree --git-ignore'
  alias ls='eza'

  alias z='zoxide'
  alias t='tmux'
  alias n='nvim'
  alias e='exit'
  alias c='clear'
  alias r='ranger'
  alias h='htop'
  alias nv='nvtop'
  alias b='btop'
  alias mv='mv -i'
  alias cp='cp -i'

  alias lg='lazygit'
  alias gaa='git add --all'
  alias gc='git commit -m'
  alias gca='git commit --amend'
  alias gs='git status'

  nitch
'';

}
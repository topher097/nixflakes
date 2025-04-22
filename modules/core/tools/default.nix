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
    ranger
    ntfs3g
    exfat
    rpi-imager
    any-nix-shell
  ];
  
  nix.extraOptions = ''
    extra-substituters = https://devenv.cachix.org
    extra-trusted-public-keys = devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw= nixpkgs-python.cachix.org-1:hxjI7pFxTyuTHn2NkvWCrAUcNZLNS3ZAvfYNuYifcEU=
  '';
  
  # Git aliases
  home-manager.users.${username}.programs.git = {
    enable = true;
    package = pkgs.gitAndTools.gitFull;
    # Prepend these aliases with `git` to use them
    aliases = {
      undo = "reset HEAD~1 --mixed";
    };

    extraConfig = {
      #credential.helper = "oauth";
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

  # Enable thunderbird
  programs.thunderbird = {
    enable = true;
  };

  environment.shellAliases = {
    cp = "cp -ia";
    ls = "ls -la --color=auto";
    mv = "mv -i";
    eza = "eza --show-symlinks --almost-all --tree --git-ignore";
    z = "zoxide";
    zi = "zoxide query --interactive";
    "..." = "cd ../..";
    j = "just";

    lg = "lazygit";
    gaa = "git add --all";
    gc = "git commit -m";
    gca = "git commit --amend";
    gs = "git status";

    h = "htop";
    b = "btop";
    nv = "nvtop";

    c = "clear";
    e = "exit";

    n = "nvim";
    t = "tmux";
    r = "ranger";
  };

}

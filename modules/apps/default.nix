{ pkgs, username, ... }:
{
  imports = [
    #./1password
    ./firefox
    ./gitkraken
    #./jetbrains
    #./libreoffice
    #./obsidian
    ./vscode
    ./spotify
    ./3d-printing
    #./discord
    ./inkscape
  ];
  
  home-manager.users.${username} = {
    home.packages = with pkgs; [
      ticktick
      remmina
    ];

    programs.zathura = {
      enable = true;
    };
  };
}

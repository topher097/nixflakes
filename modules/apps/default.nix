{ pkgs, username, ... }:
{
  imports = [
    #./1password
    ./firefox
    ./gitkraken
    ./expressvpn
    #./jetbrains
    ./libreoffice
    #./obsidian
    ./vscode
    ./spotify
    ./discord
    ./inkscape
    ./filezilla
  ];
  
  home-manager.users.${username} = {
    home.packages = with pkgs; [
      ticktick
      remmina
    ];

    programs.zathura = {
      enable = true;
    };

    programs.yazi = {
      enable = true;
    };
  };
}

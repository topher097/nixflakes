{ pkgs, username, ... }:
{
  imports = [
    #./1password
    #./firefox
    #./gitkraken
    ./expressvpn
    #./jetbrains
    ./libreoffice
    #./obsidian
    ./vscode
    ./spotify
    ./discord
    #./inkscape
    ./filezilla
    ./brave
    ./torrent
  ];
  
  home-manager.users.${username} = {
    home.packages = with pkgs; [
    ];

    programs.zathura = {
      enable = true;
    };

    programs.yazi = {
      enable = true;
    };

    # Pomodor timer app
    services.tomat = {
        enable = true;
        settings = {
            timer = {
                work = 25;
                break = 5;
            };
        };
    };
  };
}

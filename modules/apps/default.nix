{ pkgs, username, ... }:
{
  imports = [
    # ./expressvpn
    # ./mullvad
    ./3d-printing
    ./libreoffice
    ./vscode
    ./spotify
    ./discord
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
      shellWrapperName = "y";
    };

    # Pomodoro timer app
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

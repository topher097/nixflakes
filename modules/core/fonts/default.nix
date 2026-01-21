{ pkgs, ... }:
{
  fonts = {
    packages = with pkgs; [
      noto-fonts                                                                                                                                                                             
      noto-fonts-color-emoji                                                                                     
      liberation_ttf
      roboto-mono
      font-awesome
    ];
  };
}

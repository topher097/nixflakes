# LINK: https://nixos.wiki/wiki/LibreOffice
{ pkgs, ... }:
let
  office = pkgs.libreoffice-fresh-unwrapped;
in {
  environment.sessionVariables = {
    PYTHONPATH = "${office}/lib/libreoffice/program";
    URE_BOOTSTRAP = "vnd.sun.star.pathname:${office}/lib/libreoffice/program/fundamentalrc";
  };
  
  environment.systemPackages = with pkgs; [
    libreoffice-qt
    hunspell
    hunspellDicts.en_CA
    hunspellDicts.en_US
  ];
}

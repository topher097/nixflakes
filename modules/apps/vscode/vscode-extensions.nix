{
    pkgs,
    ...
}:

with pkgs.vscode-extensions; [
    tailscale.vscode-tailscale
    ms-vscode-remote.remote-ssh
    ms-vscode-remote.vscode-remote-extensionpack
    ms-python.python
    #ms-python.vscode-pylance
    ms-toolsai.jupyter
    vscodevim.vim
    bbenoist.nix
    nefrob.vscode-just-syntax
    tamasfe.even-better-toml
    redhat.vscode-yaml
    zainchen.json
    yzhang.markdown-all-in-one
    mechatroner.rainbow-csv
    grapecity.gc-excelviewer
    johnpapa.vscode-peacock
    ibm.output-colorizer
    tomoki1207.pdf
  # Not supported on Darwin, apparently
  #    ms-dotnettools.csharp
] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
  {
    name = "python";
    publisher = "ms-python";
    version = "2026.1.2026012801";
    sha256 = "";
  }
]
{
  pkgs,
  home-manager,
  username,
  lib,
  ...
}:
{
  home-manager.users.${username} = {
    # VS Code on Wayland has issues, make sure to set the title bar to custom
    # https://github.com/microsoft/vscode/issues/181533
    programs.vscode = {
      enable = true;
      package = pkgs.unstable.vscode;
      profiles.default = {
        enableUpdateCheck = false;
        enableExtensionUpdateCheck = false;
        extensions = with pkgs.vscode-extensions; [
          github.copilot
          #mvllow.rose-pine
          eamodio.gitlens
          tailscale.vscode-tailscale
          ms-vscode-remote.vscode-remote-extensionpack
          #oderwat.indent-rainbow
          ms-toolsai.jupyter
          ms-python.python
          ms-python.vscode-pylance
          ms-python.python
          bbenoist.nix
          charliermarsh.ruff
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
        ];
        userSettings = {
          "window.titleBarStyle" = "custom";
          #"workbench.colorTheme" = lib.mkForce "Rosé Pine Moon";
          "workbench.colorTheme" = "Stylix";
          "editor.semanticHighlighting.enabled" = true;
          "editor.minimap.renderCharacters" = false;
          "editor.minimap.showSlider" = "always";
          "editor.minimap.size" = "fit";
          "[python]" = {
            "editor.defaultFormatter" = null;
            "editor.formatOnType" = true;
            "editor.codeActionsOnSave" = {
              "source.fixAll.ruff" = "always";
              "source.organizeImports.ruff" = "explicit";
            };
          };
          "github.copilot.enable" = {
            "*" = true;
            "plaintext" = false;
            "markdown" = true;
            "scminput" = false;
            "python" = true;
            "c++" = true;
            "c" = true;
            "yaml" = true;
          };
          "editor.inlineSuggest.enabled" = true;

          # For tailscale ssh
          "remote.SSH.useLocalServer" = false;
          "remote.SSH.connectTimeout" = 30;      # In seconds   
          "tailscale.ssh.connectionTimeout" = 30000;   # In ms
          "remote.SSH.remotePlatform" = {
            "pgi-desktop.tail8dc3e.ts.net" = "linux";
          };
          "remote.SSH.localServerDownload" = "always";
          "remote.SSH.showLoginTerminal" = "true";
          
        };
      };
    };
  };
}

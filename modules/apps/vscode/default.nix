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
          #github.copilot
          eamodio.gitlens
          tailscale.vscode-tailscale
          ms-vscode-remote.remote-ssh
          ms-vscode-remote.vscode-remote-extensionpack
          ms-toolsai.jupyter
          ms-python.python
          ms-python.vscode-pylance
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
          # Disable copilot
          "github.copilot.enable" = false;
          # "github.copilot.enable" = {
          #   "*" = true;
          #   "plaintext" = false;
          #   "markdown" = true;
          #   "scminput" = false;
          #   "python" = true;
          #   "c++" = true;
          #   "c" = true;
          #   "yaml" = true;
          # };
          "editor.inlineSuggest.enabled" = true;
          "markdown.preview.fontFamily" = "IBM Plex Sans";
          "markdown.preview.fontSize" = 16.0;

          # For tailscale ssh
          "remote.SSH.useLocalServer" = false;
          "remote.SSH.connectTimeout" = 30;      # In seconds   
          "tailscale.ssh.connectionTimeout" = 30000;   # In ms
          "remote.SSH.remotePlatform" = {
            "pgi-desktop.tail8dc3e.ts.net" = "linux";
          };
          "remote.SSH.localServerDownload" = "always";
          "remote.SSH.showLoginTerminal" = true;
          "update.mode" = "none";
          "window.titleBarStyle" = "custom";

          # Not sure what these are for
          "scm.inputFontFamily" = "IBM Plex Mono";
          "screencastMode.fontSize" = 64.0;
          
          # Stuff for Vim VSCode
          "vim.easymotion" = true;
          "vim.incsearch" = true;
          "vim.surround" = true;
          #"vim.commentary" = true;
          #"vim.indent-object" = true;
          "vim.camelCaseMotion.enable" = true;
          "vim.useSystemClipboard" = true;
          "vim.useCtrlKeys" = true;
          "vim.hlsearch" = true;
          "vim.insertModeKeyBindings" = [
            {
              "before"= ["j" "j"];
              "after"= ["<Esc>"];
            }
          ];
          "vim.normalModeKeyBindingsNonRecursive"= [
            {
              "before"= ["<leader>" "d"];
              "after"= ["d" "d"];
            }
            {
              "before"= ["<C-n>"];
              "commands"= [":nohl"];
            }
            {
              "before"= ["K"];
              "commands"= ["lineBreakInsert"];
              "silent"= true;
            }
          ];
          "vim.normalModeKeyBindings" = [
            {
              "before"= [":"];
              "commands"= [
                  "workbench.action.showCommands"
              ];
              "silent"= true;
            }
          ];
          "vim.leader" = "<space>";
          "vim.handleKeys" = {
            "<C-a>"= false;
            "<C-f>"= false;
          };

          # To improve performance
          "extensions.experimental.affinity" = {
            "vscodevim.vim" = 1;
          };

          # Amp code
          "amp.tab.enabled" = true;
          "amp.permissions" = [
            {
              "tool" = "Bash";
              "action" = "allow";
              "context" = "thread";
            }
            # {
            #   "tool" = "Bash";
            #   "matches" = {
            #     "cmd" = {
            #       "rm -rf *"
            #       "find *"
            #       "git commit *"
            #     };
            #   };
            #   "action" = "reject";
            #   "context" = "subagent";
            # }
          ];
        };
      };
    };
  };
}

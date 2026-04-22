{
  pkgs,
  home-manager,
  username,
  ...
}:
{
  home-manager.users.${username}.programs.zellij = {
    enable = true;
    package = pkgs.zellij;
    enableFishIntegration = true;

    # Keybinds for vim-zellij-navigator (smart-splits.nvim integration)
    #
    # These bindings use the vim-zellij-navigator WASM plugin to route
    # Ctrl-h/j/k/l and Alt-h/j/k/l intelligently between Zellij and
    # Neovim. When the focused pane is running Neovim, the keystroke is
    # forwarded to Neovim (where smart-splits.nvim handles it). When the
    # focused pane is a shell or other program, Zellij moves/resizes its
    # own panes directly.
    #
    # Overridden defaults:
    #   Ctrl h  — was "SwitchToMode Move" → now navigate left
    #   Ctrl l  — was "SwitchToMode Session" → now navigate right
    #   Alt h/j/k/l — was "MoveFocus" → now resize panes
    #
    # Alternates for lost bindings:
    #   Ctrl m  — enter Move mode (replaces lost Ctrl h)
    #   Ctrl s  — enter Session mode (unchanged, already default)
    extraConfig = ''
      keybinds {
        shared_except "locked" {
          // Navigation: move focus between Zellij panes (and into/out of Neovim)
          bind "Ctrl h" {
            MessagePlugin "https://github.com/hiasr/vim-zellij-navigator/releases/download/0.2.1/vim-zellij-navigator.wasm" {
              name "move_focus";
              payload "left";
            };
          }
          bind "Ctrl j" {
            MessagePlugin "https://github.com/hiasr/vim-zellij-navigator/releases/download/0.2.1/vim-zellij-navigator.wasm" {
              name "move_focus";
              payload "down";
            };
          }
          bind "Ctrl k" {
            MessagePlugin "https://github.com/hiasr/vim-zellij-navigator/releases/download/0.2.1/vim-zellij-navigator.wasm" {
              name "move_focus";
              payload "up";
            };
          }
          bind "Ctrl l" {
            MessagePlugin "https://github.com/hiasr/vim-zellij-navigator/releases/download/0.2.1/vim-zellij-navigator.wasm" {
              name "move_focus";
              payload "right";
            };
          }

          // Resize: Alt-h/j/k/l resizes Zellij panes (and Neovim splits)
          bind "Alt h" {
            MessagePlugin "https://github.com/hiasr/vim-zellij-navigator/releases/download/0.2.1/vim-zellij-navigator.wasm" {
              name "resize";
              payload "left";
            };
          }
          bind "Alt j" {
            MessagePlugin "https://github.com/hiasr/vim-zellij-navigator/releases/download/0.2.1/vim-zellij-navigator.wasm" {
              name "resize";
              payload "down";
            };
          }
          bind "Alt k" {
            MessagePlugin "https://github.com/hiasr/vim-zellij-navigator/releases/download/0.2.1/vim-zellij-navigator.wasm" {
              name "resize";
              payload "up";
            };
          }
          bind "Alt l" {
            MessagePlugin "https://github.com/hiasr/vim-zellij-navigator/releases/download/0.2.1/vim-zellij-navigator.wasm" {
              name "resize";
              payload "right";
            };
          }

          // Alternate binding for Move mode (floating pane management)
          // Replaces the default Ctrl h which is now used for navigation
          bind "Ctrl m" { SwitchToMode "Move"; }
        }
      }
    '';
  };
}


{
  pkgs,
  lib,
  username,
  inputs,
  ...
}:
let
  opencodeConfig = lib.importJSON ./opencode.json;
  opencodeNotifierConfig = lib.importJSON ./opencode-notifier.json;
  # oh-my-openagent model routing (agents + categories), shared by the OmO
  # native `omo` binary and the opencode plugin port. Vendored from the
  # installer output so every machine gets the same routing.
  omoConfig = lib.importJSON ./omo.jsonc;
  # oh-my-openagent V2 port (fazulfi/omo-v2, branch port/v2): upstream ships
  # only load-only support for opencode 2.x, so the full plugin (agents,
  # skills, hooks) comes from this fork as a local-path plugin. Kept fresh
  # and rebuilt by the activation below.
  omoV2Path = "/home/${username}/.local/share/omo-v2";
  opencodeJson = opencodeConfig // {
    plugins = opencodeConfig.plugins ++ [ omoV2Path ];
  };
in
{
  environment.systemPackages = with pkgs; [
    python3
    unstable.opencode
    bun
    gh
    libnotify
    nodejs
  ];

  home-manager.users.${username} = {
    imports = [
      inputs.agent-skills.homeManagerModules.default
    ];

    programs.agent-skills = {
      enable = true;

      sources.caveman = {
        input = "caveman";
        subdir = "skills";
        filter.maxDepth = 1;
      };

      sources.pstack = {
        input = "pstack";
        subdir = "skills";
      };

      skills.enable = [
        "caveman"
        "caveman-commit"
        "caveman-help"
        "caveman-review"
        "caveman-compress"
      ];

      # All 53 pstack skills (29 workflow + 24 principle-*).
      skills.enableAll = [ "pstack" ];

      targets.opencode = {
        dest = "/home/${username}/.config/opencode/skills";
        structure = "symlink-tree";
        enable = true;
      };
    };

    home.file = {
      ".config/opencode/opencode.json".text = builtins.toJSON opencodeJson;
      ".config/opencode/opencode-notifier.json".text = builtins.toJSON opencodeNotifierConfig;
      ".omo/omo.jsonc".text = builtins.toJSON omoConfig;
      ".config/opencode/AGENTS.md".source = ./AGENTS.md;
      ".config/opencode/agents/poteto-agent.md".source = "${inputs.pstack}/agents/poteto-agent.md";
      ".config/opencode/agents/comment-sicko.md".source = "${inputs.pstack}/agents/comment-sicko.md";
    };

    # opencode caches npm plugin resolutions (@latest) under ~/.cache/opencode/npm
    # and keeps serving stale copies across rebuilds. Purge the whole cache so
    # every rebuild re-resolves all plugins to the newest version from npm on
    # the next plugin load.
    #
    # OmO Native (standalone `omo`) refresh: opencode 2.x runs the omo plugin
    # inert (no agents/tools/hooks), so omo lives as its own binary. The
    # official installer is idempotent — replaces ~/.local/bin/omo only when
    # the latest channel has a newer version, does nothing otherwise — and
    # verifies SHA256SUMS. Guarded so an offline rebuild only skips the
    # refresh instead of failing activation.
    home.activation.refreshOpencodePlugins =
      inputs.home-manager.lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        rm -rf "$HOME/.cache/opencode/npm"
        ${pkgs.curl}/bin/curl -fsSL https://get.omo.dev/install.sh \
          | OMO_NO_MODIFY_PATH=1 ${pkgs.bash}/bin/bash \
          >> "$HOME/.cache/omo-install.log" 2>&1 || true
        # oh-my-openagent V2 port: keep the checkout on the port/v2 branch and
        # rebuild only when new commits landed (or dist is missing). The sed
        # patch re-applied after every reset bundles @opencode/client into the
        # plugin: the host does not expose that package to plugins, so leaving
        # it external breaks the load (stale-resolution errors). bun needs
        # node/npm on PATH for some sub-builds, hence the nodejs package above.
        omoV2="$HOME/.local/share/omo-v2"
        if [ ! -d "$omoV2/.git" ]; then
          ${pkgs.git}/bin/git clone -q --branch port/v2 --depth 1 \
            https://github.com/fazulfi/omo-v2 "$omoV2" 2>/dev/null || true
        fi
        if [ -d "$omoV2/.git" ]; then
          omoOld=$(${pkgs.git}/bin/git -C "$omoV2" rev-parse HEAD 2>/dev/null || true)
          ${pkgs.git}/bin/git -C "$omoV2" fetch -q origin port/v2 2>/dev/null || true
          ${pkgs.git}/bin/git -C "$omoV2" reset -q --hard origin/port/v2 2>/dev/null || true
          ${pkgs.git}/bin/git -C "$omoV2" checkout -q port/v2 2>/dev/null || true
          sed -i 's/, "--external", "@opencode\/client"//g' "$omoV2/script/build-nodes.ts" 2>/dev/null || true
          omoNew=$(${pkgs.git}/bin/git -C "$omoV2" rev-parse HEAD 2>/dev/null || true)
          if [ "$omoOld" != "$omoNew" ] || [ ! -f "$omoV2/dist/tui-entry.js" ] \
            || ! grep -q '@opencode/client' "$omoV2/dist/index.js" 2>/dev/null; then
            (
              cd "$omoV2" \
                && ${pkgs.bun}/bin/bun install \
                && ${pkgs.bun}/bin/bun run build \
                && mkdir -p node_modules/@opencode \
                && for entry in node_modules/.bun/@opencode+*; do
                    pkgName=$(basename "$entry" | sed -E 's/^@opencode\+([^@]+)@.*/\1/')
                    if [ -d "$entry/node_modules/@opencode/$pkgName" ] && [ ! -e "node_modules/@opencode/$pkgName" ]; then
                      ln -s "$(realpath "$entry/node_modules/@opencode/$pkgName")" "node_modules/@opencode/$pkgName"
                    fi
                  done
            ) >> "$HOME/.cache/omo-v2-build.log" 2>&1 || true
          fi
        fi
      '';
  };
}

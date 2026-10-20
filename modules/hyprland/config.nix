{
    home-manager,
    username,
    pkgs,
    lib,
    ...
}:
let
    configDir = ../hyprland;

    # Battery present at eval time -> laptop-style host: keep power-profiles module.
    # No battery -> strip every power-profiles-daemon reference from the generated waybar config.
    hasBattery =
        lib.any (x: lib.strings.hasPrefix "BAT" x)
            (builtins.attrNames (builtins.readDir "/sys/class/power_supply"));

    baseConfig = builtins.readFile "${configDir}/waybar/config.jsonc";

    # Remove the power-profiles-daemon waybar module (list entry + config block)
    # from the shared config, using the pp-marker comment sentinels in config.jsonc.
    lines = lib.strings.splitString "\n" baseConfig;

    go = {
        acc,
        skipping,
    }: line:
        let
            isEntry = line == "        \"power-profiles-daemon\"";
            isStart = lib.strings.hasInfix "pp-marker: block-start" line;
            isEnd = lib.strings.hasInfix "pp-marker: block-end" line;
        in
            if skipping && isEnd then {
                inherit acc;
                skipping = false;
            } else if skipping then {
                inherit acc;
                skipping = true;
            } else if isStart then {
                inherit acc;
                skipping = true;
            } else if isEntry then {
                inherit acc;
                skipping = false;
            } else {
                acc = acc ++ [ line ];
                skipping = false;
            };

    stripped = lib.strings.concatStringsSep "\n"
        ((lib.lists.foldl' go { acc = [ ]; skipping = false; } lines).acc);

    # "battery" stays as the last entry in modules-right: drop the trailing comma.
    noPPConfig =
        lib.strings.replaceStrings
            [ "        \"battery\",\n    ]," ]
            [ "        \"battery\"\n    ]," ]
            stripped;

    waybarSource =
        if hasBattery then
            "${configDir}/waybar"
        else
            (pkgs.runCommand "waybar-stripped" { } ''
                mkdir -p $out
                cp -r ${configDir}/waybar/. $out/
                chmod -R u+w $out
                printf '%s' ${lib.escapeShellArg noPPConfig} > $out/config.jsonc
            '');
in {
    home-manager.users.${username} = _: {
        # Hyprland never activates graphical-session.target itself, and that
        # target refuses manual start. This intermediate target is started by
        # exec.conf and pulls in graphical-session.target via a dependency, so
        # services WantedBy=graphical-session.target (tomat, redshift, ...)
        # actually start with the session.
        systemd.user.targets.hyprland-session = {
            Unit = {
                Description = "Hyprland compositor session";
                BindsTo = [ "graphical-session.target" ];
                Wants = [ "graphical-session.target" ];
                After = [ "graphical-session.target" ];
            };
        };

        home.file = {
            ".config/wallpapers".source = "${configDir}/wallpapers";
            ".config/hypr".source = "${configDir}/hypr";
            #".config/swayidle".source = "${configDir}/swayidle";
            #".config/swaylock".source = "${configDir}/swaylock";
            ".config/hypridle".source = "${configDir}/hypridle";
            ".config/hyprlock".source = "${configDir}/hyprlock";
            ".config/wlogout".source = "${configDir}/wlogout";
            ".config/waybar".source = waybarSource;
            ".config/wofi".source = "${configDir}/wofi";
            ".config/mako".source = "${configDir}/mako";
        };
    };
}

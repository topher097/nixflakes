{
    home-manager,
    username,
    ...
}:
let configDir = ../hyprland;
in
{
    home-manager.users.${username} = _: {
        home.file = {
            ".config/wallpapers".source = "${configDir}/wallpapers";
            ".config/hypr".source = "${configDir}/hypr";
            #".config/swayidle".source = "${configDir}/swayidle";
            #".config/swaylock".source = "${configDir}/swaylock";
            ".config/hypridle".source = "${configDir}/hypridle";
            ".config/hyprlock".source = "${configDir}/hyprlock";
            ".config/wlogout".source = "${configDir}/wlogout";
            ".config/waybar".source = "${configDir}/waybar";
            ".config/wofi".source = "${configDir}/wofi";
            ".config/mako".source = "${configDir}/mako";
        };
    };
}

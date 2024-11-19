# { config, lib, pkgs, ... }: {
#   # This will install Discord PTB for all users of the system
#   environment.systemPackages = with pkgs; [
#     discord-ptb
#   ];
# }

{
    config,
    lib,
    pkgs,
    attrs,
    home-manager,
    username,
    ...
}: {

    home-manager.sharedModules = [
        attrs.nixcord.homeManagerModules.nixcord
    ];

    home-manager.users.${username} = _: {
        programs.nixcord = {
            enable = true;

            discord = {
                enable = false;   # Don't install Discord, using vencord instead
                vencord = {
                    package = pkgs.vencord;    # Must do this for 24.05
                    enable = true;
                };
                openASAR.enable = false;
            };
        
            vesktop.enable = true;

            config = {
                #useQuickCss = true;   # use out quickCSS
                themeLinks = [
                    "https://discordstyles.github.io/DarkMatter/DarkMatter.theme.css"
                    "https://raw.githubusercontent.com/KillYoy/DiscordNight/master/DiscordNight.theme.css"
                    "https://capnkitten.github.io/BetterDiscord/Themes/Spotify-Discord/css/source.css"

                ];
                frameless = true; # set some Vencord options
                plugins = {
                    alwaysAnimate.enable = true;
                    hideAttachments.enable = true; 
                    ignoreActivities = {    # Enable a plugin and set some options
                        enable = true;
                        ignorePlaying = true;
                        ignoreWatching = true;
                        #ignoredActivities = [ "someActivity" ];
                    };
                    betterSessions = {
                        enable = true;
                        backgroundCheck = true;
                    };
                    betterSettings = {
                        enable = true;
                        organizeMenu = true;
                        eagerLoad = true;
                    };
                    biggerStreamPreview.enable = true;
                    clearURLs.enable = true;
                    ctrlEnterSend = {
                        enable = true;
                        submitRule = "ctrl+enter";
                        sendMessageInTheMiddleOfACodeBlock = true;
                    };
                    fakeNitro = {
                        enable = true;      # Allow streaming in nitro quality and send fake emojis/stickers
                    };
                    fixImagesQuality.enable = true;     # Loads images in original quality rather than webp
                    fixSpotifyEmbeds = {
                        enable = true;
                        volume = 5.0;       # This is percentage of volume, avoid going over 10%
                    };
                    fixYoutubeEmbeds.enable = true;
                    friendsSince.enable = true;
                    fullSearchContext.enable = true;
                    memberCount.enable = true;
                    messageLogger = {
                        enable = true;
                    };
                    noDevtoolsWarning.enable = true;
                    openInApp = {
                        enable = true;
                        spotify = true;
                        steam = true;
                    };
                    reverseImageSearch.enable = true;
                    volumeBooster = {
                        enable = true;
                        multiplier = 2;       # This is a multiplier, 1 is system's 100%
                    };
                    youtubeAdblock.enable = true;
                    webScreenShareFixes.enable = true;
                };
            };
        };
    };
}

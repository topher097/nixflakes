
{ 
  pkgs, 
  username,
  home-manager,
  ... 
}:
{
    home-manager.users.${username}.programs.mpv = {
        enable = true;

        package = (
            pkgs.mpv-unwrapped.wrapper {
            scripts = with pkgs.mpvScripts; [
                uosc
                sponsorblock
            ];

            mpv = pkgs.mpv-unwrapped.override {
                waylandSupport = true;
                ffmpeg = pkgs.ffmpeg-full;
            };
            }
        );

        config = {
            #"profile" = "high-quality";
            "force-window" = true;
            "ytdl-format" = "bestvideo+bestaudio";
            "cache-default" = 4000000;
            "osd-status-msg" = "\${playback-time/full} / \${duration} (\${percent-pos}%)\nframe: \${estimated-frame-number} / \${estimated-frame-count}";
        };
    };
}

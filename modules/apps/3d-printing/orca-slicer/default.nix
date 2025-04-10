{
    pkgs,
    ...
}: {
    environment.systemPackages = with pkgs; [
        orca-slicer
        virtualgl
    ];

    # Need to launch orca sclier using the following command due to graphics driver issues:
    #  DISPLAY=:0 vglrun orca-slicer
    environment.shellAliases = {
        os = "DISPLAY=:0 vglrun orca-slicer";
    };

}
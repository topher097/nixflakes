{
    pkgs,
    ...
}: {
    environment.systemPackages = with pkgs; [
        unstable.inkscape-with-extensions
    ];
}
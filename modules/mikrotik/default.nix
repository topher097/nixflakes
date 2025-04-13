{
    pkgs,
    ...
}:
{
    environment.systemPackages = with pkgs; [
        winbox
    ];
}

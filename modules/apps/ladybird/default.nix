{
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    unstable.ladybird
  ];

  programs.ladybird = {
    enable = true;
    # Set the default browser to Ladybird
    # defaultBrowser = true;
  };
}
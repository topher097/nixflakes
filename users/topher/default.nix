{
  pkgs,
  username,
  home-manager,
  ...
}: {
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${username} = {
    shell = pkgs.fish;    # Default shell is fish
    isNormalUser = true;
    initialPassword = "temp123";
    extraGroups = [
      "wheel"   # For sudo
      "input"
      "video"   # nvidia driver with video enabled
      "render"  # nvidia driver with rendering enabled
      "compute" # nvidia driver with compute enabled
    ];
  };

  # Setup global git user and email
  home-manager.users.${username}.programs.git = {
    userName = "topher097";
    userEmail = "cmendres400@gmail.com";
  };
}

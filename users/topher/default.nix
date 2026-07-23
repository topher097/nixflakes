{
  pkgs,
  username,
  home-manager,
  ...
}: {
  # Define a user account. Don't forget to set a password with 'passwd'.
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

  # Passwordless sudo for nixos-rebuild activation
  security.sudo.extraRules = [
    {
      users = [ username ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  # Setup global git user and email
  home-manager.users.${username}.programs.git.settings = {
    user = {
      name = "topher097";
      email = "cmendres400@gmail.com";
    };
  };
}

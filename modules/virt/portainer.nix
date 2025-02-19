# LINK: https://gitlab.com/cbleslie/portainer-on-nixos

{
  portainer-on-nixos,
  ...
}: 
{
  imports = [
    portainer-on-nixos.nixosModules.portainer
  ];

  # example that shows all default the portainer options
  services.portainer = {
    enable = true; # Default false

    version = "latest"; # Default latest, you can check dockerhub for
                        # other tags.

    openFirewall = true; # Default false, set to 'true' if you want
                            # to be able to access via the port on
                            # something other than localhost. 

    port = 9443; # Sets the port number in both the firewall and
                # the docker container port mapping itself.
  };

}
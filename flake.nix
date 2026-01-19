{
  description = "topher's machine specific configuration flake.";

  inputs = {
    #nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

    # You can access packages and modules from different nixpkgs revs
    # at the same time. Here's an working example:
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    # Also see the 'unstable-packages' overlay at 'overlays/default.nix'.

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.darwin.follows = "";
    };

    hyprland = {
      url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    };

    hyprlock = {
      url = "github:hyprwm/hyprlock";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprpicker = {
      url = "github:hyprwm/hyprpicker";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    eriixpkgs = {
      url = "github:erictossell/eriixpkgs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    tophpkgs = {
      url = "github:topher097/tophpkgs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    NixOS-WSL = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      #url = "github:danth/stylix";
      url = "github:nix-community/stylix/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Env file system
    envfs = {
      url = "github:Mic92/envfs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Weekly updated nix-index database.
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Nix User Repository
    nur = {
      url = "github:nix-community/NUR";
    };

    # Orca slicer
    orca-slicer = {
      url = "github:ovlach/nix-orca-slicer";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Nixcord
    nixcord = {
      url = "github:kaylorben/nixcord";
      #inputs.nixpkgs.follows = "nixpkgs";
    };

    # Portainer
    portainer-on-nixos = {
      url = "gitlab:cbleslie/portainer-on-nixos";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # MicroVM
    microvm = {
      url = "github:astro/microvm.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
  };

  outputs =
    {
      self,
      tophpkgs,
      nixpkgs,
      envfs,
      home-manager,
      nur,
      microvm,
      ...
    } @ attrs:
    let
      inherit (self) outputs;
      supportedSystems = [ "x86_64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      nixpkgsFor = forAllSystems (system: import nixpkgs { 
        inherit system; 
        config = {
          allowUnfree = true;
        }; 
      });
    in
    {
      # Your custom packages
      # Accessible through 'nix build', 'nix shell', etc
      packages = forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});

      # Your custom packages and modifications, exported as overlays
      overlays = import ./overlays { inherit attrs; };

      nixosConfigurations = {

        # windows-11 =
        #   nixpkgs.lib.nixosSystem {
        #     specialArgs = {
        #       username = "topher";
        #       hostName = "windows-11";
        #       #hyprlandConfig = "laptop";
        #       #DE = "gnome";
        #       inherit outputs attrs;
        #     } // attrs;
        #     system = "x86_64-linux";
        #     modules = [
        #       # Include the microvm module
        #       microvm.nixosModules.microvm
        #       # Add more modules here
        #       {
                
        #         networking.hostName = "windows-11";
        #         microvm = {
        #           user = "topher";
        #           mem = "10000";  # 10GB
        #           vcpu = "4";
        #           hypervisor = "cloud-hypervisor";
        #        };
        #       }
        #     ];
        #   }; # windows-11

        pgi-desktop =
          let
            system = "x86_64-linux";
          in
          nixpkgs.lib.nixosSystem {
            specialArgs = {
              username = "topher";
              hostName = "pgi-desktop";
              hyprlandConfig = "desktop";
              DE = "hyprland";
              inherit system outputs attrs;
            } // attrs;
            modules = [
              ./.
              ./modules/apps/ms-teams     # teams-for-linux
              ./modules/hardware/nvidia   # Nvidia hardware
              ./modules/virt              # Virtualization tools
              #./modules/virt/portainer.nix    # Portainer docker auto run
              ./modules/apps/3d-printing  # 3D printing tools
            ];
          }; # pgi-desktop 


        topher-laptop =
          let
            system = "x86_64-linux";
          in
          nixpkgs.lib.nixosSystem {
            specialArgs = {
              username = "topher";
              hostName = "topher-laptop";
              hyprlandConfig = "laptop";
              DE = "gnome";
              inherit system outputs attrs;
            } // attrs;
            modules = [
              ./.
              ./modules/apps/ms-teams     # teams-for-linux
              ./modules/hardware/nvidia   # Nvidia hardware
              ./modules/virt              # Virtualization tools
            ];
          }; # topher-laptop

        live-image =
          let
            system = "x86_64-linux";
          in
          nixpkgs.lib.nixosSystem {
            inherit system;
            specialArgs = {
              username = "nixos";
              hostName = "live-image";
              hyprlandConfig = "laptop";
              inherit system outputs attrs;
            } // attrs;
            modules = [ ./minimal.nix ];
          }; # live-image

        winix =
          let
            system = "x86_64-linux";
          in
          nixpkgs.lib.nixosSystem {
            inherit system;
            specialArgs = {
              username = "topher";
              hostName = "winix-pgi-laptop";
              inherit system outputs attrs;
            } // attrs;
            modules = [ 
              ./wsl.nix 
              {
                wsl.enable = true;
              }
              home-manager.nixosModules.home-manager {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.users.topher = import ./home.nix;
              }
            ];
          }; # winix

      };

      # All systems/hosts get these packages installed
      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgsFor.${system};
        in
        {
          default = pkgs.mkShell {    # Can use mkShellNoCC, but do more research on that...
            buildInputs = with pkgs; [
              nixfmt
              statix
              #tophvim.nixosModules.${system}.default
            ];

            # shellHook = ''
            #   if [[ "$TERM_PROGRAM" == "ghostty" ]]; then
            #     export TERM=xterm-256color
            #   fi
            #   export NIXPKGS_ALLOW_UNFREE=1
            #   export EZA_COLORS = "da=1;34:gm=1;34:Su=1;34";
            # '';
          };
        }
      );

      templates.default = {
        path = ./.;
        description = "The default template for topher's nixflakes.";
      }; # templates

      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt-rfc-style;
    };
}

{
  description = "My simple NixOS flake"; # come up with better descriptiom

  inputs = {
    # NixOS official package source
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    # home-manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dms = {
      url = "github:AvengeMedia/DankMaterialShell/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-stable,
    home-manager,
    stylix,
    nixos-hardware,
    dms,
    niri,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    user = "kmc";
  in {
    # system hostname

    nixosConfigurations.z4 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {
        pkgs-stable = import nixpkgs-stable {
          inherit system;
          config.allowUnfree = true;
        };
        inherit inputs system;
      };
      modules = [
        ./nixos/hosts/z4/configuration.nix
        stylix.nixosModules.stylix
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.${user} = ./home-manager/home.nix;
            backupFileExtension = "backup";

            extraSpecialArgs = {inherit inputs user dms niri;};
          };
        }  # 1. Enable Stylix here ONLY



      ];
    };

    nixosConfigurations.t14 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {
        pkgs-stable = import nixpkgs-stable {
          inherit system;
          config.allowUnfree = true;
        };
        inherit inputs system;
      };
      modules = [
        ./nixos/hosts/laptop/configuration.nix
        nixos-hardware.nixosModules.lenovo-thinkpad-t14-amd-gen5
        stylix.nixosModules.stylix
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.${user} = ./home-manager/home.nix;
            backupFileExtension = "backup";

            extraSpecialArgs = {inherit inputs user dms niri;};
          };
        }
      ];
    };
  };
}

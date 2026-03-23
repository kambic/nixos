{
  description = "A simple NixOS flake";

  inputs = {
    # NixOS official package source, using the nixos-25.11 branch here
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
 
    stylix = {
          url = "github:danth/stylix/release-25.11";
      # url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = { self, nixpkgs, nixos-hardware, stylix,  ... }@inputs: {

    nixosConfigurations.nixer = nixpkgs.lib.nixosSystem {
      modules = [
        stylix.nixosModules.stylix
        nixos-hardware.nixosModules.lenovo-thinkpad-t14-amd-gen5
        ./hosts/laptop/configuration.nix
      ];
    };


    nixosConfigurations.z4 = nixpkgs.lib.nixosSystem {
      modules = [
        # Import the previous configuration.nix we used,
        # so the old configuration file still takes effect
        stylix.nixosModules.stylix
        
        ./hosts/z4/configuration.nix
      ];
    };
  };
}

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
  system = "x86_64-linux";   # 👈 REQUIRED
  modules = [
    stylix.nixosModules.stylix
    nixos-hardware.nixosModules.lenovo-thinkpad-t14-amd-gen5
    ./hosts/laptop/configuration.nix
  ];
};

nixosConfigurations.z4 = nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";   # 👈 REQUIRED
  specialArgs = { inherit inputs; };
  modules = [
    stylix.nixosModules.stylix
    ./hosts/z4/configuration.nix
  ];
};
  };
}

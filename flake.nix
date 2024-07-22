{
  description = "Jans's NixOS Flake";

  nixConfig = {
    experimental-features = ["nix-command" "flakes"];

    extra-substituters = [
      # Nix community's cache server
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    impermanence.url = "github:nix-community/impermanence";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    home-manager,
    impermanence,
    ...
  } @ inputs: let
    inherit (self) outputs;
    system = "x86_64-linux";
    mkNixosConfig = name: user:
      nixpkgs.lib.nixosSystem {
        system = system;
        modules = [
          {_module.args = {inherit inputs;};}
          ./hosts/${name}/configuration.nix
          impermanence.nixosModules.impermanence
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = {inherit inputs outputs;};
              users.${user}.imports = [./hosts/${name}/home.nix];
            };
          }
        ];
      };
  in {
    nixosConfigurations = {
      gnome_laptop = mkNixosConfig "gnome_laptop" "jan";
      server = mkNixosConfig "server" "test";
    };
  };
}

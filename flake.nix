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
    # Official NixOS package source, using nixos-unstable branch here
    # nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-23.05";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    # microvm.url = "github:astro/microvm.nix";
    # microvm.inputs.nixpkgs.follows = "nixpkgs";

    impermanence.url = "github:nix-community/impermanence";

    # home-manager, used for managing user configuration
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      # url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    home-manager,
    nur,
    impermanence,
    # microvm,
    ...
  } @ inputs: let
    inherit (self) outputs;
    system = "x86_64-linux";
  in {
    nixosConfigurations = {
      "gnome_laptop" = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs outputs;
        };
        modules = [
          # Nix User Repo
          {nixpkgs.overlays = [nur.overlay];}
          ({pkgs, ...}: let
            nur-no-pkgs = import nur {
              nurpkgs = import nixpkgs {system = "x86_64-linux";};
            };
          in {
            imports = [nur-no-pkgs.repos.iopq.modules.xraya];
            services.xraya.enable = true;
          })
          {_module.args = {inherit inputs;};}
          # Classic NixOS Configuration
          ./hosts/gnome_laptop/configuration.nix

          # microvm.nixosModules.host

          impermanence.nixosModules.impermanence

          # home-manager
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = {
                inherit inputs outputs;
              };
              users.jan.imports = [
                ./hosts/gnome_laptop/home.nix
              ];
            };
          }
        ];
      };

      "server" = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs outputs;
        };
        modules = [
          # Nix User Repo
          {nixpkgs.overlays = [nur.overlay];}
          ({pkgs, ...}: let
            nur-no-pkgs = import nur {
              nurpkgs = import nixpkgs {system = "x86_64-linux";};
            };
          in {
            imports = [nur-no-pkgs.repos.iopq.modules.xraya];
            services.xraya.enable = true;
          })
          # Classic NixOS Configuration
          ./hosts/server/configuration.nix

          # microvm.nixosModules.host

          # impermanence.nixosModules.impermanence

          # home-manager
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = {
                inherit inputs outputs;
              };
              users.test.imports = [
                ./hosts/server/home.nix
              ];
            };
          }
        ];
      };
    };
  };
}

{
  description = "Jans's NixOS Flake";

  nixConfig = {
    experimental-features = [ "nix-command" "flakes" ];
    #    substituters = [
    #      # Replace the official cache with a mirror located in China
    #      "https://mirrors.ustc.edu.cn/nix-channels/store"
    #      "https://cache.nixos.org/"
    #  ];

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
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-23.05";

    # Nix User Repo
    nur.url = "github:nix-community/NUR";

    # home-manager, used for managing user configuration
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      # If you are not running an unstable channel of nixpkgs, select the corresponding branch of nixvim.
      # url = "github:nix-community/nixvim/nixos-23.05";

      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland.url = "github:hyprwm/Hyprland";

    ironbar = {
      url = "github:JakeStanger/ironbar";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-stable, home-manager, nur, nixvim, hyprland
    , ... }@inputs:
    let inherit (self) outputs;
    in {
      nixosConfigurations = {
        "jans-nixos" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs outputs; };
          modules = [

            # Nix User Repo
            { nixpkgs.overlays = [ nur.overlay ]; }
            ({ pkgs, ... }:
              let
                nur-no-pkgs = import nur {
                  nurpkgs = import nixpkgs { system = "x86_64-linux"; };
                };
              in {
                imports = [ nur-no-pkgs.repos.iopq.modules.xraya ];
                services.xraya.enable = true;
              })

            # Classic NixOS Configuration
            ./nixos/configuration.nix

            # home-manager
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = { inherit inputs outputs; };
                users.jan.imports = [
                  ./home-manager/home.nix
                  nixvim.homeManagerModules.nixvim
                  hyprland.homeManagerModules.default
                  { wayland.windowManager.hyprland.enable = true; }
                  inputs.ironbar.homeManagerModules.default
                ];
              };
            }
          ];
        };
      };

    };
}

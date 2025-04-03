{
  description = "Jan's NixOS, Home Manager & Nix-on-Droid Configuration";

  nixConfig = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    extra-substituters = [
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    # System modules
    impermanence.url = "github:nix-community/impermanence";
    agenix.url = "github:ryantm/agenix";

    # User configurations
    nixvim-config.url = "github:JvandeLocht/nixvim-config";
    nvf.url = "github:JvandeLocht/nvf-config";
    zen-browser.url = "github:0xc000022070/zen-browser-flake";
    fcitx-virtual-keyboard-adapter = {
      url = "github:horriblename/fcitx-virtualkeyboard-adapter";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager-unstable = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Nix-on-Droid
    nix-on-droid = {
      url = "github:nix-community/nix-on-droid";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    nixpkgs-unstable,
    home-manager,
    home-manager-unstable,
    impermanence,
    nvf,
    agenix,
    nix-on-droid,
    ...
  }: let
    inherit (self) outputs;
    x86System = "x86_64-linux";
    armSystem = "aarch64-linux";
    pkgs-unstable = nixpkgs-unstable.legacyPackages.x86_64-linux;

    mkNixosConfig = name: user:
      nixpkgs-unstable.lib.nixosSystem {
        system = x86System;
        modules = [
          {
            nixpkgs.overlays = [
              (final: _prev: {nvf = nvf.packages.${_prev.system}.default;})
              (final: prev: {
                wvkbd = prev.wvkbd.overrideAttrs (oldAttrs: {
                  patches = (oldAttrs.patches or []) ++ [./patches/switchYandZ.patch];
                });
              })
              (final: prev: {
                spotube = prev.spotube.overrideAttrs (oldAttrs: {
                  version = "4.0.2";
                });
              })
            ];
          }
          {_module.args = {inherit inputs outputs;};}
          ./hosts/${name}/configuration.nix
          impermanence.nixosModules.impermanence
          home-manager-unstable.nixosModules.home-manager
          agenix.nixosModules.default
          {
            home-manager = {
              useGlobalPkgs = true;
              extraSpecialArgs = {inherit inputs outputs;};
              users.${user} = {
                imports = [./hosts/${name}/home.nix];
              };
              backupFileExtension = "backup";
            };
          }
        ];
      };
  in {
    nixosConfigurations = {
      groot = mkNixosConfig "groot" "jan";
      nixnas = mkNixosConfig "nixnas" "jan";
    };

    homeConfigurations."jan" = home-manager-unstable.lib.homeManagerConfiguration {
      pkgs = pkgs-unstable;
      extraSpecialArgs = {inherit inputs outputs;};
      modules = [
        ./hosts/man/home.nix
        {nixpkgs.overlays = [(final: _prev: {nvf = nvf.packages.${_prev.system}.default;})];}
      ];
    };

    nixOnDroidConfigurations.default = nix-on-droid.lib.nixOnDroidConfiguration {
      modules = [./hosts/nixdroid/nix-on-droid.nix];
      pkgs = import nixpkgs {
        system = armSystem;
        overlays = [
          nix-on-droid.overlays.default
          (final: _prev: {nvf = nvf.packages.${_prev.system}.default;})
        ];
      };
      home-manager-path = home-manager.outPath;
    };
  };
}

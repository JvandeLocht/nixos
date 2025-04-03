{
  description = "Jan's NixOS & Home Manager Configuration";

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
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      home-manager,
      home-manager-unstable,
      impermanence,
      nvf,
      agenix,
      ...
    }@inputs:
    let
      inherit (self) outputs;
      system = "x86_64-linux";
      pkgs-unstable = nixpkgs-unstable.legacyPackages.${system};

      # NixOS configuration builder
      mkNixosConfig =
        name: user:
        nixpkgs-unstable.lib.nixosSystem {
          inherit system;
          modules = [
            {
              nixpkgs.overlays = [
                (final: _prev: {
                  nvf = nvf.packages.${_prev.system}.default;
                })
                (final: prev: {
                  wvkbd = prev.wvkbd.overrideAttrs (oldAttrs: {
                    patches = (oldAttrs.patches or [ ]) ++ [ ./patches/switchYandZ.patch ];
                  });
                })
                (final: prev: {
                  spotube = prev.spotube.overrideAttrs (oldAttrs: {
                    version = "4.0.2";
                  });
                })
              ];
            }
            { _module.args = { inherit inputs outputs; }; }
            ./hosts/${name}/configuration.nix
            impermanence.nixosModules.impermanence
            home-manager-unstable.nixosModules.home-manager
            agenix.nixosModules.default
            {
              home-manager = {
                useGlobalPkgs = true;
                extraSpecialArgs = { inherit inputs outputs; };
                users.${user} = {
                  imports = [ ./hosts/${name}/home.nix ];
                };
                backupFileExtension = "backup";
              };
            }
          ];
        };

    in
    {
      nixosConfigurations = {
        groot = mkNixosConfig "groot" "jan";
        nixnas = mkNixosConfig "nixnas" "jan";
      };

      homeConfigurations."jan" = home-manager-unstable.lib.homeManagerConfiguration {
        pkgs = pkgs-unstable;
        extraSpecialArgs = { inherit inputs outputs; };
        modules = [
          ./hosts/man/home.nix
          {
            nixpkgs.overlays = [
              (final: _prev: {
                nvf = nvf.packages.${_prev.system}.default;
              })
            ];
          }
        ];
      };
    };
}

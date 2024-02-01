{
  description = "Jans's NixOS Flake";

  nixConfig = {
    experimental-features = ["nix-command" "flakes"];
    #    substituters = [
    #      # Replace the official cache with a mirror located in China
    #      "https://mirrors.ustc.edu.cn/nix-channels/store"
    #      "https://cache.nixos.org/"
    #  ];

    extra-substituters = [
      # Nix community's cache server
      "https://nix-community.cachix.org"
      # "https://app.cachix.org/cache/cuda-maintainers"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      # "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
    ];
  };

  inputs = {
    # Official NixOS package source, using nixos-unstable branch here
    #    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-23.05";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    #nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Nix User Repo
    nur.url = "github:nix-community/NUR";

    # home-manager, used for managing user configuration
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix.url = "github:Mic92/sops-nix";

    nixneovimplugins.url = "github:jooooscha/nixpkgs-vim-extra-plugins";

    #    nixvim = {
    #      url = "github:nix-community/nixvim";
    # If you are not running an unstable channel of nixpkgs, select the corresponding branch of nixvim.
    # url = "github:nix-community/nixvim/nixos-23.05";

    #      inputs.nixpkgs.follows = "nixpkgs";
    #    };

    #    hyprland.url = "github:hyprwm/Hyprland";
    #    hyprgrass = {
    #      url = "github:horriblename/hyprgrass";
    #      inputs.hyprland.follows = "hyprland"; # IMPORTANT
    #    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nur,
    sops-nix,
    nixneovimplugins,
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

          {
            nixpkgs.overlays = [
              inputs.nixneovimplugins.overlays.default
            ];
          }

          # Classic NixOS Configuration
          ./hosts/gnome_laptop/configuration.nix

          # Secret Managment
          sops-nix.nixosModules.sops

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
                #                  nixvim.homeManagerModules.nixvim
              ];
            };
          }
        ];
      };
    };
  };
}

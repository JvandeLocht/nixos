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
    flake-utils.url = "github:numtide/flake-utils";
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    doomemacs = {
      url = "github:doomemacs/doomemacs";
      flake = false;
    };
    emacs-overlay = {
      url = "github:nix-community/emacs-overlay";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # System modules
    impermanence = {
      url = "github:nix-community/impermanence";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    hyprland = {
      url = "github:hyprwm/Hyprland";
    };

    # User configurations
    nvf = {
      url = "github:JvandeLocht/nvf-config";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    fcitx-virtual-keyboard-adapter = {
      url = "github:horriblename/fcitx-virtualkeyboard-adapter";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    copyparty.url = "github:9001/copyparty";

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

  outputs =
    inputs@{
      self,
      nixpkgs,
      nixpkgs-unstable,
      flake-utils,
      home-manager,
      home-manager-unstable,
      impermanence,
      nvf,
      sops-nix,
      nix-on-droid,
      copyparty,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        pkgs-unstable = nixpkgs-unstable.legacyPackages.${system};
      in
      {
        # Per-system outputs can go here if needed
        # devShells.default = pkgs.mkShell { ... };
        # packages = { ... };
      }
    )
    // (
      let
        inherit (self) outputs;

        # Common overlays to be reused across all configurations
        commonOverlays = import ./overlays inputs;

        # Common special args for all configurations
        specialArgs = { inherit inputs outputs; };

        mkNixosConfig = import ./lib/mkNixosConfig.nix {
          inherit
            inputs
            impermanence
            sops-nix
            home-manager-unstable
            commonOverlays
            specialArgs
            ;
        };
      in
      {
        nixosConfigurations = {
          groot = mkNixosConfig {
            system = "x86_64-linux";
            hostname = "groot";
            username = "jan";
            extraOverlays = [
              (import ./overlays/wvkbd.nix inputs)
            ];
          };

          nixnas = mkNixosConfig {
            system = "x86_64-linux";
            hostname = "nixnas";
            username = "jan";
            extraModules = [
              # load the copyparty NixOS module
              copyparty.nixosModules.default
              (
                { pkgs, ... }:
                {
                  # add the copyparty overlay to expose the package to the module
                  nixpkgs.overlays = [ copyparty.overlays.default ];
                  # (optional) install the package globally
                  environment.systemPackages = [ pkgs.copyparty ];
                  # configure the copyparty module
                  services.copyparty.enable = true;
                }
              )
            ];
          };

          nixwsl = mkNixosConfig {
            system = "x86_64-linux";
            hostname = "nixwsl";
            username = "jan";
            extraModules = [ inputs.nixos-wsl.nixosModules.default ];
          };
        };

        homeConfigurations = {
          default = self.homeConfigurations.jan;
          jan = home-manager-unstable.lib.homeManagerConfiguration {
            pkgs = nixpkgs-unstable.legacyPackages.x86_64-linux;
            extraSpecialArgs = specialArgs;
            modules = [
              ./hosts/man/home.nix
              { nixpkgs.overlays = commonOverlays; }
            ];
          };
        };

        nixOnDroidConfigurations.default = nix-on-droid.lib.nixOnDroidConfiguration {
          modules = [ ./hosts/nixdroid/nix-on-droid.nix ];
          pkgs = import nixpkgs {
            system = "aarch64-linux";
            overlays = [
              nix-on-droid.overlays.default
            ]
            ++ commonOverlays;
          };
          home-manager-path = home-manager.outPath;
          extraSpecialArgs = specialArgs;
        };
      }
    );
}

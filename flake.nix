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
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    certs = {
      url = "/etc/nixos";
      flake = false;
    };

    doomemacs = {
      url = "github:doomemacs/doomemacs";
      flake = false;
    };
    emacs-overlay.url = "github:nix-community/emacs-overlay";

    # System modules
    impermanence.url = "github:nix-community/impermanence";
    agenix.url = "github:ryantm/agenix";
    hyprland.url = "github:hyprwm/Hyprland";

    # User configurations
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

  outputs =
    inputs@{
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
    }:
    let
      inherit (self) outputs;
      x86System = "x86_64-linux";
      armSystem = "aarch64-linux";
      pkgs-unstable = nixpkgs-unstable.legacyPackages.x86_64-linux;

      # Common special args for all configurations
      specialArgs = { inherit inputs outputs; };

      # Common overlays to be reused
      commonOverlays = [
        (final: _prev: { nvf = nvf.packages.${_prev.system}.default; })
        inputs.emacs-overlay.overlays.default
        (self: super: {
          st = super.st.overrideAttrs (oldAttrs: {
            patches = (oldAttrs.patches or [ ]) ++ [
              (super.fetchpatch {
                url = "https://st.suckless.org/patches/glyph_wide_support/st-glyph-wide-support-20220411-ef05519.diff";
                sha256 = "sha256-nGVswWAJhIhHq0s6+hiVaKLkYKog1mEhBUsLzJjzN+g=";
              })
              (super.fetchpatch {
                url = "https://st.suckless.org/patches/defaultfontsize/st-defaultfontsize-20210225-4ef0cbd.diff";
                sha256 = "sha256-CPtmRUPqcyY1j8jGUI3FywDJ26+xgRDZjx+oTewI8AQ=";
              })
              (super.fetchpatch {
                url = "https://st.suckless.org/patches/anygeometry/st-anygeometry-0.8.1.diff";
                sha256 = "sha256-mxxRKzkKg7dIQBYq5qYLwlf77XNN4waazr4EnC1pwNE=";
              })
              (super.fetchpatch {
                url = "https://st.suckless.org/patches/gruvbox/st-gruvbox-dark-0.8.5.diff";
                sha256 = "sha256-dOkrjXGxFgIRy4n9g2RQjd8EBAvpW4tNmkOVj4TaFGg=";
              })
            ];
          });
        })
      ];

      mkNixosConfig = import ./lib/mkNixosConfig.nix {
        inherit
          inputs
          impermanence
          agenix
          home-manager-unstable
          commonOverlays
          specialArgs
          ;
      };
    in
    {
      nixosConfigurations = {
        groot = mkNixosConfig {
          system = x86System;
          hostname = "groot";
          username = "jan";
          extraOverlays = [
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
        };

        nixnas = mkNixosConfig {
          system = x86System;
          hostname = "nixnas";
          username = "jan";
        };

        nixwsl = mkNixosConfig {
          system = x86System;
          hostname = "nixwsl";
          username = "jan";
          extraModules = [ inputs.nixos-wsl.nixosModules.default ];
        };
      };

      homeConfigurations = {
        default = self.homeConfigurations.jan;
        backupFileExtension = "backup";
        jan = home-manager-unstable.lib.homeManagerConfiguration {
          pkgs = pkgs-unstable;
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
          system = armSystem;
          overlays = [
            nix-on-droid.overlays.default
          ] ++ commonOverlays;
        };
        home-manager-path = home-manager.outPath;
      };
    };
}

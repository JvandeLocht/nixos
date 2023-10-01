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
    nixpkgs.url = "github:NixOS/nixpkgs/release-23.05";

    # home-manager, used for managing user configuration
    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    astronvim = {
      flake = false;
      url = "git+https://github.com/AstroNvim/AstroNvim?submodules=1";
    };

  };
  outputs = { self, nixpkgs, home-manager,  ... }@inputs: {
    nixosConfigurations = {
      "jans-nixos" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
	      specialArgs = inputs;
        modules = [
          ./configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            home-manager.users.jan = import ./home.nix;
          }
        ];
      };
    };
  };
}


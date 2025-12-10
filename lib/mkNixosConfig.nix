{
  inputs,
  impermanence,
  sops-nix,
  home-manager-unstable,
  commonOverlays,
  specialArgs,
}:
{
  system,
  hostname,
  username,
  extraOverlays ? [ ],
  extraModules ? [ ],
  additionalHomeManagerModules ? [ ],
}:
let
  pkgs-unstable = inputs.nixpkgs-unstable.legacyPackages.${system};
in
inputs.nixpkgs-unstable.lib.nixosSystem {
  inherit system;
  modules = [
    {
      nixpkgs.overlays = commonOverlays ++ extraOverlays;
    }
    {
      _module.args = specialArgs // {
        inherit pkgs-unstable;
      };
    }
    ../hosts/${hostname}/configuration.nix
    impermanence.nixosModules.impermanence
    home-manager-unstable.nixosModules.home-manager
    sops-nix.nixosModules.sops
    {
      home-manager = {
        useGlobalPkgs = true;
        extraSpecialArgs = specialArgs // {
          inherit pkgs-unstable;
        };
        users.${username} = {
          imports = [ ../hosts/${hostname}/home.nix ] ++ additionalHomeManagerModules;
        };
        backupFileExtension = "backup";
      };
    }
  ]
  ++ extraModules;
}

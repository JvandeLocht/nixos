{
  inputs,
  impermanence,
  agenix,
  sops-nix,
  home-manager-unstable,
  commonOverlays,
  specialArgs,
}: {
  system,
  hostname,
  username,
  extraOverlays ? [],
  extraModules ? [],
}:
let
  pkgs-unstable = inputs.nixpkgs-unstable.legacyPackages.${system};
in
inputs.nixpkgs-unstable.lib.nixosSystem {
  inherit system;
  modules =
    [
      {
        nixpkgs.overlays = commonOverlays ++ extraOverlays;
      }
      {_module.args = specialArgs // { inherit pkgs-unstable; };}
      ../hosts/${hostname}/configuration.nix
      impermanence.nixosModules.impermanence
      home-manager-unstable.nixosModules.home-manager
      agenix.nixosModules.default
      sops-nix.nixosModules.sops
      {
        home-manager = {
          useGlobalPkgs = true;
          extraSpecialArgs = specialArgs // { inherit pkgs-unstable; };
          users.${username} = {
            imports = [../hosts/${hostname}/home.nix];
          };
          backupFileExtension = "backup";
        };
      }
    ]
    ++ extraModules;
}

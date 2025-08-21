{
  lib,
  config,
  ...
}:
{
  options.nix-settings = {
    enable = lib.mkEnableOption "Common nix settings";
    maxJobs = lib.mkOption {
      type = lib.types.oneOf [lib.types.str lib.types.ints.positive];
      default = "auto";
      description = "Maximum number of parallel build jobs";
    };
  };

  config = lib.mkIf config.nix-settings.enable {
    nix.settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      trusted-users = [ "jan" ];
      auto-optimise-store = true;
      max-jobs = config.nix-settings.maxJobs;
      builders-use-substitutes = true;
    };
  };
}
{ pkgs, ... }: {
  imports = [ ./config.nix ];
  programs.ironbar = {
    enable = true;
    style = let
      built = pkgs.callPackage ./scss-pkg.nix {
        src = ./styles;
        entry = "main";
      };
    in ''
      @import url("${built}/out.css");
    '';
    # package = inputs.ironbar;
    # features = [ "feature" "another_feature" ];
  };
}

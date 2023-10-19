{ pkgs, ... }:
let
  vars = {
    # Variables Used In Flake
    user = "jan";
    homeDir = "/home/jan";
    location = "$HOME/.setup";
    terminal = "alacritty";
    editor = "nvim";
  };
in {
  programs.swaylock = {
    enable = true;
    package = pkgs.swaylock-effects;
    settings = {
      clock = true;
      font-size = 24;
      indicator-idle-visible = false;
      indicator-radius = 100;
      line-color = "ffffff";
      show-failed-attempts = true;
      image = "${vars.location}/img/nixos_wallpaper.jpg";
      effect-blur = "7x5";
      effect-vignette = "0.5:0.5";
      grace = 2;
      fade-in = 0.2;
      daemonize = true;
    };
  };
}

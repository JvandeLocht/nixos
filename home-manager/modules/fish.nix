{
  lib,
  config,
  pkgs,
  ...
}: {
  options.fish = {
    enable = lib.mkEnableOption "Custom Fish shell configuration";
  };

  config = lib.mkIf config.fish.enable {
    home.packages = with pkgs; [
      fishPlugins.z
      grc # for fish
      upower
      nix-output-monitor
    ];

    programs.fish = {
      enable = true;
      interactiveShellInit = ''
        set fish_greeting # Disable greeting
      '';
      plugins = [
        # Enable a plugin (here grc for colorized command output) from nixpkgs
        {
          name = "grc";
          src = pkgs.fishPlugins.grc.src;
        }
      ];
      shellAliases = {
        p = "upower -i /org/freedesktop/UPower/devices/battery_BAT0";
        ng = "sudo nixos-rebuild switch --log-format internal-json -v --flake ~/.setup#gnome_laptop &| nom --json";
        ngt = "sudo nixos-rebuild test --log-format internal-json -v --flake ~/.setup#gnome_laptop &| nom --json";
        j = "z";
        k = "kubectl";
        t = "zellij";
        st = "ssh admin@192.168.178.40";
      };
    };
  };
}

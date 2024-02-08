{pkgs, ...}: {
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
      sj = "kitten ssh jan@192.168.178.40";
      sa = "kitten ssh ae@192.168.178.40";
    };
  };
}

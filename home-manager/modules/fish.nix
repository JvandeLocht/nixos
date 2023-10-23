{ pkgs, ... }: {
  home.packages = (with pkgs; [
    fishPlugins.z
    grc # for fish
    upower
  ]);

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
      nr = "sudo nixos-rebuild switch --flake ~/.setup#jans-nixos";
      j = "z";
      sj = "ssh jan@192.168.178.40";
      sa = "ssh ae@192.168.178.40";
    };
  };

}

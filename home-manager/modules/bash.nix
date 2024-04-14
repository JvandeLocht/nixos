{pkgs, ...}: {
  home.packages = with pkgs; [
    upower
    nix-output-monitor
  ];

  programs.bash = {
    blesh.enable = true;
    shellAliases = {
      p = "upower -i /org/freedesktop/UPower/devices/battery_BAT0";
      ng = "sudo nixos-rebuild switch --log-format internal-json -v --flake ~/.setup#gnome_laptop &| nom --json";
      ngt = "sudo nixos-rebuild test --log-format internal-json -v --flake ~/.setup#gnome_laptop &| nom --json";
      j = "z";
      t = "zellij";
      sj = "ssh jan@192.168.178.40";
      sa = "ssh ae@192.168.178.40";
    };
  };
}

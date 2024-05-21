{
  programs = {
    starship.enable = true;
    autojump = {
      enable = true;
      enableZshIntegration = true;
    };
    zsh = {
      enable = true;
      enableAutosuggestions = true;
      syntaxHighlighting.enable = true;
      shellAliases = {
        p = "upower -i /org/freedesktop/UPower/devices/battery_BAT0";
        ng = "sudo nixos-rebuild switch --log-format internal-json -v --flake ~/.setup#gnome_laptop &| nom --json";
        ngt = "sudo nixos-rebuild test --log-format internal-json -v --flake ~/.setup#gnome_laptop &| nom --json";
        j = "z";
        k = "kubectl";
        t = "zellij";
        st = "ssh admin@192.168.178.40";
      };
      oh-my-zsh = {
        enable = true;
        #   # theme = "robbyrussell";
        plugins = [
          "git"
          "npm"
          "history"
          "node"
          "rust"
          "fluxcd"
          "kubectl"
        ];
      };
    };
  };
}

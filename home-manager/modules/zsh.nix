{
  programs = {
    starship.enable = true;
    autojump = {
      enable = true;
      enableZshIntegration = true;
    };
    zsh = {
      enable = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      # initExtra = "zellij";
      shellAliases = {
        p = "upower -i /org/freedesktop/UPower/devices/battery_BAT0";
        ng = "sudo nixos-rebuild switch --flake ~/.setup#gnome_laptop";
        ngt = "sudo nixos-rebuild test --log-format internal-json -v --flake ~/.setup#gnome_laptop &| nom --json";
        # j = "z";
        # k = "kubectl";
        t = "zellij";
        sp = "ssh root@192.168.178.40";
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

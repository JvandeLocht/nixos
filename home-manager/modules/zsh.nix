{
  lib,
  config,
  pkgs,
  ...
}: {
  options = {
    zsh.enable =
      lib.mkEnableOption "enables preconfigured zsh";
  };

  config = lib.mkIf config.zsh.enable {
    home.packages = with pkgs; [
      upower
      nix-output-monitor
    ];
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
        initExtra = ''
          if [[ -z "$ZELLIJ" ]]; then
            if command -v zellij >/dev/null 2>&1; then
              zellij attach -c
            fi
          fi
        '';
        shellAliases = {
          p = "upower -i /org/freedesktop/UPower/devices/battery_BAT0";
          ng = "sudo nixos-rebuild switch --flake ~/.setup#gnome_laptop --log-format internal-json -v |& nom --json";
          ngt = "sudo nixos-rebuild test --log-format internal-json -v --flake ~/.setup#gnome_laptop &| nom --json";
          # j = "z";
          # k = "kubectl";
          t = "zellij";
          sp = "ssh root@192.168.178.40";
        };
        oh-my-zsh = {
          enable = true;
          theme = "robbyrussell";
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
  };
}

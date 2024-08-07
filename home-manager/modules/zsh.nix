{ lib
, config
, pkgs
, ...
}: {
  options = {
    zsh.enable =
      lib.mkEnableOption "enables preconfigured zsh";
  };

  config = lib.mkIf config.zsh.enable {
    home.packages = with pkgs; [
      upower
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
          if [ -z "$TMUX" ]
          then
              tmux new-session -A -s main
          fi
        '';
        shellAliases = {
          p = "upower -i /org/freedesktop/UPower/devices/battery_BAT0";
          ng = "nh os switch -H gnome_laptop ~/.setup";
          t = "tmux";
          y = "yazi";
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

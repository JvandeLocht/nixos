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
        shellAliases = {
          p = "watch upower -i /org/freedesktop/UPower/devices/battery_BAT0";
          ng = "nh os switch -H groot ~/.setup";
          nn = "nh os switch -H nixnas ~/.setup";
          ns = "nh os switch";
          t = "tmux";
          v = "nvim";
          y = "yazi";
          sp = "ssh root@192.168.178.40";
          # ssh = "kitty +kitten ssh";
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

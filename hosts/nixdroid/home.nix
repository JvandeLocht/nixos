{
  config,
  lib,
  pkgs,
  ...
}:
{
  # Read the changelog before changing this value
  home.stateVersion = "23.11";

  # imports = [./neovim];

  programs = {
    starship = {
      enable = true;
      enableZshIntegration = true;
    };
    autojump = {
      enable = true;
      enableZshIntegration = true;
    };
    zsh = {
      enable = true;
      autosuggestion.enable = true;
      prezto.autosuggestions.color = "cyan";
      syntaxHighlighting.enable = true;
      shellAliases = {
        p = "upower -i /org/freedesktop/UPower/devices/battery_BAT0";
        ng = "sudo nixos-rebuild switch --log-format internal-json -v --flake ~/.setup#gnome_laptop &| nom --json";
        ngt = "sudo nixos-rebuild test --log-format internal-json -v --flake ~/.setup#gnome_laptop &| nom --json";
        k = "kubectl";
        t = "zellij";
        v = "nvim";
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
  # insert home-manager config
}

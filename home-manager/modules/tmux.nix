{
  lib,
  config,
  pkgs,
  inputs,
  ...
}: let
  stable = import inputs.nixpkgs {
    localSystem = pkgs.system;
  };
in {
  options = {
    tmux.enable =
      lib.mkEnableOption "enables preconfigured tmux";
  };

  config = lib.mkIf config.tmux.enable {
    xdg.configFile = {
      "tmux/plugins/tmux-which-key/config.yaml".text = lib.generators.toYAML {} {
        command_alias_start_index = 200;
        # rest of config here
      };
    };
    programs.zsh = {
      initExtra = ''
        if [ -z "$TMUX" ]
        then
            tmux new-session -A -s main
        fi
      '';
    };

    programs.tmux = {
      enable = true;
      terminal = "xterm-kitty";
      extraConfig = ''
        set-option -g status-position top
        set-option -g status-style "bg=black,fg=green"
        set -g status-right ""

        # split panes using | and -
        bind | split-window -h
        bind - split-window -v
        unbind '"'
        unbind %

        # reload config file (change file location to your the tmux.conf you want to use)
        bind r source-file ~/.config/tmux/tmux.conf

        # switch panes using Alt-arrow without prefix
        bind -n M-h select-pane -L
        bind -n M-l select-pane -R
        bind -n M-j select-pane -U
        bind -n M-k select-pane -D

        # remap prefix from 'C-b' to 'C-a'
        unbind C-b
        set-option -g prefix C-Space
        bind-key C-Space send-prefix

        # Enable mouse control (clickable windows, panes, resizable panes)
        set -g mouse on
      '';
      plugins = with pkgs;
        [
          {
            plugin = tmuxPlugins.continuum;
            extraConfig = ''
              set -g @continuum-restore 'on'
              set -g @continuum-save-interval '60' # minutes
            '';
          }
        ]
        ++ (with stable; [
          {
            plugin = tmuxPlugins.resurrect;
            extraConfig = "set -g @resurrect-strategy-nvim 'session'";
          }
        ]);
    };
  };
}

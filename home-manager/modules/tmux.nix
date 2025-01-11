{
  lib,
  config,
  pkgs,
  ...
}: let
  tmux-which-key =
    pkgs.tmuxPlugins.mkTmuxPlugin
    {
      pluginName = "tmux-which-key";
      version = "2024-07-15";
      src = pkgs.fetchFromGitHub {
        owner = "alexwforsythe";
        repo = "tmux-which-key";
        rev = "1f419775caf136a60aac8e3a269b51ad10b51eb6";
        sha256 = "sha256-X7FunHrAexDgAlZfN+JOUJvXFZeyVj9yu6WRnxMEA8E=";
      };
      rtpFilePath = "plugin.sh.tmux";
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
    # programs.zsh = {
    #   initExtra = ''
    #     if [ -z "$TMUX" ]
    #     then
    #         tmux new-session -A -s main
    #     fi
    #   '';
    # };

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
      plugins = with pkgs; [
        {
          plugin = tmuxPlugins.resurrect;
          extraConfig = "set -g @resurrect-strategy-nvim 'session'";
        }
        {
          plugin = tmuxPlugins.continuum;
          extraConfig = ''
            set -g @continuum-restore 'on'
            set -g @continuum-save-interval '60' # minutes
          '';
        }
        # {
        #   plugin = tmux-which-key;
        #   extraConfig = ''
        #     set -g @tmux-which-key-xdg-enable 1;
        #   '';
        # }
      ];
    };
  };
}

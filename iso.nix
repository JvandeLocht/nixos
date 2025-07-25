# Config for custom nixos iso. Build with: nix-build '<nixpkgs/nixos>' -A config.system.build.isoImage -I nixos-config=./iso.nix
{ config, pkgs, ... }:

{
  imports = [
    # Base minimal installation CD
    <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix>
  ];

  networking.hostName = "custom-nixos";

  # Enable SSH server
  services.openssh = {
    enable = true;
    permitRootLogin = "yes";
    passwordAuthentication = true;
  };

  # Set root password for SSH login (replace with a secure password)
  users.users.root = {
    password = "password";
  };

  # Make sure sshd service starts on boot
  systemd.services.sshd.wantedBy = [ "multi-user.target" ];

  programs.tmux = {
    enable = true;
    clock24 = true;
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
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  environment = {
    shellAliases = {
      get-config = "git clone https://github.com/JvandeLocht/nixos";
      v = "nix run github:JvandeLocht/nvf-config#";
    };
    interactiveShellInit = ''
      echo "Available aliases:"
      alias
    '';
    systemPackages = with pkgs; [
      tmux
      vim
      git
      sops
      age
    ];
  };

}

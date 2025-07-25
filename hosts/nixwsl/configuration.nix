# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
# NixOS-WSL specific options are documented on the NixOS-WSL repository:
# https://github.com/nix-community/NixOS-WSL
{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    trusted-users = [ "jan" ]; # Add your own username to the trusted list
    auto-optimise-store = true;
    max-jobs = "auto";
    builders-use-substitutes = true;
  };
  users.defaultUserShell = pkgs.zsh;
  wsl.enable = true;
  wsl.defaultUser = "jan";
  # age.identityPaths = [ "${config.users.users.jan.home}/.ssh/id_ed25519" ];
  # Load host-specific certificate from repository
  security.pki.certificates = [
    (builtins.readFile ./man-cert.crt)
  ];
  networking = {
    hostName = "nixwsl"; # Define your hostname.
  };
  programs = {
    zsh.enable = true;
  };
  environment = {
    systemPackages =
      with pkgs;
      [
        curl
        powertop
        rclone
        restic
      ]
      ++ (with inputs; [
      ])
      ++ (with unstable; [
        # proton-pass
      ]);
    # Set default editor to vim
    variables = {
      EDITOR = "nvim";
      RESTIC_PROGRESS_FPS = "1";
    };
  };

  fonts = {
    fontDir.enable = true;
    packages = with pkgs; [
      cantarell-fonts
      notonoto
      vistafonts
      nerd-fonts.fira-code
      nerd-fonts.fira-mono
      nerd-fonts.meslo-lg
    ];
  };
  nixpkgs.config.allowUnfree = true;
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}

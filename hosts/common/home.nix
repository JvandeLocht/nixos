{ pkgs, ... }:
{
  imports = [
    # ../../home-manager/modules
  ];

  programs = {
    git = {
      enable = true;
      settings = {
        user = {
          name = "Jan van de Locht";
          email = "jan@vandelocht.uk";
        };
      };
    };
    nh = {
      enable = true;
      clean = {
        enable = true;
        extraArgs = "--keep-since 4d --keep 3";
      };
      flake = "/home/jan/.setup";
    };
  };

  home = {
    file = {
      ".nixos_wallpaper.jpg" = {
        source = ../../img/nixos_wallpaper.jpg;
        recursive = true;
      };
    };
    packages = with pkgs; [
      # archives
      zip
      xz
      unzip
      p7zip

      # CLI
      typst
      pandoc
      yq-go
      kubeconform
      kustomize
      talosctl
      kubectl
      kubernetes-helm
      k9s
      fluxcd
      kompose
      # nixvim
      nvf
      minio-client
      velero
      opencode

      sops
      age

      abduco # Allows programs to be run independently from its controlling terminal
      neofetch
      lazygit
      evtest # test Input Events (for example LidSwitch)
      usbutils
      android-tools
      auto-cpufreq
      sshfs
      tree # Display filetree
      htop
      tldr
      killall
    ];
    # This value determines the home Manager release that your
    # configuration is compatible with. This helps avoid breakage
    # when a new home Manager release introduces backwards
    # incompatible changes.
    #
    # You can update home Manager without changing this value. See
    # the home Manager release notes for a list of state version
    # changes in each release.
    stateVersion = "23.05";
  };

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;
}

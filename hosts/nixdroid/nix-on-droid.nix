{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  pkgs-unstable = import inputs.nixpkgs-unstable {
    system = pkgs.system;
    config.allowUnfree = true;
  };
in {
  # Simply install just the packages
  environment.packages = with pkgs; [
    # claude-code from unstable
    pkgs-unstable.claude-code
    zsh
    git
    ##vim # or some other editor, e.g. nano or neovim
    nano
    nvf
    typst

    # kubernetes
    kubectl
    pkgs-unstable.talosctl
    kubernetes-helm
    pkgs-unstable.k9s
    fluxcd
    yq-go
    kustomize
    kubeconform

    #sops
    sops
    age
    pre-commit

    wget
    curl
    zellij
    procps
    killall
    diffutils
    findutils
    utillinux
    tzdata
    tree
    hostname
    man
    gnugrep
    gnupg
    gnused
    gnutar
    bzip2
    gzip
    xz
    zip
    unzip
    inetutils
    mycli
    velero
    tldr
    minio-client
    s3fs
    samba
    jq

    python3
    pre-commit-hook-ensure-sops
    python311Packages.pip
    virtualenv

    openssh
    dig
    iproute2
    busybox

    kompose

    ollama
    xclip
    # termux-wallpaper
  ];
  user.shell = "${pkgs.zsh}/bin/zsh";
  terminal.font = let
    fontPackage = pkgs.nerdfonts.override {
      fonts = ["UbuntuMono"];
    };
    fontPath = "/share/fonts/truetype/NerdFonts/UbuntuMonoNerdFont-Regular.ttf";
  in
    fontPackage + fontPath;

  # Backup etc files instead of failing to activate generation if a file already exists in /etc
  environment.etcBackupExtension = ".bak";

  # Read the changelog before changing this value
  system.stateVersion = "23.11";

  # Set up nix for flakes
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';
  # Set your time zone
  time.timeZone = "Europe/Berlin";

  # Configure home-manager
  home-manager = {
    config = ./home.nix;
    backupFileExtension = "hm-bak";
    useGlobalPkgs = true;
  };
}

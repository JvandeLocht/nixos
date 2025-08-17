{ pkgs,
  inputs,
  ... }: {
  imports = [
    ./hardware-configuration.nix
    ./networking.nix # generated at runtime by nixos-infect
    ../common/configuration.nix
  ];

  locale.enable = true;
  sops-config.enable = true;

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
    flake = "/home/jan/.setup";
  };

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    trusted-users = [ "jan" ]; # Add your own username to the trusted list
    auto-optimise-store = true;
    max-jobs = 1;
    builders-use-substitutes = true;
  };

  users = {
    # groups.samba = {};
    users = {
      "jan" = {
        isNormalUser = true;
        # hashedPasswordFile = config.sops.secrets.jan-nixnas.path;
        initialHashedPassword = "$y$j9T$2DyEjQxPoIjTkt8zCoWl.0$3mHxH.fqkCgu53xa0vannyu4Cue3Q7xL4CrUhMxREKC"; # Password.123
        home = "/home/jan";
        extraGroups = [
          "wheel"
          "networkmanager"
          "users"
        ];
        linger = true;
    };
  };
  };


  environment.systemPackages =
    (with pkgs; [
      # nixvim
      spice
      tmux
    ])
    ++ (with inputs; [
    ]);

  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;
  networking.hostName = "nixos-4gb-fsn1-2";
  networking.domain = "";
  services.openssh.enable = true;
  users.users.root.openssh.authorizedKeys.keys = [''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJn9cBaz3tYq1veuROlicKBNW4ArJTJ3lEk10+SN+x7V jan@vandelocht.uk'' ];
  system.stateVersion = "23.11";
}

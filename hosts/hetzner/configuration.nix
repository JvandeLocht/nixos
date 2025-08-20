{
  pkgs,
  inputs,
  config,
  ...
}:
let
  domain = "headscale.vandelocht.uk";
in
{
  imports = [
    ./hardware-configuration.nix
    ./networking.nix # generated at runtime by nixos-infect
    ../common/configuration.nix
  ];

  podman = {
    enable = true;
    headscale-admin.enable = true;
  };

  acme-cloudflare.enable = true;
  services.resolved.enable = true;
  services = {
    headscale = {
      enable = true;
      address = "0.0.0.0";
      port = 8080;

      settings = {
        logtail.enabled = false;
        server_url = "https://${domain}";
        dns = {
          base_domain = "vpn.internal";
          nameservers.global = [
            "1.1.1.1"
            "9.9.9.9"
          ];
          magic_dns = true;
          override_local_dns = false;
        };
      };
    };

    nginx = {
      enable = true;
      recommendedTlsSettings = true;
      virtualHosts.${domain} = {
        useACMEHost = "vandelocht.uk";
        forceSSL = true;

        locations."/" = {
          proxyPass = "http://localhost:${toString config.services.headscale.port}";
          proxyWebsockets = true;
        };
        locations."/admin".extraConfig = ''
          proxy_pass http://127.0.0.1:8090;
          proxy_set_header Host $host;
          proxy_redirect http:// https://;
          proxy_http_version 1.1;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header Upgrade $http_upgrade;
          proxy_set_header Connection $connection_upgrade;
        '';
      };
    };
  };

  environment.systemPackages = [ config.services.headscale.package ];

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
    mutableUsers = false;
    users = {
      "jan" = {
        isNormalUser = true;
        hashedPasswordFile = config.sops.secrets.jan-hetzner.path;
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

  networking.firewall = {
    enable = true;
    allowedTCPPortRanges = [
      {
        from = 8080;
        to = 8080;
      }
      {
        from = 8090;
        to = 8090;
      }
    ];
    allowedUDPPortRanges = [
      {
        from = 8080;
        to = 8080;
      }
      {
        from = 8090;
        to = 8090;
      }
    ];
  };

  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;
  networking.hostName = "hetzner";
  networking.domain = "";
  services.openssh.enable = true;
  users.users.root.openssh.authorizedKeys.keys = [
    ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJn9cBaz3tYq1veuROlicKBNW4ArJTJ3lEk10+SN+x7V jan@vandelocht.uk''
  ];
  users.users.jan.openssh.authorizedKeys.keys = [
    ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJn9cBaz3tYq1veuROlicKBNW4ArJTJ3lEk10+SN+x7V jan@vandelocht.uk''
  ];
  system.stateVersion = "23.11";
}

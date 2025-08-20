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

      # WebSocket upgrade mapping for proper proxying
      appendHttpConfig = ''
        map $http_upgrade $connection_upgrade {
          default upgrade;
          "" close;
        }
        
        # Global DNS resolver for oauth2-proxy connections
        resolver 1.1.1.1 1.0.0.1 valid=300s;
        resolver_timeout 5s;
        
        # Increase buffer sizes for large headers from oauth2-proxy
        proxy_buffer_size 16k;
        proxy_buffers 8 16k;
        proxy_busy_buffers_size 32k;
        large_client_header_buffers 8 32k;
      '';

      virtualHosts.${domain} = {
        useACMEHost = "vandelocht.uk";
        forceSSL = true;

        locations."/" = {
          proxyPass = "http://localhost:${toString config.services.headscale.port}";
          proxyWebsockets = true;
          extraConfig = ''
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection $connection_upgrade;
            proxy_set_header Host $server_name;
            proxy_redirect http:// https://;
            proxy_buffering off;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            add_header Strict-Transport-Security "max-age=15552000; includeSubDomains" always;
          '';
        };
        locations."/admin" = {
          proxyPass = "http://127.0.0.1:8090";
          proxyWebsockets = true;
          extraConfig = ''
            # oauth2-proxy authentication with improved error handling
            auth_request /oauth2/auth;
            error_page 401 = @oauth2_signin;
            error_page 403 = @oauth2_signin;
            error_page 502 = @oauth2_signin;
            
            # Pass authentication headers
            auth_request_set $auth_user $upstream_http_x_auth_request_user;
            auth_request_set $auth_email $upstream_http_x_auth_request_email;
            auth_request_set $auth_groups $upstream_http_x_auth_request_groups;
            proxy_set_header X-Auth-Request-User $auth_user;
            proxy_set_header X-Auth-Request-Email $auth_email;
            proxy_set_header X-Auth-Request-Groups $auth_groups;
            
            proxy_redirect http:// https://;
            proxy_redirect http://127.0.0.1:8090/ /admin/;
          '';
        };
        locations."/admin/" = {
          proxyPass = "http://127.0.0.1:8090/admin/";
          proxyWebsockets = true;
          extraConfig = ''
            # oauth2-proxy authentication with improved error handling
            auth_request /oauth2/auth;
            error_page 401 = @oauth2_signin;
            error_page 403 = @oauth2_signin;
            error_page 502 = @oauth2_signin;
            
            # Pass authentication headers
            auth_request_set $auth_user $upstream_http_x_auth_request_user;
            auth_request_set $auth_email $upstream_http_x_auth_request_email;
            auth_request_set $auth_groups $upstream_http_x_auth_request_groups;
            proxy_set_header X-Auth-Request-User $auth_user;
            proxy_set_header X-Auth-Request-Email $auth_email;
            proxy_set_header X-Auth-Request-Groups $auth_groups;
            
            proxy_redirect http:// https://;
            proxy_redirect http://127.0.0.1:8090/ /admin/;
          '';
        };

        # Named location for oauth2 signin redirect
        locations."@oauth2_signin" = {
          extraConfig = ''
            return 302 https://oauth2proxy.vandelocht.uk/oauth2/start?rd=$scheme://$server_name$request_uri;
          '';
        };

        # oauth2-proxy auth endpoint with improved connectivity
        locations."/oauth2/auth" = {
          proxyPass = "https://oauth2proxy.vandelocht.uk/oauth2/auth";
          extraConfig = ''
            internal;
            proxy_pass_request_body off;
            proxy_set_header Content-Length "";
            proxy_set_header X-Original-URI $request_uri;
            proxy_set_header X-Original-Method $request_method;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header Host oauth2proxy.vandelocht.uk;
            
            # Pass cookies for authentication
            proxy_pass_request_headers on;

            # SSL configuration
            proxy_ssl_verify off;
            proxy_ssl_server_name on;
            proxy_ssl_name oauth2proxy.vandelocht.uk;

            # Connection settings
            proxy_connect_timeout 10s;
            proxy_send_timeout 10s;
            proxy_read_timeout 10s;
            
            # Buffer settings for large headers
            proxy_buffer_size 32k;
            proxy_buffers 8 32k;
            proxy_busy_buffers_size 64k;
            
            # Ignore client abort
            proxy_ignore_client_abort on;
          '';
        };

        # oauth2-proxy callback endpoint (for post-auth redirects)
        locations."/oauth2/callback" = {
          proxyPass = "https://oauth2proxy.vandelocht.uk/oauth2/callback";
          extraConfig = ''
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header Host oauth2proxy.vandelocht.uk;

            # SSL configuration
            proxy_ssl_verify off;
            proxy_ssl_server_name on;
            proxy_ssl_name oauth2proxy.vandelocht.uk;

            # Connection settings
            proxy_connect_timeout 10s;
            proxy_send_timeout 10s;
            proxy_read_timeout 10s;
          '';
        };
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
        from = 80;
        to = 80;
      }
      {
        from = 443;
        to = 443;
      }
    ];
    allowedUDPPortRanges = [
      {
        from = 80;
        to = 80;
      }
      {
        from = 443;
        to = 443;
      }
    ];
  };

  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;
  networking.hostName = "hetzner";
  networking.domain = "";
  services.openssh.enable = true;
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJn9cBaz3tYq1veuROlicKBNW4ArJTJ3lEk10+SN+x7V jan@vandelocht.uk"
  ];
  users.users.jan.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJn9cBaz3tYq1veuROlicKBNW4ArJTJ3lEk10+SN+x7V jan@vandelocht.uk"
  ];
  system.stateVersion = "23.11";
}

{ config
, pkgs
, osConfig
, ...
}: {
  imports = [
    ../common/home.nix
  ];

  tmux.enable = false;


  home = {
    username = "jan";
    homeDirectory = "/home/jan";
    packages =
      (with pkgs; [
      ])
      ++ (with pkgs.gnomeExtensions; [
        arcmenu
        caffeine
        forge
        space-bar
        gsconnect
        appindicator
        screen-rotate
        dash-to-dock
        syncthing-indicator
      ]);
  };
  # Packages that should be installed to the user profile.
  services.syncthing.enable = true;


  systemd.user.services = {
    minio-secret-minio-root-user = {
      Unit = {
        Description = "Podman MinIO secret Service";
      };
      Service = {
        Restart = "never";
        ExecCondition = "${pkgs.busybox}/bin/sh -c '! ${pkgs.podman}/bin/podman secret exists minio_root_user'";
        ExecStart = /*bash*/''
          ${pkgs.podman}/bin/podman secret create minio_root_user ${osConfig.age.secrets.minio-accessKey.path}
        '';
      };
      Install = { WantedBy = [ "graphical-session.target" ]; };
    };
    minio-secret-minio-root-password = {
      Unit = {
        Description = "Podman MinIO secret Service";
      };
      Service = {
        Restart = "never";
        ExecCondition = "${pkgs.busybox}/bin/sh -c '! ${pkgs.podman}/bin/podman secret exists minio_root_password'";
        ExecStart = /*bash*/''
          ${pkgs.podman}/bin/podman secret create minio_root_password ${osConfig.age.secrets.minio-secretKey.path}
        '';
      };
      Install = { WantedBy = [ "graphical-session.target" ]; };
    };
    minio = {
      Unit = {
        Description = "Podman MinIO Service";
        Documentation = "man:podman-generate-systemd(1)";
        Wants = [ "network-online.target" ];
        After = [ "network-online.target" ];
        RequiresMountsFor = [ "%t/containers" ];
      };
      Service = {
        Environment = [
          "PODMAN_SYSTEMD_UNIT=%n"
        ];
        Restart = "on-failure";
        ExecCondition = "${pkgs.busybox}/bin/sh -c '${pkgs.podman}/bin/podman secret exists minio_root_user && ${pkgs.podman}/bin/podman secret exists minio_root_password'";
        TimeoutStopSec = "70";
        ExecStart = ''
          ${pkgs.podman}/bin/podman run \
            --cidfile=%t/%n.ctr-id \
            --cgroups=no-conmon \
            --rm \
            --sdnotify=conmon \
            -d \
            --name minio \
            --replace \
            -p 9000:9000 \
            -p 9001:9001 \
            -v /mnt/data/minio-podman:/data \
            --secret minio_root_user,type=env,target=MINIO_ROOT_USER \
            --secret minio_root_password,type=env,target=MINIO_ROOT_PASSWORD \
            quay.io/minio/minio server /data \
            --console-address :9001
        '';
        ExecStop = "${pkgs.podman}/bin/podman stop --ignore -t 10 --cidfile=%t/%n.ctr-id";
        ExecStopPost = ''
          ${pkgs.podman}/bin/podman rm -f --ignore -t 10 --cidfile=%t/%n.ctr-id
          ${pkgs.podman}/bin/podman secret rm minio_root_user || true
          ${pkgs.podman}/bin/podman secret rm minio_root_password || true
        '';
        Type = "notify";
        NotifyAccess = "all";
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };



  # systemd.user.services.minio = {
  #   Unit = {
  #     Description = "Podman MinIO Service";
  #     Documentation = "man:podman-generate-systemd(1)";
  #     Wants = [ "network-online.target" ];
  #     After = [ "network-online.target" ];
  #     RequiresMountsFor = [ "%t/containers" ];
  #   };
  #   Service = {
  #     Environment = [
  #       "PODMAN_SYSTEMD_UNIT=%n"
  #       "MINIO_ROOT_USER=${pkgs.busybox}/bin/cat ${config.age.secrets.minio-accessKey.path}"
  #       "MINIO_ROOT_PASSWORD=${pkgs.busybox}/bin/cat ${config.age.secrets.minio-secretKey.path}"
  #     ];
  #     Restart = "on-failure";
  #     TimeoutStopSec = "70";
  #     ExecStart = ''
  #       ${pkgs.podman}/bin/podman run \
  #         --cidfile=%t/%n.ctr-id \
  #         --cgroups=no-conmon \
  #         --rm \
  #         --sdnotify=conmon \
  #         -d \
  #         --name minio \
  #         --replace \
  #         -p 9000:9000 \
  #         -p 9001:9001 \
  #         -v /mnt/data/minio-podman:/data \
  #         -e MINIO_ROOT_USER="${pkgs.busybox}/bin/cat ${config.age.secrets.minio-accessKey.path}" \
  #         -e MINIO_ROOT_PASSWORD="${pkgs.busybox}/bin/cat ${config.age.secrets.minio-secretKey.path}" \
  #         quay.io/minio/minio server /data \
  #         --console-address :9001
  #     '';
  #     ExecStop = "${pkgs.podman}/bin/podman stop --ignore -t 10 --cidfile=%t/%n.ctr-id";
  #     ExecStopPost = "${pkgs.podman}/bin/podman rm -f --ignore -t 10 --cidfile=%t/%n.ctr-id";
  #     Type = "notify";
  #     NotifyAccess = "all";
  #   };
  #   Install = {
  #     WantedBy = [ "default.target" ];
  #   };
  # };
  #


  # This value determines the home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update home Manager without changing this value. See
  # the home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "23.05";

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;
}

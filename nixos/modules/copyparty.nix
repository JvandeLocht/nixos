{
  config,
  lib,
  pkgs,
  ...
}:
{

  options.copyparty = {
    enable = lib.mkEnableOption "Toggle the copyparty service on nixnas";
  };
  config = lib.mkIf config.copyparty.enable {
    sops = {
      secrets = {
        "copyparty/users/jan" = {
          owner = "copyparty";
          group = "copyparty";
        };
      };
    };
    # Open firewall port
    networking.firewall.allowedTCPPorts = [ 3923 ];

    services.copyparty = {
      enable = true;
      # directly maps to values in the [global] section of the copyparty config.
      # see `copyparty --help` for available options
      settings = {
        i = "0.0.0.0";
        # use lists to set multiple values
        p = [
          3923 # http/https
        ];
      };

      # create users
      accounts = {
        # specify the account name as the key
        jan = {
          # provide the path to a file containing the password, keeping it out of /nix/store
          # must be readable by the copyparty service user
          passwordFile = config.sops.secrets."copyparty/users/jan".path;
        };
      };

      # Create volume for /tank/copyparty
      volumes = {
        "/" = {
          # Path on the filesystem
          path = "/tank/copyparty";

          # Access permissions
          access = {
            # Everyone can read
            # r = "*";
            # Add specific users for write access if needed
            rw = [ "jan" ];
          };

          # Volume flags
          flags = {
            # Enable file indexing
            e2d = true;
            # Enable metadata indexing
            e2t = true;
            # "d2t" disables multimedia parsers (in case the uploads are malicious)
            d2t = true;
            # skips hashing file contents if path matches *.iso
            nohash = "\.iso$";
            # Scan for new files every 5 minutes
            scan = 300;
          };
        };
      };

      # you may increase the open file limit for the process
      openFilesLimit = 8192;
    };
  };
}

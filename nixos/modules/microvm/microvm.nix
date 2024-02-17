let
  name = "vm-test";
in
  {
    pkgs,
    microvm,
    ...
  }: {
    microvm.vms.${name} = {
      config = {
        networking.hostName = name;
        # networking.firewall.enable = false;
        # services.openssh = {
        #   enable = true;
        #   settings.PermitEmptyPasswords = "yes";
        #   settings.PermitRootLogin = "yes";
        # };
        users.users.root.password = "";

        microvm.hypervisor = "cloud-hypervisor";
        microvm.shares = [
          {
            source = "/nix/store";
            mountPoint = "/nix/.ro-store";
            tag = "ro-store";
            proto = "virtiofs";
          }
        ];
        microvm.interfaces = [
          {
            type = "tap";
            id = "${name}-tap";
            mac = "02:00:00:00:00:01";
            # macvtap = {
            #   link = "wlp7s0";
            #   mode = "bridge";
            # };
          }
        ];
        system.stateVersion = "23.05";
      };
    };
  }

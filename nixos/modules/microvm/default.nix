{
  # imports = [./microvm.nix];

  # networking = {
  #   useNetworkd = true;
  # bridges = {
  #   "br0" = {
  #     interfaces = ["wlp7s0"];
  #   };
  # };
  # bonds = {
  #   "bond0" = {
  #     interfaces = ["wlp7s0"];
  #   };
  # };
  # interfaces = {
  # bond0 = {
  # useDHCP = true;
  # };
  # wlp7s0 = {
  #   useDHCP = true;
  # };
  # };
  # };

  # systemd = {
  #   services."systemd-networkd".environment.SYSTEMD_LOG_LEVEL = "debug";
  #   network = {
  #     netdevs = {
  #       "10-bond0" = {
  #         netdevConfig = {
  #           Kind = "bond";
  #           Name = "bond0";
  #         };
  #         bondConfig = {
  #           Mode = "active-backup";
  #           PrimaryReselectPolicy = "always";
  #           MIIMonitorSec = "1s";
  #           TransmitHashPolicy = "layer3+4";
  #         };
  #       };
  #     };
  #     networks = {
  #       "30-enp" = {
  #         matchConfig.Name = "enp*";
  #         networkConfig = {
  #           Bond = "bond0";
  #           PrimarySlave = true;
  #         };
  #       };
  #       "30-wlp" = {
  #         matchConfig.Name = "wlp*";
  #         networkConfig.Bond = "bond0";
  #       };
  #       "40-bond0" = {
  #         matchConfig.Name = "bond0";
  #         linkConfig = {
  #           RequiredForOnline = "carrier";
  #         };
  #         dhcpV6Config = {
  #           UseDNS = true;
  #           UseNTP = true;
  #         };
  #         ipv6AcceptRAConfig = {
  #           DHCPv6Client = "always";
  #         };
  #         networkConfig = {
  #           IPv6AcceptRA = true;
  #           LinkLocalAddressing = "no";
  #           DHCP = "yes";
  #         };
  #       };
  #     };
  #   };
  # };
  # systemd.network = {
  #   enable = true;
  #   netdevs."20-br0" = {
  #     netdevConfig = {
  #       Name = "br0";
  #       Kind = "bridge";
  #     };
  #   };
  #   networks = {
  #     "10-lan" = {
  #       matchConfig.Name = ["enp*" "vm-*"];
  #       networkConfig = {
  #         Bridge = "br0";
  #       };
  #     };
  #     "10-lan-bridge" = {
  #       matchConfig.Name = "br0";
  #       networkConfig = {
  #         Address = ["192.168.1.2/24" "2001:db8::a/64"];
  #         Gateway = "192.168.1.1";
  #         DNS = ["192.168.1.1"];
  #         IPv6AcceptRA = true;
  #       };
  #       linkConfig.RequiredForOnline = "routable";
  #     };
  #     # Configure the bridge for its desired function
  #     "40-br0" = {
  #       matchConfig.Name = "br0";
  #       bridgeConfig = {};
  #       linkConfig = {
  #         # or "routable" with IP addresses configured
  #         RequiredForOnline = "carrier";
  #       };
  #     };
  #   };
  # };
}

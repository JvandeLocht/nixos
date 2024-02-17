{
  # imports = [./microvm.nix];
  #
  # networking.useNetworkd = true;
  #
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

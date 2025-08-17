{ lib, ... }: {
  # This file was populated at runtime with the networking
  # details gathered from the active system.
  networking = {
    nameservers = [ "2a01:4ff:ff00::add:2"
 "2a01:4ff:ff00::add:1"
 "185.12.64.2"
 ];
    defaultGateway = "172.31.1.1";
    defaultGateway6 = {
      address = "fe80::1";
      interface = "eth0";
    };
    dhcpcd.enable = false;
    usePredictableInterfaceNames = lib.mkForce false;
    interfaces = {
      eth0 = {
        ipv4.addresses = [
          { address="49.13.54.214"; prefixLength=32; }
        ];
        ipv6.addresses = [
          { address="2a01:4f8:c013:f3c8::1"; prefixLength=64; }
{ address="fe80::9000:6ff:fe5e:64ea"; prefixLength=64; }
        ];
        ipv4.routes = [ { address = "172.31.1.1"; prefixLength = 32; } ];
        ipv6.routes = [ { address = "fe80::1"; prefixLength = 128; } ];
      };
      
    };
  };
  services.udev.extraRules = ''
    ATTR{address}=="92:00:06:5e:64:ea", NAME="eth0"
    
  '';
}

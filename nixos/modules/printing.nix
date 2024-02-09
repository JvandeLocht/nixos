{pkgs, ...}: {
  # Enable CUPS to print documents.
  services.printing = {
    enable = true;
    drivers = [
      (pkgs.writeTextDir "share/cups/model/OKI_C332_PS.ppd"
        (builtins.readFile ../../dotfiles/OKI_C332_PS.ppd))
    ];
  };
  services.avahi = {
    enable = true; # runs the Avahi daemon
    nssmdns = true; # enables the mDNS NSS plug-in
    openFirewall = true; # opens the firewall for UDP port 5353
  };
}

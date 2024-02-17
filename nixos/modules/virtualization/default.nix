{pkgs, ...}: {
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;
  users.users.jan.extraGroups = ["libvirtd"];
  environment.systemPackages = with pkgs; [
    qemu
    libvirt
    nixos-generators
  ];
}

{
  pkgs,
  lib,
  config,
  ...
}: {
  options.virtSupport = {
    enable = lib.mkEnableOption "Set up virtualization environment";
  };

  config = lib.mkIf config.virtSupport.enable {
    virtualisation.libvirtd.enable = true;
    programs.virt-manager.enable = true;
    environment.systemPackages = with pkgs; [
      qemu
      libvirt
      nixos-generators
    ];
  };
}

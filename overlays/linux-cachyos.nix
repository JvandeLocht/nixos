inputs: final: prev:
let
  # Create nyxUtils compatibility layer
  nyxUtils = import ../pkgs/linux-cachyos/lib/nyx-utils.nix {
    inherit (final) lib;
  };

  # Create flakes structure expected by the package
  # Use final.path which points to the actual nixpkgs source being used
  flakes = {
    self.overlays.default = _: _: {}; # Empty overlay
    nixpkgs = final.path;
  };

  # Extend final with nyxUtils and flakes so callPackage can find them
  finalWithUtils = final // {
    inherit nyxUtils flakes;
  };

  # Import the cachyos kernel definitions with all required inputs
  cachyosKernels = import ../pkgs/linux-cachyos {
    final = finalWithUtils;
    inherit nyxUtils flakes;
    inputs = {
      inherit flakes;
      final = finalWithUtils;
    };
  };
in
{
  # Export nyxUtils for use by callPackage
  inherit nyxUtils flakes;

  # Export individual kernel packages
  linux_cachyos-gcc = cachyosKernels.cachyos-gcc.kernel;
  linux_cachyos-lts = cachyosKernels.cachyos-lts.kernel;
  linux_cachyos-rc = cachyosKernels.cachyos-rc.kernel;
  linux_cachyos-lto = cachyosKernels.cachyos-lto.kernel;
  linux_cachyos-lto-znver4 = cachyosKernels.cachyos-lto-znver4.kernel;
  linux_cachyos-server = cachyosKernels.cachyos-server.kernel;
  linux_cachyos-hardened = cachyosKernels.cachyos-hardened.kernel;

  # Export linuxPackages_* variants
  linuxPackages_cachyos-gcc = cachyosKernels.cachyos-gcc;
  linuxPackages_cachyos-lts = cachyosKernels.cachyos-lts;
  linuxPackages_cachyos-rc = cachyosKernels.cachyos-rc;
  linuxPackages_cachyos-lto = cachyosKernels.cachyos-lto;
  linuxPackages_cachyos-lto-znver4 = cachyosKernels.cachyos-lto-znver4;
  linuxPackages_cachyos-server = cachyosKernels.cachyos-server;
  linuxPackages_cachyos-hardened = cachyosKernels.cachyos-hardened;

  # Export custom ZFS package if needed
  zfs_cachyos = cachyosKernels.zfs;
}

{ pkgs, ... }:

pkgs.writeScript "gpu-drm-devices" ''
  #!/usr/bin/env bash

  # Find AMD GPU card device
  amd_pci=$(${pkgs.pciutils}/bin/lspci -d 1002: | head -n1 | cut -d' ' -f1)
  if [ -n "$amd_pci" ]; then
    amd_card=$(ls -l /dev/dri/by-path/pci-0000:$amd_pci-card 2>/dev/null | sed 's/.*card/\/dev\/dri\/card/')
  fi

  # Find NVIDIA GPU card device
  nvidia_pci=$(${pkgs.pciutils}/bin/lspci -d 10de: | head -n1 | cut -d' ' -f1)
  if [ -n "$nvidia_pci" ]; then
    nvidia_card=$(ls -l /dev/dri/by-path/pci-0000:$nvidia_pci-card 2>/dev/null | sed 's/.*card/\/dev\/dri\/card/')
  fi

  # Set AQ_DRM_DEVICES with AMD first (primary display), NVIDIA second (compute/acceleration)
  if [ -n "$amd_card" ] && [ -n "$nvidia_card" ]; then
    ${pkgs.hyprland}/bin/hyprctl keyword env AQ_DRM_DEVICES,$amd_card:$nvidia_card
  elif [ -n "$amd_card" ]; then
    ${pkgs.hyprland}/bin/hyprctl keyword env AQ_DRM_DEVICES,$amd_card
  elif [ -n "$nvidia_card" ]; then
    ${pkgs.hyprland}/bin/hyprctl keyword env AQ_DRM_DEVICES,$nvidia_card
  fi
''
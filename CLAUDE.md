# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal NixOS configuration using flakes that manages multiple systems including desktop workstations, servers, and mobile devices. The repository implements impermanence (stateless root filesystem) with ZFS snapshots for desktop systems.

## Development Commands

### Building Systems
- **Build specific host:** `nix build .#nixosConfigurations.<hostname>` (e.g., `groot`, `nixnas`, `nixwsl`)
- **Build home-manager config:** `nix build .#homeConfigurations.jan`
- **Deploy to system:** `nixos-rebuild switch --flake .#<hostname>` (run on target machine)
- **Check flake validity:** `nix flake check`

### Code Quality
- **Format all Nix files:** `nixpkgs-fmt **/*.nix`
- **Update flake inputs:** `nix flake update`

### Maintenance
- **Clean old generations:** `./scripts/trim-generations.sh` (interactive script with options)
- **Check ZFS state (on impermanence systems):** `sudo zfs diff rpool/local/root@blank`

## Architecture

### Flake Structure
- **flake.nix:** Main flake definition with inputs/outputs for all configurations
- **lib/mkNixosConfig.nix:** Reusable function to create NixOS configurations with consistent overlays and modules
- **overlays/:** Custom package overlays including nvf, emacs, freecad, etc.

### Host Organization
- **hosts/common/:** Shared configuration for all systems
- **hosts/<hostname>/:** Per-host configuration and home-manager setup
- **hosts/<hostname>/opt-in.nix:** Impermanence persistence configuration (what survives reboots)

### Modular System Design
- **nixos/modules/:** System-level NixOS modules (networking, gaming, podman, etc.)
- **home-manager/modules/:** User environment modules (desktop apps, shell config, editors)
- Both module directories use `default.nix` files that import all modules in the directory

### Key System Features
- **Impermanence:** Root filesystem reset on boot with selective persistence via `/persist` mount
- **ZFS:** Advanced filesystem with snapshots and auto-scrub
- **Secrets Management:** Using agenix for encrypted secrets
- **Container Support:** Podman with GPU acceleration and custom services
- **Multi-architecture:** Supports x86_64-linux and aarch64-linux (Nix-on-Droid)

### Configuration Pattern
Each host configuration follows the pattern:
1. Import hardware-configuration.nix and common config
2. Enable desired feature modules via boolean options
3. Set host-specific networking and hardware settings
4. Include corresponding home-manager configuration

The modular design allows easy enabling/disabling of features like `gaming.enable = true` or `nvidia.enable = true` in host configurations.
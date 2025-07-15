# NixOS and Home-Manager Configuration

This repository contains personal NixOS and Home-Manager configurations.

## Build, Lint, and Test

The primary tool for managing this repository is `nix`.

- **Build a system configuration:** `nix build .#<hostname>`, where `<hostname>` is one of the defined hosts (e.g., `groot`, `nixnas`).
- **Check for flakes:** `nix flake check` to run linters and tests.
- **Apply changes:** Run `nixos-rebuild switch --flake .#<hostname>` on the target machine.
- **Format code:** Use `nixpkgs-fmt` on all `.nix` files to maintain a consistent style.

## Code Style Guidelines

- **Formatting:** All `.nix` files should be formatted with `nixpkgs-fmt`.
- **Naming Conventions:**
    - Use `camelCase` for variables and function arguments.
    - Use `PascalCase` for NixOS modules and options.
- **Imports:** Use `inherit` to bring variables into scope from surrounding scopes or attribute sets to avoid redundancy.
- **Error Handling:** Ensure that all package definitions and module configurations are robust and handle potential failures gracefully.

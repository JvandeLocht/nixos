# NixOS and Home-Manager Configuration

## Build, Lint, and Test Commands

- **Build system:** `nix build .#nixosConfigurations.<hostname>.config.system.build.toplevel` where `<hostname>` is `groot`, `nixnas`, `nixcache`, `hetzner`, or `nixwsl`
- **Build home-manager:** `nix build .#homeConfigurations.jan.activationPackage`
- **Check flake:** `nix flake check` - runs all checks and tests
- **Update flake inputs:** `nix flake update`
- **Apply system changes:** `sudo nixos-rebuild switch --flake .#<hostname>`
- **Apply home-manager:** `home-manager switch --flake .#jan`
- **Format all Nix files:** `nixpkgs-fmt **/*.nix` or `find . -name '*.nix' -exec nixpkgs-fmt {} +`

## Code Style Guidelines

- **Formatting:** Use `nixpkgs-fmt` exclusively. Indentation is 2 spaces (never tabs).
- **Imports:** Place `imports` first in modules. Use `inherit` for bringing variables into scope to avoid redundancy.
- **Naming:** Use `camelCase` for variables/function arguments. Module options use `kebab-case` (e.g., `nix-settings.enable`).
- **Module structure:** Always use `{ lib, config, pkgs, ... }:` parameter pattern. Define `options` before `config`.
- **Options:** Use `lib.mkEnableOption` for boolean enable options. Use `lib.mkIf` for conditional config blocks.
- **Comments:** Use `#` for single-line comments. Avoid inline comments unless necessary for complex expressions.
- **Strings:** Use double-quoted strings `"..."` for paths and simple strings. Use `''...''` for multi-line strings (bash scripts, etc.).
- **Lists:** Multi-line lists should have one item per line with trailing semicolons aligned.
- **Error handling:** Prefer `lib.optionals` and `lib.mkIf` over runtime checks. Use `builtins.tryEval` for potentially broken derivations.

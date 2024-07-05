{
  lib,
  config,
  pkgs,
  ...
}: {
  options.nixvim = {
    enable = lib.mkEnableOption "Custom Neovim (nixvim) configuration";
  };

  config = lib.mkIf config.nixvim.enable {
    imports = [
      ./autocommands.nix
      ./completion.nix
      ./keymappings.nix
      ./options.nix
      ./plugins
      ./todo.nix
    ];

    home.shellAliases.v = "nvim";

    programs.nixvim = {
      enable = true;
      # package = pkgs-unstable.nixvim;
      # defaultEditor = true;

      viAlias = true;
      vimAlias = true;

      luaLoader.enable = true;

      # Highlight and remove extra white spaces
      # highlight.ExtraWhitespace.bg = "red";
      match.ExtraWhitespace = "\\s\\+$";
    };
  };
}

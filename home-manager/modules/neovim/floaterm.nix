{
  lib,
  config,
  pkgs,
  ...
}: {
  options.neovim.floaterm = {
    enable = lib.mkEnableOption "vim-floaterm plugin for Neovim";
  };

  config = lib.mkIf config.neovim.floaterm.enable {
    programs.neovim = {
      plugins = with pkgs.vimPlugins; [
        {
          plugin = vim-floaterm;
          type = "lua";
          config =
            /*
            lua
            */
            ''
              vim.keymap.set('n', '<F7>', '<cmd>FloatermToggle<cr>', { desc = 'Toggle Floaterm' })
              vim.g["floaterm_height"] = 0.95
              vim.g["floaterm_width"] = 0.95
            '';
        }
      ];
    };
  };
}

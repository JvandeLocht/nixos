{pkgs, ...}: {
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
            vim.keymap.set('n', '<F7>', '<cmd>FloatermToggle<cr>', { desc = 'Save current buffer' })
            vim.g["floaterm_height"] = 0.95
            vim.g["floaterm_width"] = 0.95
          '';
      }
    ];
  };
}

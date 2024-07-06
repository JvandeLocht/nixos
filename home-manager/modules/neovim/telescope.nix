{
  lib,
  config,
  pkgs,
  ...
}: {
  options.neovim.telescope = {
    enable = lib.mkEnableOption "telescope-nvim plugin for Neovim";
  };

  config = lib.mkIf config.neovim.telescope.enable {
    programs.neovim = {
      plugins = with pkgs.vimPlugins; [
        {
          plugin = telescope-nvim;
          type = "lua";
          config =
            /*
            lua
            */
            ''
              local builtin = require('telescope.builtin')
              vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Find files' })
              vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'live grep' })
              vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Buffers' })
              vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Help tags' })
              require("telescope").setup{}
            '';
        }
      ];
    };
  };
}

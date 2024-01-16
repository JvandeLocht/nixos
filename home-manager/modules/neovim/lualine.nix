{pkgs, ...}: {
  programs.neovim = {
    plugins = with pkgs.vimPlugins; [
      {
        plugin = lualine-nvim;
        type = "lua";
        config =
          /*
          lua
          */
          ''
            local function metals_status()
              return vim.g["metals_status"] or ""
            end
            require('lualine').setup(
              {
                options = { theme = 'onedark' },
                sections = {
                  lualine_a = {'mode' },
                  lualine_b = {'branch', 'diff' },
                  lualine_c = {'filename', metals_status },
                  lualine_x = {'encoding', 'filetype'},
                  lualine_y = {'progress'},
                  lualine_z = {'location'}
                }
              }
            )
          '';
      } # Status Line
    ];
  };
}

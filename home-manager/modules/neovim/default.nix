{
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    ./autopairs.nix
    ./gen.nix
    ./bufferline.nix
    ./comment.nix
    ./completion.nix
    ./floaterm.nix
    ./lspconfig.nix
    ./lualine.nix
    ./metals.nix
    ./none-ls.nix
    ./onedark.nix
    ./telescope.nix
    ./treesitter.nix
    ./web-devicons.nix
    ./which-key.nix
  ];

  options.neovim = {
    enable = lib.mkEnableOption "Custom Neovim configuration";
  };

  config = lib.mkIf config.neovim.enable {
    home.shellAliases.v = "nvim";

    programs.neovim = {
      enable = true;
      defaultEditor = true;
      vimAlias = true;
      plugins = with pkgs.vimPlugins; [
        neo-tree-nvim # File-browser
        vimwiki # Wiki
        luasnip
        vim-startify
        lazygit-nvim
        plenary-nvim
        markdown-preview-nvim # Markdown Preview
      ];

      extraConfig =
        /*
        vim
        */
        ''
          :set number
          :set expandtab
          set clipboard+=unnamedplus
          set cursorlineopt=number
          if has("autocmd")
            au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
          endif
          au FileType css setlocal tabstop=2 shiftwidth=2
          au FileType haskell setlocal tabstop=2 shiftwidth=2
          au FileType nix setlocal tabstop=2 shiftwidth=2
          au FileType json setlocal tabstop=2 shiftwidth=2
          au FileType cpp setlocal tabstop=2 shiftwidth=2
          au FileType c setlocal tabstop=2 shiftwidth=2
          au FileType java setlocal tabstop=2 shiftwidth=2
          au FileType markdown setlocal spell
          au FileType markdown setlocal tabstop=2 shiftwidth=2
          au CursorHold,CursorHoldI * lua vim.diagnostic.open_float(nil, {focus=false})
          au BufRead,BufNewFile *.wiki setlocal textwidth=80 spell tabstop=2 shiftwidth=2
          au FileType xml setlocal tabstop=2 shiftwidth=2
          au FileType help wincmd L
          au FileType gitcommit setlocal spell
        '';

      extraLuaConfig =
        /*
        lua
        */
        ''
          vim.g.mapleader = ' '
          vim.keymap.set('n', '<Leader>w', '<cmd>w<cr>', { desc = 'Save current buffer' })
          vim.keymap.set('n', '<Leader>wa', '<cmd>wa<cr>', { desc = 'Save all buffer' })
          vim.keymap.set('n', '<Leader>wq', '<cmd>wq<cr>', { desc = 'Save and quit' })
          vim.keymap.set('n', '<Leader>q', '<cmd>confirm q<cr>', { desc = 'Quit' })
          vim.keymap.set('n', '<Leader>o', '<cmd>Neotree toggle<cr>', { desc = 'Toggle Neotree' })
          vim.keymap.set('n', '|', '<cmd>vsplit<cr>', { desc = 'Split vertically' })
          vim.keymap.set('n', '\\', '<cmd>split<cr>', { desc = 'Split horizontally' })
          vim.keymap.set('n', '<esc>', ':noh<CR>', { desc = 'Clear search results' })
          vim.keymap.set('n', '<Leader>h', '<C-w>h', { desc = 'Move on Window left' })
          vim.keymap.set('n', '<Leader>j', '<C-w>j', { desc = 'Move on Window down' })
          vim.keymap.set('n', '<Leader>l', '<C-w>l', { desc = 'Move on Window right' })
          vim.keymap.set('n', '<Leader>k', '<C-w>k', { desc = 'Move on Window up' })
          vim.keymap.set('n', '<C-Left>', ':vertical resize +2<CR>', { desc = 'Resize Window to the left' })
          vim.keymap.set('n', '<C-Right>', ':vertical resize -2<CR>', { desc = 'Resize Window to the right' })
          vim.keymap.set('n', '<C-Up>', ':resize -2<CR>', { desc = 'Resize Window upwards' })
          vim.keymap.set('n', '<C-Down>', ':resize +2<CR>', { desc = 'Resize Window downwards' })
          vim.keymap.set('n', '<leader>g', '<cmd>FloatermNew lazygit<CR>', { desc = 'Open Lazygit in new Floaterm Window' })
          vim.o.undofile = true

          vim.opt.expandtab = true
          vim.opt.shiftwidth = 4
          vim.opt.softtabstop = 4
          vim.keymap.set('v', '<Tab>', '>gv', { desc = 'indent in visual' })
          vim.keymap.set('v', '<S-Tab>', '<gv', { desc = 'unindent in visual' })
        '';

      extraPackages = with pkgs; [
        ripgrep # Requirement for telescope
        wl-clipboard
      ];
    };
  };
}

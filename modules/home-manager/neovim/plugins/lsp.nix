{
  programs.nixvim = {
    plugins = {
      lsp-format = {
        enable = true;
        lspServersToEnable = "all";
      };
      lsp = {
        enable = true;
        onAttach = ''
          vim.cmd [[autocmd BufWritePre <buffer> lua vim.lsp.buf.format()]]
        '';
        keymaps = {
          silent = true;
          diagnostic = {
            # Navigate in diagnostics
            "<leader>k" = "goto_prev";
            "<leader>j" = "goto_next";
          };

          lspBuf = {
            gd = "definition";
            gD = "references";
            gt = "type_definition";
            gi = "implementation";
            K = "hover";
            "<F2>" = "rename";
          };
        };

        servers = {
          bashls.enable = true;
          clangd.enable = true;
          nil_ls.enable = true;
          lua-ls.enable = true;
          texlab.enable = true;
          rust-analyzer.enable = true;
        };
      };
    };
  };
}

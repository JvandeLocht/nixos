{
  programs.nixvim = {
    plugins = {
      none-ls = {
        enable = true;
        sources.diagnostics.shellcheck.enable = true;
        sources.formatting = {
          black.enable = true;
          fourmolu.enable = true;
          fnlfmt.enable = true;
          nixfmt.enable = true;
          isort.enable = true;
          prettier.enable = true;
        };
      };
    };
  };
}

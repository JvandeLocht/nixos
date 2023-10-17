{
  programs.nixvim = {
    plugins = {
      nvim-cmp = {
        enable = true;
        sources = [{ name = "nvim_lsp"; }];
        mappingPresets = [ "insert" ];
        mapping = { "<CR>" = "cmp.mapping.confirm({ select = true })"; };
        formatting.fields = [ "kind" "abbr" "menu" ];

        window.completion = {
          winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,Search:None";
          colOffset = -4;
          sidePadding = 0;
          border = "single";
        };

        window.documentation = {
          winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,Search:None";
          border = "single";
        };

        snippet.expand = "luasnip";
      };
    };
  };
}

{
  lib,
  config,
  pkgs,
  ...
}: {
  options.neovim.metals = {
    enable = lib.mkEnableOption "nvim-metals plugin for Neovim";
  };

  config = lib.mkIf config.neovim.metals.enable {
    programs.neovim = {
      plugins = with pkgs.vimPlugins; [
        {
          plugin = nvim-metals;
          type = "lua";
          config =
            /*
            lua
            */
            ''
              metals_config = require("metals").bare_config()
              metals_config.settings = {
                useGlobalExecutable = true,
                showInferredType = true
              }
              metals_config.init_options.statusBarProvider = "on"
              local nvim_metals_group = vim.api.nvim_create_augroup("nvim-metals", { clear = true })
              vim.api.nvim_create_autocmd("FileType", {
                pattern = { "scala", "sbt", },
                callback = function()
                  require("metals").initialize_or_attach(metals_config)
                end,
                group = nvim_metals_group,
              })
            '';
        }
      ];
    };
  };
}

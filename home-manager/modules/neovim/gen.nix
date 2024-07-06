{
  lib,
  config,
  pkgs,
  ...
}: let
  gen = pkgs.vimUtils.buildVimPlugin {
    name = "nvim-gen";
    src = pkgs.fetchFromGitHub {
      owner = "David-Kunz";
      repo = "gen.nvim";
      rev = "b1230ce2993b2be38a1e22606750d05a94307380";
      hash = "sha256-z03a2au40RIcpDUTRSWlWAbo1E+MgEgVaobFWV8hIaI=";
    };
  };
in {
  options.neovim.gen = {
    enable = lib.mkEnableOption "gen.nvim plugin for Neovim";
  };

  config = lib.mkIf config.neovim.gen.enable {
    programs.neovim = {
      plugins = [
        {
          plugin = gen;
          type = "lua";
          config =
            /*
            lua
            */
            ''
              require('gen').setup({
                opts = {
                  model = "dolphin-mistral:latest", -- The default model to use.
                  display_mode = "split", -- The display mode. Can be "float" or "split".
                  show_prompt = true, -- Shows the Prompt submitted to Ollama.
                  show_model = true, -- Displays which model you are using at the beginning of your chat session.
                  no_auto_close = false, -- Never closes the window automatically.
                  -- Function to initialize Ollama
                  command = function(options)
                      local body = {model = options.model, stream = true}
                      return "curl --silent --no-buffer -X POST http://" .. options.host .. ":" .. options.port .. "/api/chat -d $body"
                  end,
                  -- The command for the Ollama service. You can use placeholders $prompt, $model and $body (shellescaped).
                  -- This can also be a command string.
                  -- The executed command must return a JSON object with { response, context }
                  -- (context property is optional).
                  -- list_models = '<omitted lua function>', -- Retrieves a list of model names
                  display_mode = "float", -- The display mode. Can be "float" or "split" or "horizontal-split".
                  show_prompt = false, -- Shows the prompt submitted to Ollama.
                  show_model = false, -- Displays which model you are using at the beginning of your chat session.
                  no_auto_close = false, -- Never closes the window automatically.
                  debug = false -- Prints errors and the command which is run.
                        }
                      })

                      vim.keymap.set({ 'n', 'v' }, '<leader>]', ':Gen<CR>')
            '';
        }
      ];
    };
  };
}

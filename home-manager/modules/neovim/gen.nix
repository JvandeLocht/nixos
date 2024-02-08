{pkgs, ...}: let
  gen = pkgs.vimUtils.buildVimPlugin {
    name = "nvim-gen";
    src = pkgs.fetchFromGitHub {
      owner = "David-Kunz";
      repo = "gen.nvim";
      rev = "41ad952c8269fa7aa3a4b8a5abb44541cb628313";
      hash = "sha256-cNz/yPTTgt1ng4C2BqN4P62FBV7lmDIEmEsdDhfyKHk=";
    };
  };
in {
  programs.neovim = {
    plugins = with pkgs.vimPlugins; [
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
                  init = function(options) pcall(io.popen, "ollama serve > /dev/null 2>&1 &") end,
                  -- Function to initialize Ollama
                  command = "curl --silent --no-buffer -X POST http://localhost:11434/api/generate -d $body",
                  -- The command for the Ollama service. You can use placeholders $prompt, $model and $body (shellescaped).
                  -- This can also be a lua function returning a command string, with options as the input parameter.
                  -- The executed command must return a JSON object with { response, context }
                  -- (context property is optional).
                  list_models = '<omitted lua function>', -- Retrieves a list of model names
                  debug = false -- Prints errors and the command which is run.
              }
            })

            vim.keymap.set({ 'n', 'v' }, '<leader>]', ':Gen<CR>')
          '';
      }
    ];
  };
}

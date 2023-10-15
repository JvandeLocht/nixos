{
  programs.nixvim = {
    globals = {
      mapleader = " ";
      maplocalleader = " ";
    };
    keymaps = [
      {
        mode = "n";
        key = "<leader>w";
        action = "<cmd>w<cr>";
        options = {
          silent = true;
          desc = "Save";
        };
      }
      {
        mode = "n";
        key = "<leader>wa";
        action = "<cmd>wa<cr>";
        options = {
          silent = true;
          desc = "Save all";
        };
      }
      {
        mode = "n";
        key = "<esc>";
        action = ":noh<CR>";
        options = {
          silent = true;
          desc = "Clear search results";
        };
      }
      {
        mode = "n";
        key = "<C-c>";
        action = ":b#<CR>";
        options = {
          silent = true;
          desc = "Back and fourth between the two most recent files";
        };
      }
      {
        mode = "n";
        key = "<leader>q";
        action = "<cmd>confirm q<cr>";
        options = {
          silent = true;
          desc = "Quit";
        };
      }
      {
        mode = "n";
        key = "|";
        action = "<cmd>vsplit<cr>";
        options = {
          silent = true;
          desc = "Vertical Split";
        };
      }
      {
        mode = "n";
        key = "\\";
        action = "<cmd>split<cr>";
        options = {
          silent = true;
          desc = "Horizontal Split";
        };
      }
      {
        mode = "n";
        key = "<C-h>";
        action = "<C-w>h";
        options = {
          silent = true;
          desc = "navigate to the left window";
        };
      }
      {
        mode = "n";
        key = "<C-l>";
        action = "<C-w>l";
        options = {
          silent = true;
          desc = "navigate to the right window";
        };
      }
      {
        mode = "n";
        key = "<C-Up>";
        action = ":resize -2<CR>";
        options = {
          silent = true;
          desc = "resize window up";
        };
      }
      {
        mode = "n";
        key = "<C-Down>";
        action = ":resize +2<CR>";
        options = {
          silent = true;
          desc = "resize window Down";
        };
      }
      {
        mode = "n";
        key = "<C-Left>";
        action = ":vertical resize +2<CR>";
        options = {
          silent = true;
          desc = "resize window left";
        };
      }
      {
        mode = "n";
        key = "<C-Right>";
        action = ":vertical resize -2<CR>";
        options = {
          silent = true;
          desc = "resize window right";
        };
      }
    ];
  };
}

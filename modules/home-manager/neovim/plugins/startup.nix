{ lib, buildVimPlugin, buildNeovimPlugin, fetchFromGitHub, fetchgit }:

let
  startup-nvim = buildVimPlugin {
    pname = "startup.nvim";
    version = "2023-03-13";
    src = fetchFromGitHub {
      owner = "startup-nvim";
      repo = "startup.nvim";
      rev = "5295eabe35eb66d0b355ada0ca06ec8bdb8f9698";
      sha256 = "";
    };
    meta.homepage = "https://github.com/startup-nvim/startup.nvim";
  };
in
{

programs.nixvim = {
    extraPlugins = [ startup-nvim ];
    };
}

{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
{
  options = {
    emacs.enable = lib.mkEnableOption "installes dependencies for emacs";
    emacs.package = lib.mkPackageOption pkgs "emacs-git-pgtk" {
      extraDescription = "Defines which emacs package should be used.";
    };
  };

  config = lib.mkIf config.emacs.enable {
    programs.emacs = {
      enable = true;
      package = config.emacs.package;
      extraPackages =
        epkgs: with epkgs; [
          vterm
          treesit-grammars.with-all-grammars
          python-black
          flycheck-pyflakes
          flymake-python-pyflakes
          python-isort
          py-isort
          pipenv
          pytest
          shfmt
          flymake-shellcheck
          apheleia
          prettier
          fzf
        ];
    };
    home.sessionVariables = {
      DOOMDIR = "${config.home.homeDirectory}/.setup/home-manager/modules/emacs/doom";
      EMACSDIR = "${config.xdg.configHome}/emacs";
      DOOMLOCALDIR = "${config.xdg.dataHome}/doom";
      DOOMPROFILELOADFILE = "${config.xdg.stateHome}/doom-profiles-load.el";
    };
    fonts.fontconfig.enable = true;
    home.packages =
      with pkgs;
      [
        ripgrep
        fzf
        bat
        fd
        nixfmt-rfc-style
        lazygit
        tinymist
        fira-sans
        emacs-all-the-icons-fonts
        fontconfig
        shfmt # :lang sh
        shellcheck # :lang sh
        nodejs_24 # needed for lsp
        black # :lang python
        multimarkdown
        ispell
        vips # dirvish image preview
        nodePackages_latest.prettier # code formatting with apheleia
        st
        # C++ development tools
        clang-tools # provides clangd LSP server
        cmake
        cmake-language-server # LSP for CMakeLists.txt
        gdb # debugger
        lldb # alternative debugger
      ]
      ++ (with python312Packages; [
        pyflakes
        isort
        pipenv
        pytest
        nose2
        setuptools
      ]);
    xdg.desktopEntries.doom = {
      exec = "env DOOMDIR=${config.home.homeDirectory}/.setup/home-manager/modules/emacs/doom EMACSDIR=${config.xdg.configHome}/emacs DOOMLOCALDIR=${config.xdg.dataHome}/doom DOOMPROFILELOADFILE=${config.xdg.stateHome}/doom-profiles-load.el ${pkgs.emacs-git-pgtk}/bin/emacs";
      name = "Doom Emacs";
      icon = "${config.home.homeDirectory}/.setup/img/doom.png";
    };
    xdg.configFile."emacs".source = inputs.doomemacs;

  };
}

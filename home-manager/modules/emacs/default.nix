{
  pkgs,
  lib,
  config,
  ...
}:
{
  options = {
    emacs.enable = lib.mkEnableOption "installes dependencies for emacs";
  };

  config = lib.mkIf config.emacs.enable {
    programs.emacs = {
      enable = true;
      package = pkgs.emacs-gtk;
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
        ];
    };
    home.sessionVariables = {
      DOOMDIR = "/home/jan/.setup/home-manager/modules/emacs/doom";
      EMACSDIR = "${config.xdg.configHome}/emacs";
      DOOMLOCALDIR = "${config.xdg.dataHome}/doom";
      DOOMPROFILELOADFILE = "${config.xdg.stateHome}/doom-profiles-load.el";
    };
    fonts.fontconfig.enable = true;
    home.packages =
      with pkgs;
      [
        ripgrep
        fd
        nixfmt-rfc-style
        lazygit
        tinymist
        nerd-fonts.fira-code
        nerd-fonts.fira-mono
        fira-sans
        emacs-all-the-icons-fonts
        fontconfig
        shfmt # :lang sh
        shellcheck # :lang sh
        nodejs_23 # needed for lsp
        black # :lang python
        multimarkdown
        ispell
        vips # dirvish image preview
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
      exec = "env DOOMDIR=/home/jan/.setup/home-manager/modules/emacs/doom EMACSDIR=${config.xdg.configHome}/emacs DOOMLOCALDIR=${config.xdg.dataHome}/doom DOOMPROFILELOADFILE=${config.xdg.stateHome}/doom-profiles-load.el ${pkgs.emacs}/bin/emacs";
      name = "Doom Emacs";
      icon = "/home/jan/.setup/img/doom.png";
    };
  };
}

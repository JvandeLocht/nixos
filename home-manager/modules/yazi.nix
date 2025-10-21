{
  lib,
  config,
  pkgs,
  ...
}:
{
  options = {
    yazi.enable = lib.mkEnableOption "enables preconfigured yazi";
  };

  config = lib.mkIf config.yazi.enable {
    programs.yazi = {
      enable = true;
      enableZshIntegration = true;
      shellWrapperName = "y";
      settings = {
        mgr = {
          show_hidden = true;
          mouse_events = [
            "click"
            "scroll"
            "drag"
          ];
        };
        preview = {
          max_width = 1000;
          max_height = 1000;
        };
        plugins = {
          prepend_previewers = [
            # Archive previewer
            {
              mime = "application/*zip";
              run = "ouch";
            }
            {
              mime = "application/x-tar";
              run = "ouch";
            }
            {
              mime = "application/x-bzip2";
              run = "ouch";
            }
            {
              mime = "application/x-7z-compressed";
              run = "ouch";
            }
            {
              mime = "application/x-rar";
              run = "ouch";
            }
            {
              mime = "application/x-xz";
              run = "ouch";
            }
            {
              mime = "application/xz";
              run = "ouch";
            }
            #csv previewer[plugin]
            {
              mime = "application/*csv";
              run = "rich-preview";
            }
            {
              mime = "*.md";
              run = "rich-preview";
            }
            {
              mime = "*.rst";
              run = "rich-preview";
            }
            {
              mime = "*.ipynb";
              run = "rich-preview";
            }
            {
              mime = "*.json";
              run = "rich-preview";
            }
          ];
        };
      };
      keymap = {
        mgr.prepend_keymap = [
          {
            run = "plugin ouch";
            on = [ "C" ];
            desc = "Compress with ouch";
          }
          {
            run = "plugin mount";
            on = [ "M" ];
            desc = "mount with mount";
          }
          {
            run = ''shell -- ripdrag --no-click --and-exit --icon-size 64 --target --all "$@" | while read filepath; do cp -nR "$filepath" .; done'';
            on = [ "<S-d>" ];
            desc = "Drag-n-drop files (no overwrite)";
          }
          {
            run = ''shell -- ripdrag --no-click --and-exit --icon-size 64 --target --all "$@" | while read filepath; do cp -fR "$filepath" .; done'';
            on = [ "<C-S-d>" ];
            desc = "Drag-n-drop files (with overwrite)";
          }
        ];
      };
      plugins = {
        ouch = pkgs.yaziPlugins.ouch;
        miller = pkgs.yaziPlugins.miller;
        rich-preview = pkgs.yaziPlugins.rich-preview;
        mount = pkgs.yaziPlugins.mount;
      };
    };
    home.packages = with pkgs; [
      ueberzugpp
      mpv
      ouch
      rich-cli
      udisks
      ripdrag
    ];
  };
}

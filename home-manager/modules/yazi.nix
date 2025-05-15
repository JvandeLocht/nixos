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
        manager = {
          show_hidden = true;
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
            #csv previewer
            {
              mime = "text/csv";
              run = "miller";
            }
          ];
        };
      };
      keymap = {
        manager.prepend_keymap = [
          {
            run = "plugin ouch";
            on = [ "C" ];
            desc = "Compress with ouch";
          }
        ];
      };
      plugins = {
        ouch = pkgs.yaziPlugins.ouch;
        miller = pkgs.yaziPlugins.miller;
      };
    };
    home.packages = with pkgs; [
      ueberzugpp
      mpv
      ouch
      miller
    ];
  };
}

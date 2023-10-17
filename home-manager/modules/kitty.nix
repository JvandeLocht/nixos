{ pkgs, ... }: {
  programs.kitty = {
    enable = true;
    font = {
      size = 16;
      package = pkgs.nerdfonts;
      name = "MesloLGM Nerd Font Mono";
    };
    theme = "Treehouse";
    shellIntegration.enableFishIntegration = true;
    settings = {
      scrollback_lines = 10000;
      enable_audio_bell = false;
      update_check_interval = 0;
    };
  };
}

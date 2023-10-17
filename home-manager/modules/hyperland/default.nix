{ pkgs, ... }: {

  imports = [ ./config.nix ];

  wayland.windowManager.hyprland = {
    enable = true;
    package = pkgs.hyprland;
    xwayland.enable = true;
    enableNvidiaPatches = true;
  };

  home.packages = (with pkgs; [
    libnotify
    mako
    wl-clipboard
    waybar
    # (pkgs.waybar.overrideAttrs (oldAttrs: {
    #   mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true" ];
    # }))
    swww
    # wofi
  ]);

}

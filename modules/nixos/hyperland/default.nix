{ pkgs, ... }: {

  # imports = [ ./config.nix ];

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    enableNvidiaPatches = true;
  };
  # stuff for hyperland
  environment.sessionVariables = {
    # If your cursor becomes invisible
    WLR_NO_HARDWARE_CURSORS = "1";
    # Hint electron apps to use wayland
    NIXOS_OZONE_WL = "1";
  };
  services.xserver.displayManager.defaultSession = "hyprland";

  environment.systemPackages = (with pkgs; [
    libnotify
    mako
    wl-clipboard
    waybar
    (pkgs.waybar.overrideAttrs (oldAttrs: {
      mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true" ];
    }))
    eww
    swww
    wofi
  ]);

}

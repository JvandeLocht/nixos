{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
{
  options.hyprland = {
    enable = lib.mkEnableOption "Set up Hyprland desktop environment";
  };

  config = lib.mkIf config.hyprland.enable {
    programs = {
      hyprland = {
        # set the flake package
        package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
        # make sure to also set the portal package, so that they are in sync
        portalPackage =
          inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
        enable = true;
        withUWSM = true;
      };
      hyprlock.enable = true;
    };
    services = {
      greetd = {
        enable = true;
        settings = {
          initial_session = {
            command = "${pkgs.hyprland}/bin/Hyprland";
            user = "jan";
          };
          default_session = {
            command = "${pkgs.greetd.tuigreet}/bin/tuigreet --cmd ${pkgs.hyprland}/bin/Hyprland";
            user = "greeter";
          };
        };
      };
      gnome.gnome-keyring.enable = true;
      gvfs.enable = true; # Mount, trash, and other functionalities
      tumbler.enable = true; # Thumb${pkgs.hyprland}/bin/Hyprlandnail support for images
      supergfxd.enable = true;
      upower.enable = true;
      gnome.sushi.enable = true;
      # hypridle.enable = false;
      dbus.enable = true;
      udisks2.enable = true;
    };

    # nixpkgs.overlays = [
    #   (final: prev: {
    #     wvkbd = prev.wvkbd.overrideAttrs (oldAttrs: {
    #       patches = (oldAttrs.patches or []) ++ [../../patches/switchYandZ.patch];
    #     });
    #   })
    # ];

    environment = {
      variables = {
        XCURSOR_SIZE = "15";
      };
      sessionVariables = {
        # If your cursor becomes invisible
        WLR_NO_HARDWARE_CURSORS = "1";
        # Hint electron apps to use wayland
        NIXOS_OZONE_WL = "1";
        # GTK: Use wayland if available, fall back to x11 if not.
        GDK_BACKEND = "wayland,x11";
        # Qt: Use wayland if available, fall back to x11 if not.
        QT_QPA_PLATFORM = "wayland;xcb";
        # Run SDL2 applications on Wayland.
        # Remove or set to x11 if games that provide
        # older versions of SDL cause compatibility issues
        SDL_VIDEODRIVER = "wayland";
        # Clutter package already has wayland enabled,
        # this variable will force Clutter applications
        # to try and use the Wayland backend
        CLUTTER_BACKEND = "wayland";
        # XDG specific environment variables are often detected
        # through portals and applications that may set those for you,
        # however it is not a bad idea to set them explicitly.
        XDG_CURRENT_DESKTOP = "Hyprland";
        XDG_SESSION_TYPE = "wayland";
        XDG_SESSION_DESKTOP = "Hyprland";
        # (From the Qt documentation) enables automatic scaling,
        # based on the monitor’s pixel density
        # https://doc.qt.io/qt-5/highdpi.html
        QT_AUTO_SCREEN_SCALE_FACTOR = "1";
      };
      systemPackages = with pkgs; [
        brightnessctl
        xbindkeys
        qt5.qtwayland
        qt6.qtwayland
        file-roller
        nautilus
        nautilus-open-any-terminal
        seahorse
      ];
    };

    security = {
      polkit.enable = true;
      pam.services.greetd = {
        enableGnomeKeyring = true;
        startSession = true;
      };
    };

    systemd = {
      user.services.lxqt-policykit-agent = {
        description = "lxqt-policykit-agent";
        wantedBy = [ "hyprland-session.target" ];
        wants = [ "hyprland-session.target" ];
        after = [ "hyprland-session.target" ];
        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.lxqt.lxqt-policykit}/bin/lxqt-policykit-agent";
          Restart = "on-failure";
          RestartSec = 1;
          TimeoutStopSec = 10;
        };
      };
    };
  };
}

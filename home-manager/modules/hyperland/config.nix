{
  config,
  pkgs,
  lib,
  ...
}:
{
  wayland.windowManager.hyprland.extraConfig = ''
    exec-once = ${pkgs.swaynotificationcenter}/bin/swaync
    exec-once = waybar
    exec-once = ${pkgs.kdePackages.plasma-workspace}/bin/xembedsniproxy
    exec-once = hyprctl setcursor catppuccin-mocha-sapphire-cursors 15
    exec-once = hyprpaper & nm-applet
    exec-once = ${pkgs.brightnessctl}/bin/brightnessctl set 5
    exec-once = ${pkgs.filen-desktop}/bin/filen-desktop
    exec-once = ${pkgs.asusctl}/bin/rog-control-center
    exec-once = ${pkgs.udiskie}/bin/udiskie -t


    # See https://wiki.hyprland.org/Configuring/Monitors/
    monitor=DP-7, 3440x1440, 0x0,1
    monitor=DP-8, 2560x1440, 3440x0,1
    monitor=eDP-2, 2560x1600@165.04Hz, 0x0,1.25
    monitor=eDP-1, 2560x1600@165.04Hz, 0x0,1.25
    monitor=,highres,auto,1
    xwayland {
        force_zero_scaling = true
    }
    env = GDK_SCALE,1.25
    env = XCURSOR_SIZE,15

    # See https://wiki.hyprland.org/Configuring/Keywords/ for more
    $mainMod = ALT

    # Power - Dynamic GPU detection via script
    exec-once = ${pkgs.gpu-drm-devices}

    # For all categories, see https://wiki.hyprland.org/Configuring/Variables/
    input {
        kb_layout = de
        kb_variant =
        kb_model =
        kb_options =
        kb_rules =

        follow_mouse = 1

        touchpad {
            natural_scroll = yes
        }

        sensitivity = 1 # -1.0 - 1.0, 0 means no modification.
    }

    general {
        # See https://wiki.hyprland.org/Configuring/Variables/ for more

        gaps_in = 5
        gaps_out = 20
        border_size = 2
        col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
        col.inactive_border = rgba(595959aa)
        resize_on_border = true
        allow_tearing = true
        layout = scrolling
    }

    decoration {
        # See https://wiki.hyprland.org/Configuring/Variables/ for more

        rounding = 10

        blur {
            enabled = false
            size = 3
            passes = 1
        }
    }

    animations {
        enabled = yes

        # Some default animations, see https://wiki.hyprland.org/Configuring/Animations/ for more

        bezier = myBezier, 0.05, 0.9, 0.1, 1.05

        animation = windows, 1, 7, myBezier
        animation = windowsOut, 1, 7, default, popin 80%
        animation = border, 1, 10, default
        animation = borderangle, 1, 8, default
        animation = fade, 1, 7, default
        animation = workspaces, 1, 6, default
    }

    dwindle {
        # See https://wiki.hyprland.org/Configuring/Dwindle-Layout/ for more
        pseudotile = yes # master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
        preserve_split = yes # you probably want this
    }

    gestures {
      workspace = on
    #   workspace_swipe_cancel_ratio = 0.15
    gesture = 3, horizontal, workspace
    }

    # Asus pen
    device {
      name = elan9008:00-04f3:2fc3-stylus
      sensitivity = 1.0
      transform = 0
      output = eDP-1
    }


    plugin {
      hyprscrolling {
          column_width = 0.7
          fullscreen_on_one_column = true
      }
      touch_gestures {
        # default sensitivity is probably too low on tablet screens,
        # I recommend turning it up to 4.0
        sensitivity = 20.0

        # must be >= 3
        workspace_swipe_fingers = 3

        # resize windows by long-pressing on window borders and gaps.
        # If general:resize_on_border is enabled, general:extend_border_grab_area is used for floating
        # windows
        resize_on_border_long_press = true

        # swipe up from bottom edge
        hyprgrass-bind = , edge:d:u, exec, ${pkgs.writeScript "wvkbd-skript" ''
          #!/usr/bin/env bash
            if ${pkgs.toybox}/bin/pgrep -x 'wvkbd-mobintl' > /dev/null; then
              ${pkgs.killall}/bin/killall wvkbd-mobintl
            else
              ${pkgs.wvkbd}/bin/wvkbd-mobintl -L 300
            fi
        ''}

        # swipe down with 4 fingers
        hyprgrass-bind = , swipe:4:d, killactive

        # swipe down with 3 fingers
        hyprgrass-bind = , swipe:3:d, exec, wlogout

        # Audio swipe up and down from left edge
        hyprgrass-bind = , edge:l:u, exec, wpctl set-volume -l "1.0" @DEFAULT_AUDIO_SINK@ 6%+
        hyprgrass-bind = , edge:l:d, exec, wpctl set-volume -l "1.0" @DEFAULT_AUDIO_SINK@ 6%-

        # Brightness swipe up and down from right edge
        hyprgrass-bind = , edge:r:u, exec, brightnessctl set +5%
        hyprgrass-bind = , edge:r:d, exec, brightnessctl set 5%-

        # tap with 3 fingers
        hyprgrass-bind = , tap:3, exec, rofi -show

        hyprgrass-bindm = , longpress:2, movewindow
      }
    }

    # Example windowrule v1
    # windowrule = float, ^(kitty)$
    # Example windowrule v2
    # See https://wiki.hyprland.org/Configuring/Window-Rules/ for more

    windowrulev2 = float,title:ee-kitty
    windowrulev2 = size 95% 95%,title:ee-kitty
    windowrulev2 = center 1,title:ee-kitty

    windowrulev2 = workspace special:Filen,class:Filen
    bind = $mainMod, F, togglespecialworkspace,Filen

    windowrulev2 = workspace special:Notify,class:com.ranfdev.Notify
    bind = $mainMod, N, togglespecialworkspace,Notify

    windowrulev2 = workspace special:Signal,class:signal
    bind = $mainMod, S, exec,${pkgs.writeScript "signal" ''
      #!/usr/bin/env bash
        if ! pgrep -x "signal-desktop" > /dev/null; then
            ${pkgs.signal-desktop}/bin/signal-desktop &
        fi

        hyprctl dispatch togglespecialworkspace Signal
    ''}



    # Lockscreen
    bind = $mainMod, l, exec, hyprlock

    # Laptop lid - close
    bindl=,switch:on:Lid Switch,exec,${pkgs.writeScript "lid-close" ''
      #!/usr/bin/env bash

      # Find the internal eDP display (could be eDP-1 or eDP-2)
      edp_display=$(${pkgs.hyprland}/bin/hyprctl monitors all | ${pkgs.gnugrep}/bin/grep -oP 'Monitor \K(eDP-[0-9]+)' | head -n1)

      # Count external displays (DP- but not eDP-)
      external_count=$(${pkgs.hyprland}/bin/hyprctl monitors | ${pkgs.gnugrep}/bin/grep -oP 'Monitor \K(DP-[0-9]+)' | wc -l)

      if [ "$external_count" -eq 0 ]; then
        # No external displays, suspend
        systemctl suspend
      else
        # External displays connected, disable internal
        if [ -n "$edp_display" ]; then
          ${pkgs.hyprland}/bin/hyprctl keyword monitor "$edp_display, disable"
        fi
      fi
    ''}

    # Laptop lid - open
    bindl=,switch:off:Lid Switch,exec,${pkgs.writeScript "lid-open" ''
      #!/usr/bin/env bash

      # Find the internal eDP display
      edp_display=$(${pkgs.hyprland}/bin/hyprctl monitors all | ${pkgs.gnugrep}/bin/grep -oP 'Monitor \K(eDP-[0-9]+)' | head -n1)

      # Count external displays
      external_count=$(${pkgs.hyprland}/bin/hyprctl monitors | ${pkgs.gnugrep}/bin/grep -oP 'Monitor \K(DP-[0-9]+)' | wc -l)

      if [ "$external_count" -eq 0 ]; then
        echo "lid opened - no external displays"
      else
        # External displays connected, re-enable internal
        if [ -n "$edp_display" ]; then
          ${pkgs.hyprland}/bin/hyprctl keyword monitor "$edp_display, 2560x1600, 1280x1440, 1.25"
        fi
      fi
    ''}


    # Tablet mode
    bindl=,switch:on:Asus WMI hotkeys,exec,iio-hyprland
    bindl=,switch:on:Asus WMI hotkeys,exec, systemctl start --user wvkbd.service
    bindl=,switch:off:Asus WMI hotkeys,exec,killall iio-hyprland
    bindl=,switch:off:Asus WMI hotkeys,exec,systemctl stop --user wvkbd.service

    # Mouse
    # LMB -> 272
    # RMB -> 273
    bindm=ALT,mouse:272,movewindow


    # Brightness
    bind=,XF86MonBrightnessDown,exec,brightnessctl set 5%-
    bind=,XF86MonBrightnessUp,exec,brightnessctl set +5%
    bind=,XF86KbdBrightnessDown,exec,brightnessctl -d asus::kbd_backlight set 5%-
    bind=,XF86KbdBrightnessUp,exec,brightnessctl -d asus::kbd_backlight set +5%

    # volume
    bindle = , XF86AudioRaiseVolume, exec, wpctl set-volume -l "1.0" @DEFAULT_AUDIO_SINK@ 6%+
    bindle = , XF86AudioLowerVolume, exec, wpctl set-volume -l "1.0" @DEFAULT_AUDIO_SINK@ 6%-
    bindl = , XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
    bindl = , XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle

    # screenshot
    # stop animations while screenshotting; makes black border go away
    $screenshotarea = hyprctl keyword animation "fadeOut,0,0,default"; grimblast --notify copysave area; hyprctl keyword animation "fadeOut,1,4,default"
    bind = $mainMod, d, exec, $screenshotarea
    # bind = $mod SHIFT, R, exec, $screenshotarea
    # bind = CTRL, Print, exec, grimblast --notify --cursor copysave output
    # bind = $mod SHIFT CTRL, R, exec, grimblast --notify --cursor copysave output
    # bind = ALT, Print, exec, grimblast --notify --cursor copysave screen
    # bind = $mod SHIFT ALT, R, exec, grimblast --notify --cursor copysave screen

    # Example binds, see https://wiki.hyprland.org/Configuring/Binds/ for more
    bind = $mainMod, Q, exec, ghostty
    bind = $mainMod, Z, exec, zen
    bind = $mainMod, W, exec, env DOOMDIR=${config.home.homeDirectory}/.setup/home-manager/modules/emacs/doom EMACSDIR=${config.xdg.configHome}/emacs DOOMLOCALDIR=${config.xdg.dataHome}/doom DOOMPROFILELOADFILE=${config.xdg.stateHome}/doom-profiles-load.el ${pkgs.emacs-git-pgtk}/bin/emacs
    bind = $mainMod, C, killactive,
    bind = $mainMod, M, exit,
    bind = $mainMod, E, exec, dolphin
    bind = $mainMod, V, togglefloating,
    bind = SUPER, F, fullscreen
    # bind = $mainMod, R, exec, ulauncher-toggle
    bind = $mainMod, R, exec, rofi -show
    bind = $mainMod, P, exec, rofi-pass
    bind = $mainMod, J, togglesplit, # dwindle

    # Move focus with mainMod + arrow keys
    bind = $mainMod, left, movefocus, l
    bind = $mainMod, right, movefocus, r
    bind = $mainMod, up, movefocus, u
    bind = $mainMod, down, movefocus, d

    # Switch workspaces with mainMod + [0-9]
    bind = $mainMod, 1, workspace, 1
    bind = $mainMod, 2, workspace, 2
    bind = $mainMod, 3, workspace, 3
    bind = $mainMod, 4, workspace, 4
    bind = $mainMod, 5, workspace, 5
    bind = $mainMod, 6, workspace, 6
    bind = $mainMod, 7, workspace, 7
    bind = $mainMod, 8, workspace, 8
    bind = $mainMod, 9, workspace, 9
    bind = $mainMod, 0, workspace, 10

    # Move active window to a workspace with mainMod + SHIFT + [0-9]
    bind = $mainMod SHIFT, 1, movetoworkspace, 1
    bind = $mainMod SHIFT, 2, movetoworkspace, 2
    bind = $mainMod SHIFT, 3, movetoworkspace, 3
    bind = $mainMod SHIFT, 4, movetoworkspace, 4
    bind = $mainMod SHIFT, 5, movetoworkspace, 5
    bind = $mainMod SHIFT, 6, movetoworkspace, 6
    bind = $mainMod SHIFT, 7, movetoworkspace, 7
    bind = $mainMod SHIFT, 8, movetoworkspace, 8
    bind = $mainMod SHIFT, 9, movetoworkspace, 9
    bind = $mainMod SHIFT, 0, movetoworkspace, 10

    # Scroll through existing workspaces with mainMod + scroll
    bind = $mainMod, mouse_down, workspace, e+1
    bind = $mainMod, mouse_up, workspace, e-1

    # Move/resize windows with mainMod + LMB/RMB and dragging
    bindm = $mainMod, mouse:272, movewindow
    bindm = $mainMod, mouse:273, resizewindow

    # Move/resize windows with mainMod + arrow-keys
    bind = $mainMod, right, resizeactive, 10 0
    bind = $mainMod, left, resizeactive, -10 0
    bind = $mainMod, up, resizeactive, 0 -10
    bind = $mainMod, down, resizeactive, 0 10

    # Wlogout
    bind = $mainMod, e, exec, wlogout

    # Hyprscrolling
    bind = $mainMod, period, layoutmsg, colresize +conf
    bind = $mainMod, comma, layoutmsg, colresize -conf
    bind = $mainMod SHIFT, period, layoutmsg, movewindowto r
    bind = $mainMod SHIFT, comma, layoutmsg, movewindowto l
    bind = $mainMod SHIFT, up, layoutmsg, movewindowto u
    bind = $mainMod SHIFT, down, layoutmsg, movewindowto d
  '';
}

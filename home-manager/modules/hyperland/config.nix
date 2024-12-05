{ config, pkgs, ... }: {
  wayland.windowManager.hyprland.extraConfig = ''
    exec-once = waybar
    exec-once = ${pkgs.libsForQt5.plasma-workspace}/bin/xembedsniproxy
    exec-once = hyprctl setcursor catppuccin-mocha-sapphire-cursors 15
    exec-once = hyprpaper & kdeconnect-indicator & nm-applet
    # exec=gnome-keyring-daemon -sd
    exec-once = ${pkgs.brightnessctl}/bin/brightnessctl set 5

    # See https://wiki.hyprland.org/Configuring/Monitors/
    monitor=DP-7, 2560x1440, 0x0,1
    monitor=eDP-1, 2560x1600, 1280x1440,1.25
    monitor=DP-6, 3440x1440, 2560x0,1
    monitor=,highres,auto,1
    xwayland {
        force_zero_scaling = true
    }
    env = GDK_SCALE,1.25
    env = XCURSOR_SIZE,15


    # See https://wiki.hyprland.org/Configuring/Keywords/ for more
    $mainMod = ALT

    # Power
    env = WLR_DRM_DEVICES,/dev/dri/card1:/dev/dri/card0
    misc:vfr = true

    # Source a file (multi-file configs)
    # source = ~/.config/hypr/myColors.conf

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

        layout = dwindle
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
      workspace_swipe = on
      workspace_swipe_cancel_ratio = 0.15
    }

    # # Example per-device config
    # # See https://wiki.hyprland.org/Configuring/Keywords/#executing for more
    # device:epic-mouse-v1 {
    #     sensitivity = -0.5
    # }

    plugin {
      touch_gestures {
        # default sensitivity is probably too low on tablet screens,
        # I recommend turning it up to 4.0
        sensitivity = 10.0

        # must be >= 3
        workspace_swipe_fingers = 3

        # resize windows by long-pressing on window borders and gaps.
        # If general:resize_on_border is enabled, general:extend_border_grab_area is used for floating
        # windows
        resize_on_border_long_press = true

        # swipe up from bottom edge
        hyprgrass-bind = , edge:d:u, exec, ${
          pkgs.writeScript "wvkbd-skript" ''
            #!/usr/bin/env bash
              if ${pkgs.toybox}/bin/pgrep -x 'wvkbd-mobintl' > /dev/null; then
                ${pkgs.killall}/bin/killall wvkbd-mobintl
              else
                ${pkgs.wvkbd}/bin/wvkbd-mobintl -L 300
              fi
          ''
        }
      }
    }

    # Example windowrule v1
    # windowrule = float, ^(kitty)$
    # Example windowrule v2
    # windowrulev2 = float,class:^(kitty)$,title:^(kitty)$
    # See https://wiki.hyprland.org/Configuring/Window-Rules/ for more
    windowrulev2 = workspace special:Filen,class:Filen
    bind = $mainMod, F, togglespecialworkspace,Filen

    windowrulev2 = workspace special:Signal,class:signal
    bind = $mainMod, S, exec,${
      pkgs.writeScript "signal" ''
        #!/usr/bin/env bash
          if ! pgrep -x "signal-desktop" > /dev/null; then
              ${pkgs.signal-desktop}/bin/signal-desktop &
          fi

          hyprctl dispatch togglespecialworkspace Signal
      ''
    }



    # Lockscreen
    bind = $mainMod, l, exec, hyprlock

    # Laptop lid
    # bindl=,switch:on:Lid Switch,exec,hyprctl keyword monitor "eDP-1, 2560x1600, 1280x1440,1.25"
    bindl=,switch:on:Lid Switch,exec,${
      pkgs.writeScript "desktop-mode" ''
        #!/usr/bin/env bash
         count=$(${pkgs.hyprland}/bin/hyprctl monitors | grep -c "DP")
        if  [ $count = 2 ]; then
             hyprctl keyword monitor "eDP-1, 2560x1600, 1280x1440,1.25"
         else
             hyprctl keyword monitor "eDP-1, disable"
         fi
      ''
    }

    # bindl=,switch:off:Lid Switch,exec,hyprctl keyword monitor "eDP-1, disable"
    bindl=,switch:off:Lid Switch,exec,${
      pkgs.writeScript "desktop-mode" ''
        #!/usr/bin/env bash
         count=$(${pkgs.hyprland}/bin/hyprctl monitors | grep -c "DP")
        if  [ $count = 2 ]; then
             hyprctl keyword monitor "eDP-1, disable"
         else
             hyprctl keyword monitor "eDP-1, 2560x1600, 1280x1440,1.25"
         fi
      ''
    }

    # trigger when the switch is toggled
    $lidlock = ${
      pkgs.writeScript "desktop-mode" ''
        #!/usr/bin/env bash
         count=$(${pkgs.hyprland}/bin/hyprctl monitors | grep -c "DP")
        if  [ $count = 2 ]; then
             ${pkgs.hyprlock}/bin/hyprlock
         else
             echo "desktop-mode"
         fi
      ''
    }
    bindl=,switch:Lid Switch,exec,$lidlock

    # Tablet mode
    bindl=,switch:on:Asus WMI hotkeys,exec,iio-hyprland
    bindl=,switch:off:Asus WMI hotkeys,exec,killall iio-hyprland

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
    bind = $mainMod, Q, exec, kitty
    bind = $mainMod, C, killactive,
    bind = $mainMod, M, exit,
    bind = $mainMod, E, exec, dolphin
    bind = $mainMod, V, togglefloating,
    bind = $mainMod, R, exec, wofi --show drun
    bind = $mainMod, P, pseudo, # dwindle
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

    # Wlogout
    bind = $mainMod, e, exec, wlogout

    # swipe left from right edge
    bind = , swipe:2:l, exec, wlogout

    # swipe up from bottom edge
    bind = , swipe:4:u, exec, librewolf

    # swipe down from left edge
    bind = , edge:l:u, exec, wpctl set-volume -l "1.0" @DEFAULT_AUDIO_SINK@ 6%+
    bind = , edge:l:d, exec, wpctl set-volume -l "1.0" @DEFAULT_AUDIO_SINK@ 6%-

    # swipe down with 4 fingers
    bind = , swipe:4:d, killactive

    # swipe diagonally leftwards and downwards with 3 fingers
    # l (or r) must come before d and u
    bind = , swipe:3:ld, exec, foot
  '';
}

#!/bin/sh
# toggle tablet mode script
#
# Toggles the keyboard and touchpad on and off for tablet mode on many devices
# PLEASE ENSURE THAT YOU ARE USING GNOME OR RUNNING SOME ONBOARD KEYBOARD APP BEFORE RUNNING THIS SCRIPT.
# This toggler a system variable named TABLET_MODE, OFF and then turns it ON
# Depends on `notify-send` and `xinput` 
# if you dont have any: `brew install libnotify xinput`
# Must run using `source ./tgTABLETMODE.sh`
# would appreciate if anyone could turn this in a GNOME Plugin


if [[ $TABLET_MODE == 1 ]]; then

xinput | grep 'Touchpad' | cut -d '=' -f 2 | cut -f 1 | while read -r line; do 
xinput enable $line
done
xinput | grep 'Keyboard' | cut -d '=' -f 2 | cut -f 1 | while read -r line; do 
xinput enable $line
done


gsettings set org.gnome.desktop.a11y.applications screen-keyboard-enabled false
unset TABLET_MODE

notify-send "Tablet Mode OFF" -u critical

else

export TABLET_MODE=1
xinput | grep 'Touchpad' | cut -d '=' -f 2 | cut -f 1 | while read -r line; do 
xinput disable $line
done
xinput | grep 'Keyboard' | cut -d '=' -f 2 | cut -f 1 | while read -r line; do 
xinput disable $line
done

gsettings set org.gnome.desktop.a11y.applications screen-keyboard-enabled true

notify-send "Tablet Mode ON" -u critical

fi

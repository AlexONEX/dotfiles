#!/bin/bash

function run {
  if ! pgrep $1; then
    $@ &
  fi
}

#Find out your monitor name with xrandr or arandr (save and you get this line)
#xrandr --output VGA-1 --primary --mode 1360x768 --pos 0x0 --rotate normal
#xrandr --output DP2 --primary --mode 1920x1080 --rate 60.00 --output LVDS1 --off &
#xrandr --output LVDS1 --mode 1366x768 --output DP3 --mode 1920x1080 --right-of LVDS1
#xrandr --output HDMI2 --mode 1920x1080 --pos 1920x0 --rotate normal --output HDMI1 --primary --mode 1920x1080 --pos 0x0 --rotate normal --output VIRTUAL1 --off
#autorandr horizontal

if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
  export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"
fi

$HOME/.config/polybar/forest/launch.sh
#change your keyboard if you need it
#setxkbmap -layout be

keybLayout=$(setxkbmap -v | awk -F "+" '/symbols/ {print $2}')

if [ $keybLayout = "be" ]; then
  run sxhkd -c ~/.config/bspwm/sxhkd/sxhkdrc-azerty &
else
  run sxhkd -c ~/.config/bspwm/sxhkd/sxhkdrc &
fi

feh --bg-fill --no-fehbg -randomize ~/.local/share/wallpapers/*
dex $HOME/.config/autostart/arcolinux-welcome-app.desktop
xsetroot -cursor_name left_ptr &
#conky -c $HOME/.config/bspwm/system-overview &

#run variety &
#run nm-applet &
#run pamac-tray &

run xfce4-power-manager &
dunst &
numlockx on &
/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &
#blueberry-tray &
#picom --config $HOME/.config/bspwm/picom.conf &
#run volumeicon &
#run firefox &
#run insync start &

{
  home.file.".config/hypr/hyprpaper.conf".text = ''
    preload = ~/.setup/img/nixos_wallpaper.jpg
    #if more than one preload is desired then continue to preload other backgrounds
    # preload = /path/to/next_image.png
    # .. more preloads

    #set the default wallpaper(s) seen on inital workspace(s) --depending on the number of monitors used
    wallpaper = ,~/.setup/img/nixos_wallpaper.jpg
    #if more than one monitor in use, can load a 2nd image
    # wallpaper = monitor2,/path/to/next_image.png
    # .. more monitors
  '';
}

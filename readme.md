# This is my personal nix config for all my systems.

## For Desktop systems I prepare the system like this:
To set up one firstly needs to follow the Instructions of Graham Christensen on
[Darling Erasure](https://grahamc.com/blog/erase-your-darlings/)

To summarize:

- Create two partitions, one for /boot and one for the zfs Dataset
- partition your drive with zfs
- Create Root dataset
  - `zfs create -p -o mountpoint=legacy rpool/local/root`
- Snapshot Root dataset
  - `zfs snapshot rpool/local/root@blank`
- Mount Root dataset
  - `mount -t zfs rpool/local/root /mnt`
- Mount boot partition
  - `mkdir /mnt/boot`
  - `mount /dev/the-boot-partition /mnt/boot`
- Create and mount a dataset for /nix
  - `zfs create -p -o mountpoint=legacy rpool/local/nix`
  - `mkdir /mnt/nix`
  - `mount -t zfs rpool/local/nix /nix`
- And a dataset for /home
  - `zfs create -p -o mountpoint=legacy rpool/safe/home`
  - `mkdir /mnt/home`
  - `mount -t zfs rpool/safe/home /mnt/home`
- And finally, a dataset explicitly for state I want to persist between boots
  - `zfs create -p -o mountpoint=legacy rpool/safe/persist`
  - `mkdir /mnt/persist`
  - `mount -t zfs rpool/safe/persist /mnt/persist`

###### Note: in my systems, datasets under rpool/local are never backed up, and datasets under rpool/safe are.

And now safely erasing the root dataset on each boot is very easy: after devices
are made available, roll back to the blank snapshot:

```
{
  boot.initrd.postDeviceCommands = lib.mkAfter ''
    zfs rollback -r rpool/local/root@blank
  '';
}
```

The selection of data that should persist across reboots is done by using the
Nix Module [impermanence](https://github.com/nix-community/impermanence)

To see what your are about to loose you can run this command:

```
sudo zfs diff rpool/local/root@blank
```


Filestructure:

```
.
├── dotfiles
│   └── OKI_C332_PS.ppd
├── flake.lock
├── flake.nix
├── home-manager
│   └── modules
│       ├── alacritty.nix
│       ├── bash.nix
│       ├── dconf.nix
│       ├── default.nix
│       ├── desktop.nix
│       ├── emacs
│       │   ├── default.nix
│       │   └── doom
│       │       ├── config.el
│       │       ├── init.el
│       │       └── packages.el
│       ├── firefox.nix
│       ├── fish.nix
│       ├── foot.nix
│       ├── gnome.nix
│       ├── gtk.nix
│       ├── hyperland
│       │   ├── config.nix
│       │   ├── default.nix
│       │   ├── hyprpaper.nix
│       │   └── touch.nix
│       ├── hypridle.nix
│       ├── hyprlock.nix
│       ├── kitty.nix
│       ├── lf
│       │   ├── default.nix
│       │   └── icons
│       ├── neovim
│       │   ├── autopairs.nix
│       │   ├── bufferline.nix
│       │   ├── catppuccin.nix
│       │   ├── comment.nix
│       │   ├── completion.nix
│       │   ├── default.nix
│       │   ├── floaterm.nix
│       │   ├── gen.nix
│       │   ├── lspconfig.nix
│       │   ├── lualine.nix
│       │   ├── metals.nix
│       │   ├── none-ls.nix
│       │   ├── onedark.nix
│       │   ├── telescope.nix
│       │   ├── treesitter.nix
│       │   ├── web-devicons.nix
│       │   └── which-key.nix
│       ├── podman
│       │   ├── default.nix
│       │   └── ollama.container
│       ├── starship.nix
│       ├── swayidle.nix
│       ├── swaylock.nix
│       ├── tmux.nix
│       ├── waybar
│       │   ├── default.nix
│       │   └── style.css
│       ├── wezterm.nix
│       ├── wofi.nix
│       ├── yazi.nix
│       └── zsh.nix
├── hosts
│   ├── common
│   │   ├── configuration.nix
│   │   └── home.nix
│   ├── groot
│   │   ├── configuration.nix
│   │   ├── hardware-configuration.nix
│   │   ├── home.nix
│   │   └── opt-in.nix
│   ├── man
│   │   └── home.nix
│   ├── nixdroid
│   │   ├── home.nix
│   │   └── nix-on-droid.nix
│   └── nixnas
│       ├── configuration.nix
│       ├── hardware-configuration.nix
│       ├── home.nix
│       └── opt-in.nix
├── img
│   ├── doom.png
│   └── nixos_wallpaper.jpg
├── nixos
│   └── modules
│       ├── backrest.nix
│       ├── default.nix
│       ├── gaming.nix
│       ├── gnome.nix
│       ├── hyprland.nix
│       ├── locale_keymap.nix
│       ├── networking.nix
│       ├── nvidia.nix
│       ├── podman
│       │   ├── default.nix
│       │   ├── minio.nix
│       │   ├── nvidia.nix
│       │   ├── ollama-webui.nix
│       │   └── proxmox-backup-server.nix
│       ├── power.nix
│       ├── printing.nix
│       ├── secrets.nix
│       ├── services.nix
│       ├── sound.nix
│       ├── specialisation.nix
│       └── virtualization
│           └── default.nix
├── patches
│   ├── amd-tablet-sfh.patch
│   └── switchYandZ.patch
├── pkgs
│   ├── default.nix
│   └── iio-hyprland.nix
├── readme.md
├── scripts
│   ├── config-nix-efi.patch
│   ├── config-nix.patch
│   ├── format-disk.sh
│   └── trim-generations.sh
└── secrets
    ├── backrest-groot.age
    ├── backrest-nixnas.age
    ├── jan-nixnas.age
    ├── minio-accessKey.age
    ├── minio-secretKey.age
    ├── rclone-config.age
    ├── secrets.nix
    └── smb-secrets.age
```

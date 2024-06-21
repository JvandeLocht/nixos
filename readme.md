# This is my personal nix config.

To set up one firstly needs to follow the Instructions of Graham Christensen on [Darling Erasure](https://grahamc.com/blog/erase-your-darlings/)

To summarize:
- Create two partitions, one for /boot and one for the zfs Dataset
- partition your drive with zfs
- Create Root dataset
  - ```zfs create -p -o mountpoint=legacy rpool/local/root``` 
- Snapshot Root dataset
  - ```zfs snapshot rpool/local/root@blank``` 
- Mount Root dataset
  - ```mount -t zfs rpool/local/root /mnt``` 
- Mount boot partition
  - ```mkdir /mnt/boot``` 
  - ```mount /dev/the-boot-partition /mnt/boot``` 
- Create and mount a dataset for /nix
  - ```zfs create -p -o mountpoint=legacy rpool/local/nix``` 
  - ```mkdir /mnt/nix``` 
  - ```mount -t zfs rpool/local/nix /nix``` 
- And a dataset for /home
  - ```zfs create -p -o mountpoint=legacy rpool/safe/home```
  - ```mkdir /mnt/home```
  - ```mount -t zfs rpool/safe/home /mnt/home```
- And finally, a dataset explicitly for state I want to persist between boots
  - ```zfs create -p -o mountpoint=legacy rpool/safe/persist```
  - ```mkdir /mnt/persist```
  - ```mount -t zfs rpool/safe/persist /mnt/persist```

###### Note: in my systems, datasets under rpool/local are never backed up, and datasets under rpool/safe are.

And now safely erasing the root dataset on each boot is very easy: after devices are made available, roll back to the blank snapshot:
```
{
  boot.initrd.postDeviceCommands = lib.mkAfter ''
    zfs rollback -r rpool/local/root@blank
  '';
}
```

The selection of data that should persist across reboots is done by using the Nix Module [impermanence](https://github.com/nix-community/impermanence)

Filestructure:
```
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
│       ├── firefox.nix
│       ├── fish.nix
│       ├── gtk.nix
│       ├── hyperland
│       │   ├── config.nix
│       │   ├── default.nix
│       │   └── hyprpaper.nix
│       ├── kitty.nix
│       ├── lf
│       │   ├── default.nix
│       │   └── icons
│       ├── neovim
│       │   ├── autopairs.nix
│       │   ├── bufferline.nix
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
│       ├── nixvim
│       │   ├── autocommands.nix
│       │   ├── completion.nix
│       │   ├── default.nix
│       │   ├── keymappings.nix
│       │   ├── options.nix
│       │   ├── plugins
│       │   │   ├── barbar.nix
│       │   │   ├── cmp.nix
│       │   │   ├── comment.nix
│       │   │   ├── default.nix
│       │   │   ├── floaterm.nix
│       │   │   ├── harpoon.nix
│       │   │   ├── lsp.nix
│       │   │   ├── lualine.nix
│       │   │   ├── markdown-preview.nix
│       │   │   ├── neo-tree.nix
│       │   │   ├── none-ls.nix
│       │   │   ├── startify.nix
│       │   │   ├── telescope.nix
│       │   │   ├── treesitter.nix
│       │   │   ├── vimtex.nix
│       │   │   └── which-key.nix
│       │   └── todo.nix
│       ├── podman
│       │   ├── default.nix
│       │   └── ollama.container
│       ├── starship.nix
│       ├── swayidle.nix
│       ├── swaylock.nix
│       ├── waybar
│       │   ├── default.nix
│       │   └── style.css
│       ├── wezterm.nix
│       ├── wofi.nix
│       └── zsh.nix
├── hosts
│   ├── common
│   │   ├── configuration.nix
│   │   └── home.nix
│   ├── gnome_laptop
│   │   ├── configuration.nix
│   │   ├── hardware-configuration.nix
│   │   ├── home.nix
│   │   └── opt-in.nix
│   ├── hyprland_laptop
│   │   ├── configuration.nix
│   │   └── home.nix
│   ├── kde_laptop
│   │   ├── configuration.nix
│   │   └── home.nix
│   └── server
│       ├── configuration.nix
│       ├── hardware-configuration.nix
│       └── home.nix
├── img
│   └── nixos_wallpaper.jpg
├── kernel
│   └── patch
│       └── amd-tablet-sfh.patch
├── llama.log
├── nixos
│   └── modules
│       ├── default.nix
│       ├── gaming.nix
│       ├── gnome.nix
│       ├── locale_keymap.nix
│       ├── microvm
│       │   ├── default.nix
│       │   └── microvm.nix
│       ├── networking.nix
│       ├── nvidia.nix
│       ├── podman
│       │   ├── default.nix
│       │   └── ollama.nix
│       ├── power.nix
│       ├── printing.nix
│       ├── services.nix
│       ├── sound.nix
│       └── virtualization
│           └── default.nix
├── pkgs
│   ├── default.nix
│   └── iio-hyprland.nix
├── readme.md
└── scripts
    └── trim-generations.sh
``` 

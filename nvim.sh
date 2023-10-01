#!/bin/sh

NVIM="$HOME/.config/nvim"

if [ ! -d "$NVIM" ]; then
  git clone --depth 1 https://github.com/AstroNvim/AstroNvim $NVIM
else
  rsync -r $NVIM $HOME/.setup/nvim
fi

#!/usr/bin/env bash

# Link .vim directory
ln -s ~/.dotfiles/vim ~/.vim

# Install NeoBundle
git clone https://github.com/Shougo/neobundle.vim ~/.vim/bundle/neobundle.vim

# Install Plugins
cd ~/.vim
vim +NeoBundleInstall +qall

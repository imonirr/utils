#!/bin/bash

echo 'Deleting old files'
rm $HOME/.zshrc $HOME/.zprofile $HOME/.vimrc.local $HOME/.vimrc.before.local $HOME/.vimrc.bundles.local $HOME/.editorconfig $HOME/.eslintrc
rm -r $HOME/.config/i3

echo 'Zshrc Config'
ln -s $HOME/work/utils/dotfiles/.zshrc $HOME/.zshrc
ln -s $HOME/work/utils/dotfiles/.zprofile $HOME/.zprofile

echo 'vim Configs'
ln -s $HOME/work/utils/dotfiles/.vimrc.local $HOME/.vimrc.local
ln -s $HOME/work/utils/dotfiles/.vimrc.before.local $HOME/.vimrc.before.local
ln -s $HOME/work/utils/dotfiles/.vimrc.bundles.local $HOME/.vimrc.bundles.local
ln -s $HOME/work/utils/dotfiles/.editorconfig $HOME/.editorconfig

echo 'Eslint'
ln -s $HOME/work/utils/dotfiles/.eslintrc $HOME/.eslintrc

echo 'i3config'
ln -s $HOME/work/utils/dotfiles/config/i3 $HOME/.config/i3

echo 'neovim'
ln -s $HOME/work/utils/dotfiles/config/neovim $HOME/.config/neovim

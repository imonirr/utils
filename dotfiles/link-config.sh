#!/bin/bash

echo 'Deleting old files'
rm $HOME/.zshrc $HOME/.vimrc.local $HOME/.vimrc.before.local $HOME/.vimrc.bundles.local $HOME/.editorconfig $HOME/.eslintrc
rm $HOME/.config/i3

echo 'Zshrc Config'
ln -s $HOME/Work/dostokhan/utils/dotfiles/.zshrc $HOME/.zshrc

echo 'vim Configs'
ln -s $HOME/Work/dostokhan/utils/dotfiles/.vimrc.local $HOME/.vimrc.local
ln -s $HOME/Work/dostokhan/utils/dotfiles/.vimrc.before.local $HOME/.vimrc.before.local
ln -s $HOME/Work/dostokhan/utils/dotfiles/.vimrc.bundles.local $HOME/.vimrc.bundles.local
ln -s $HOME/Work/dostokhan/utils/dotfiles/.editorconfig $HOME/.editorconfig

echo 'Eslint'
ln -s $HOME/Work/dostokhan/utils/dotfiles/.eslintrc $HOME/.eslintrc

echo 'iconfig'
ln -s $HOME/Work/dostokhan/utils/dotfiles/.i3 $HOME/.config/i3

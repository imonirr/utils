#!/bin/bash

echo 'Deleting old files'
rm $HOME/.zshrc $HOME/.zprofile $HOME/.vimrc.local $HOME/.vimrc.before.local $HOME/.vimrc.bundles.local $HOME/.editorconfig $HOME/.eslintrc
rm -r $HOME/.config/nvim

echo 'Zshrc Config'
ln -s $HOME/work/utils/dotfiles/.zshrc $HOME/.zshrc
ln -s $HOME/work/utils/dotfiles/.zprofile $HOME/.zprofile

echo 'vim Configs'
ln -s $HOME/work/utils/dotfiles/.vimrc.local $HOME/.vimrc.local
ln -s $HOME/work/utils/dotfiles/.vimrc.before.local $HOME/.vimrc.before.local
ln -s $HOME/work/utils/dotfiles/.vimrc.bundles.local $HOME/.vimrc.bundles.local

# echo 'Editorconfig
# ln -s $HOME/work/utils/dotfiles/.editorconfig $HOME/.editorconfig

# echo 'Eslint'
# ln -s $HOME/work/utils/dotfiles/.eslintrc $HOME/.eslintrc

echo 'neovim'
ln -s $HOME/work/utils/dotfiles/config/nvim $HOME/.config/nvim

if command apt >/dev/null; then
    echo 'Debian!'

    rm -r $HOME/.config/i3
    echo 'i3config'
    ln -s $HOME/work/utils/dotfiles/config/i3 $HOME/.config/i3

elif [[ $(uname) == "Darwin" ]]; then
    echo 'OSX!'

else
    echo 'Unknown OS!'
fi

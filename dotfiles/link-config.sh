#!/bin/bash

echo 'Deleting old files(zshrc, zprofile. config/nvim, .tmux.conf'
rm $HOME/.zshrc $HOME/.zprofile $HOME/.tmux.conf
rm -r $HOME/.config/nvim

echo 'Zshrc Config'
ln -s $HOME/work/utils/dotfiles/.zshrc $HOME/.zshrc
ln -s $HOME/work/utils/dotfiles/.zprofile $HOME/.zprofile

echo 'Tmux Config'
ln -s $HOME/work/utils/dotfiles/.tmux.conf $HOME/.tmux.conf

# echo 'Editorconfig
# ln -s $HOME/work/utils/dotfiles/.editorconfig $HOME/.editorconfig

# echo 'Eslint'
# ln -s $HOME/work/utils/dotfiles/.eslintrc $HOME/.eslintrc

echo 'neovim'
ln -s $HOME/work/utils/dotfiles/config/nvim $HOME/.config/nvim

if command apt >/dev/null; then
    echo 'Debian! configs'

    rm -r $HOME/.config/i3
    echo 'i3config'
    ln -s $HOME/work/utils/dotfiles/config/i3 $HOME/.config/i3

elif [[ $(uname) == "Darwin" ]]; then
    echo 'OSX! configs'

    echo 'Aerospace '
    rm -r $HOME/.config/aerospace
    ln -s $HOME/work/utils/dotfiles/config/aerospace $HOME/.config/aerospace

else
    echo 'Unknown OS!'
fi

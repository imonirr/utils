#!/bin/bash

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo 'Deleting old files(zshrc, zprofile. config/nvim, .tmux.conf'
rm $HOME/.zshrc $HOME/.zprofile $HOME/.tmux.conf
rm -r $HOME/.config/nvim
rm -r $HOME/.zsh
rm $HOME/.config/ai
rm $HOME/.local/bin/pr-create

echo 'Zshrc Config'
ln -s "$DOTFILES_DIR/zshrc" "$HOME/.zshrc"
ln -s "$DOTFILES_DIR/zprofile" "$HOME/.zprofile"
ln -s "$DOTFILES_DIR/zsh" "$HOME/.zsh"

echo 'Tmux Config'
ln -s "$DOTFILES_DIR/tmux.conf" "$HOME/.tmux.conf"

echo 'Bin Scripts'
ln -s "$DOTFILES_DIR/bin/pr-create.sh" "$HOME/.local/bin/pr-create"

# echo 'Editorconfig
# ln -s $HOME/work/utils/dotfiles/.editorconfig $HOME/.editorconfig

# echo 'Eslint'
# ln -s $HOME/work/utils/dotfiles/.eslintrc $HOME/.eslintrc

echo 'neovim'
ln -s "$DOTFILES_DIR/config/nvim" "$HOME/.config/nvim"

echo 'AI'
ln -s "$DOTFILES_DIR/config/ai" "$HOME/.config/ai"

if command apt >/dev/null; then
    echo 'Debian! configs'

    rm -r "$HOME/.config/i3"
    echo 'i3config'
    ln -s "$DOTFILES_DIR/config/i3" "$HOME/.config/i3"

elif [[ $(uname) == "Darwin" ]]; then
    echo 'OSX! configs'

    echo 'Aerospace '
    rm -r "$HOME/.config/aerospace"
    ln -s "$DOTFILES_DIR/config/aerospace" "$HOME/.config/aerospace"

else
    echo 'Unknown OS!'
fi

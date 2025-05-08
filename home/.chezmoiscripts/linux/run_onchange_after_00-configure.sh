#!/usr/bin/env bash

set -eufo pipefail


ln -sf $HOME/.config/zsh/.zshenv $HOME/.zshenv

# Configure Linux

mv -f $HOME/.zprofile $HOME/.config/zsh/.zprofile.bak
mv -f $HOME/.zshrc $HOME/.config/zsh/.zshrc.bak
mv -f $HOME/.oh-my-zsh $HOME/.config/zsh/.oh-my-zsh.bak
rm -rf $HOME/.zsh_history

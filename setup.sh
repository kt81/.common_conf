#!/usr/bin/env bash

#
# For Mac and Linux
#

repoRoot=$(realpath $(dirname "$0"))

packagesCommon=(
    zsh tmux neovim
    git git-lfs tig
    htop glances ripgrep
    curl wget file
)

packagesMac=(
    fd
)
# ubuntu
packagesLinux=(
    fd-find build-essential apt-transport-https
)

# Shorthand
cex() {
    command -v $1 >/dev/null 2>&1;
}

# ----------------------------------
# Check Environment ($machine)
# ----------------------------------

unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     machine=Linux;;
    Darwin*)    machine=Mac;;
    CYGWIN*)    machine=Cygwin;;
    MINGW*)     machine=MinGw;;
    *)          machine="UNKNOWN:${unameOut}"
esac


# ----------------------------------
# Mac
# ----------------------------------

if [ $machine = Mac ] ; then

    # Homebrew
    if [ ! cex brew ] ; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
    fi

    # Homebrew Packages
    brew install \
        zsh tmux vim neovim \
        git git-lfs tig \
        htop glances \
        php python composer

    # anyenv
    if [ ! command -v anyenv > /dev/null 2>&1 ] ; then
        brew install anyenv
        anyenv init
        eval "$(anyenv init -)"
        anyenv install --init
    fi

    # powerline
    pip3 install --user powerline-status

    # Screenshot behaviour
    defaults write com.apple.screencapture type jpg
    defaults write com.apple.screencapture disable-shadow -bool true
    killall SystemUIServer
fi

# ----------------------------------
# Linux
# ----------------------------------

if [ $machine = 'Linux' ] ; then
    read -p "Are you sure you want to install System Packages? Please input N to skip if you are on SHARED SERVER. (y/N): " -n 1 -r inst
    echo
    if [[ $inst =~ ^[Yy]$ ]] ; then
        sudo apt update
        sudo apt install -y ${packagesCommon[@]} ${packagesLinux[@]}

        wget -q https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb
        sudo dpkg -i packages-microsoft-prod.deb
        sudo apt update
        sudo add-apt-repository universe
        sudo apt install -y powershell
        rm packages-microsoft-prod.deb
    fi
fi

# ----------------------------------
# ZSH
# ----------------------------------
[ -e ~/.zshrc ] || ln -s $repoRoot/.zshrc ~/.zshrc
[ -e ~/.zinit ] || sh -c "$(curl -fsSL https://raw.githubusercontent.com/zdharma/zinit/master/doc/install.sh)"
sudo chsh $USER -s $(which zsh)

# ----------------------------------
# Common and PowerShell
# ----------------------------------
command -v pwsh > /dev/null 2>&1  && pwsh $repoRoot/setup.ps1

# ----------------------------------
# Common over *NIX Platforms
# ----------------------------------
if [ ! -e ~/.fzf ] ; then
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install
fi

if ! command -v asdf > /dev/null 2>&1 ; then
    git clone https://github.com/asdf-vm/asdf.git ~/.asdf
    cd ~/.asdf
    git checkout "$(git describe --abbrev=0 --tags)"
fi

sudo chsh $USER -s $(which zsh)
zsh

# vim: et:ts=4:sw=4:ft=bash

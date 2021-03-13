#!/bin/bash

# Utils
function is_installed {
  # set to 1 initially
  local return_=1
  # set to 0 if not found
  type $1 >/dev/null 2>&1 || { local return_=0;  }
  # return
  echo "$return_"
}

# Install with apt
# to use: install @software_name @package_name
function install_with_apt() {
    if [ "$(is_installed $2)" == "0" ]; then
        echo "Installing $1"
        apt-get install $2 -y
    fi
}

# Install from git repository
# to use: install_from_git @software_name @git_repository_link
function install_from_git() {
    echo "Installing $1"
    git clone $2
}


function install_ubuntu_based_linux {
    if [[ $OSTYPE != linux* ]]; then
        return
    fi
    echo "Linux detected!"

    if [[ $(cat /etc/issue) != Ubuntu* ]]; then
        return
    fi
    echo "Ubuntu based Linux detected!"

    install_with_apt "Zsh" zsh

    install_with_apt "Git" git

    install_with_apt "Tmux" tmux
    
    install_from_git "tmux-plugin-manager" "https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm"
       
    install_with_apt "The silver researcher" silversearcher-ag
  
    install_with_apt "Fzf" fzf

    install_with_apt "Neovim" neovim


}


function backup {
  echo "Backing up dotfiles"
  local current_date=$(date +%s)
  local backup_dir=dotfiles_$current_date

  mkdir ~/$backup_dir

  mv ~/.zshrc ~/$backup_dir/.zshrc
  mv ~/.tmux.conf ~/$backup_dir/.tmux.conf
  mv ~/.vim ~/$backup_dir/.vim
  mv ~/.vimrc ~/$backup_dir/.vimrc
  mv ~/.vimrc.bundles ~/$backup_dir/.vimrc.bundles
}

function link_dotfiles {
    echo "Linking dotfiles"

    ln -s $(pwd)/zshrc ~/.zshrc
    ln -s $(pwd)/tmux.conf ~/.tmux.conf
    ln -s $(pwd)/vim ~/.vim
    ln -s $(pwd)/vimrc ~/.vimrc
    ln -s $(pwd)/vimrc.bundles ~/.vimrc.bundles

    if [ ! -d "~/.oh-my-zsh" ]; then
        echo "Installing oh-my-zsh"
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    fi
    
    if [ ! -f "~/.vim/autoload/plug.vim"]; then
        echo "Installing Vim-Plug"
        curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
            https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    fi

    if [ ! -d "$ZSH/custom/plugins/zsh-autosuggestions" ]; then
        echo "Installing zsh-autosuggestions"
        git clone git://github.com/zsh-users/zsh-autosuggestions $ZSH/custom/plugins/zsh-autosuggestions
    fi

    if [ ! -d "$ZSH/custom/plugins/zsh-autosuggestions" ]; then
        echo "Installing zsh-autosuggestions"
        git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    fi

    echo "Cleaning up"
    rm -rf $HOME/.config/nvim/init.vim
    rm -rf $HOME/.config/nvim

    mkdir -p ${XDG_CONFIG_HOME:=$HOME/.config}
    ln -s $(pwd)/vim $XDG_CONFIG_HOME/nvim
    ln -s $(pwd)/vimrc $XDG_CONFIG_HOME/nvim/init.vim
}

while test $# -gt 0; do
    case "$1" in
        --help)
            echo "Help"
            exit
            ;;
        --linux)
            install_ubuntu_based_linux
            backup
            link_dotfiles
            zsh
            source ~/.zshrc
            exit
            ;;
        --backup)
            backup
            exit
            ;;
        --dotfiles)
            link_dotfiles
            exit;;
    esac

    shift
done


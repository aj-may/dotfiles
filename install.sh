#!/usr/bin/env bash

DOTFILES_PATH="$(dirname $0)"

# Install command line tools
if pkgutil --pkg-info com.apple.pkg.CLTools_Executables &> /dev/null; then
    echo 'Xcode Command Line Tools already installed.'
else
    echo 'Installing Xcode Command Line Tools...'
    xcode-select --install
    echo 'Done.'
fi

# Install Homebrew
if hash brew; then
    echo 'Homebrew already installed.'
else
    echo 'Installing Homebrew...'
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    echo 'Done.'
fi

# Brew install packages
echo "Installing Homebrew Packages..."
brew update
brew install $(cat $DOTFILES_PATH/brew/packages.txt)
echo 'Done.'

# Brew install casks
echo "Installing Homebrew Casks..."
brew cask install $(cat $DOTFILES_PATH/brew/casks.txt)
echo 'Done.'

# Append ZSH path to /etc/shells
if cat /etc/shells | grep -q '/usr/local/bin/zsh'; then
    echo 'ZSH already listed in /etc/shells.'
else
    echo 'Appending ZSH to /etc/shells...'
    echo '/usr/local/bin/zsh' | sudo tee -a /etc/shells
    echo 'Done.'
fi

# chsh
if [ "$SHELL" = "/usr/local/bin/zsh" ]; then
    echo 'ZSH is already your default login shell.'
else
    echo 'Setting ZSH as your default login shell...'
    chsh -s /usr/local/bin/zsh
    echo 'Done.'
fi

# Install Oh-my-zsh
if [ -d "$HOME/.oh-my-zsh" ]; then
    echo 'Oh-my-zsh is already installed.'
else
    echo 'Installing Oh-my-zsh...'
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
    echo 'Done.'
fi

# Install Spaceship Theme
if [ -d "$HOME/.oh-my-zsh/custom/themes/spaceship-prompt" ]; then
    echo 'Spaceship Theme already installed.'
else
    echo 'Installing Spaceship Theme...'
    git clone https://github.com/denysdovhan/spaceship-prompt.git "$HOME/.oh-my-zsh/custom/themes/spaceship-prompt"
    ln -s "$HOME/.oh-my-zsh/custom/themes/spaceship-prompt/spaceship.zsh-theme" "$HOME/.oh-my-zsh/custom/themes/spaceship.zsh-theme"
fi

# use stow for config files
echo 'Installing stow configuration packages...'
ls -1 ${DOTFILES_PATH}/stow | xargs -L 1 stow -d "${DOTFILES_PATH}/stow" -t "${HOME}"
echo 'Done.'

# Configure sublime and terminal

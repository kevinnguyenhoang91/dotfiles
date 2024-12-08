#!/bin/zsh

# Install Homebrew
if ! command -v brew &> /dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Install Homebrew packages
cd brew && brew bundle

# oh-my-zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

mkdir -p ~/.zsh
git clone https://github.com/catppuccin/zsh-syntax-highlighting.git
cp -RLf zsh-syntax-highlighting/themes/catppuccin_mocha-zsh-syntax-highlighting.zsh ~/.zsh/
rm -rf zsh-syntax-highlighting

# stow
[[ -f ~/.zshrc ]] && rm -rf ~/.zshrc
[[ -d ~/.config/lazygit ]] && rm -rf ~/.config/lazygit
[[ -d ~/.ctags.d ]] && rm -rf ~/.ctags.d
[[ -d ~/.config/alacritty ]] && rm -rf ~/.config/alacritty
[[ -f ~/.ssh/config ]] && rm -rf ~/.ssh/config
[[ -d ~/.config/nvim ]] && rm -rf ~/.config/nvim
[[ -f ~/.netrc ]] && rm -rf ~/.netrc
[[ -f ~/.shellcheckrc ]] && rm -rf ~/.shellcheckrc
[[ -f ~/.bazelrc ]] && rm -rf ~/.bazelrc
[[ -f ~/.rgrc ]] && rm -rf ~/.rgrc
[[ -f ~/.gemrc ]] && rm -rf ~/.gemrc
[[ -f ~/.tigrc ]] && rm -rf ~/.tigrc
[[ -f ~/.gitignore ]] && rm -rf ~/.gitignore
[[ -f ~/.gitconfig ]] && rm -rf ~/.gitconfig
[[ -f ~/.tmux.conf ]] && rm -rf ~/.tmux.conf
make stow

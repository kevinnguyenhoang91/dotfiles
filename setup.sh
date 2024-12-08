#!/bin/zsh

# Install Command Line Tools
xcode-select --install

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

# Xcode
git clone https://github.com/catppuccin/xcode.git
mkdir -p ~/Library/Developer/Xcode/UserData/FontAndColorThemes
cp -RLf xcode/dist/Catppuccin\ Frappe.xccolortheme ~/Library/Developer/Xcode/UserData/FontAndColorThemes
rm -rf xcode

# GPG
echo "pinentry-program $(which pinentry-mac)" >> ~/.gnupg/gpg-agent.conf
killall gpg-agent

# stow
[[ -f ~/.zshrc ]] && rm -rf ~/.zshrc
[[ -d ~/Library/Application\ Support/lazygit ]] && rm -rf ~/Library/Application\ Support/lazygit
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

# Free the Dock
defaults write com.apple.Dock size-immutable -bool no

# Remove the auto-hiding Dock delay
defaults write com.apple.Dock autohide-delay -float 0

# Remove the animation when hiding/showing the Dock
defaults write com.apple.Dock autohide-time-modifier -float 0.5

# Set the icon size of Dock items
defaults write com.apple.Dock tilesize -int 42

# Disable press-and-hold for keys in favor of key repeat
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# Set a blazingly fast keyboard repeat rate
defaults write NSGlobalDomain KeyRepeat -int 2 # normal minimum is 2 (30 ms)
defaults write NSGlobalDomain InitialKeyRepeat -int 15 # normal minimum is 15 (225 ms)

# Shadow in screenshots
defaults write com.apple.screencapture disable-shadow -bool false

# Enable font smoothing
defaults write -g CGFontRenderingFontSmoothingDisabled -bool NO

# Enable subpixel font rendering on non-Apple LCDs
# https://github.com/kevinSuttle/macOS-Defaults/issues/17#issuecomment-266633501
defaults write NSGlobalDomain AppleFontSmoothing -int 3

# VSCode Vim
defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false

killall Dock

# PMSet
sudo pmset -a gpuswitch 2

# Battery Power
sudo pmset -b lidwake 0
sudo pmset -b standbydelayhigh 900
sudo pmset -b standbydelaylow 300
sudo pmset -b standby 1
sudo pmset -b proximitywake 1
sudo pmset -b ttyskeepawake 1
sudo pmset -b highstandbythreshold 40
sudo pmset -b powernap 0
sudo pmset -b hibernatemode 3
sudo pmset -b displaysleep 1
sudo pmset -b sleep 10
sudo pmset -b tcpkeepalive 1
sudo pmset -b halfdim 1
sudo pmset -b acwake 0
sudo pmset -b lessbright 1
sudo pmset -b disksleep 15
sudo pmset -b womp 0
sudo pmset -b autorestart 0

# AC Adapter
sudo pmset -c lidwake 0
sudo pmset -c standbydelayhigh 3600
sudo pmset -c standbydelaylow 1800
sudo pmset -c standby 1
sudo pmset -c proximitywake 1
sudo pmset -c ttyskeepawake 1
sudo pmset -c hibernatemode 3
sudo pmset -c powernap 0
sudo pmset -c highstandbythreshold 40
sudo pmset -c womp 1
sudo pmset -c displaysleep 10
sudo pmset -c sleep 30
sudo pmset -c tcpkeepalive 1
sudo pmset -c halfdim 0
sudo pmset -c acwake 0
sudo pmset -c disksleep 15
sudo pmset -c autorestart 0

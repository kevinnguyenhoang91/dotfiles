#!/bin/zsh

# Install Homebrew
if ! command -v brew &> /dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
[ -f /home/linuxbrew/.linuxbrew/bin/brew ] && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# Install Homebrew packages
cd brew && brew bundle
cd "$HOME"

# oh-my-zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

mkdir -p ~/.zsh
git clone https://github.com/catppuccin/zsh-syntax-highlighting.git
cp -RLf zsh-syntax-highlighting/themes/catppuccin_mocha-zsh-syntax-highlighting.zsh ~/.zsh/
rm -rf zsh-syntax-highlighting

git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

# Nerd Fonts
mkdir -p "${HOME}/.local/share/fonts"
curl -fsSL https://raw.githubusercontent.com/getnf/getnf/main/install.sh | bash
getnf -i 'Noto,FiraMono,FiraCode,Meslo'

# atuin
if command -v atuin &> dev/null; then
  eval "$(atuin init zsh)"
fi

# superfile
bash -c "$(curl -sLo- https://superfile.netlify.app/install.sh)"

#!/bin/zsh

# mkdir -p ~/.zsh
# git clone https://github.com/catppuccin/zsh-syntax-highlighting.git
# cp -RLf zsh-syntax-highlighting/themes/catppuccin_mocha-zsh-syntax-highlighting.zsh ~/.zsh/
# rm -rf zsh-syntax-highlighting
#
# git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
#
# # Nerd Fonts
# mkdir -p "${HOME}/.local/share/fonts"
# curl -fsSL https://raw.githubusercontent.com/getnf/getnf/main/install.sh | bash
# getnf -i 'Noto,FiraMono,FiraCode,Meslo'
#
# # atuin
# if command -v atuin &> dev/null; then
#   eval "$(atuin init zsh)"
# fi
# ||||||| parent of 64e0d5671e08 (feat: add devcontainer setup to Makefile)
# mkdir -p ~/.zsh
# git clone https://github.com/catppuccin/zsh-syntax-highlighting.git
# cp -RLf zsh-syntax-highlighting/themes/catppuccin_mocha-zsh-syntax-highlighting.zsh ~/.zsh/
# rm -rf zsh-syntax-highlighting
#
# git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
#
# # Nerd Fonts
# mkdir -p "${HOME}/.local/share/fonts"
# curl -fsSL https://raw.githubusercontent.com/getnf/getnf/main/install.sh | bash
# getnf -i 'Noto,FiraMono,FiraCode,Meslo'

make devcontainer

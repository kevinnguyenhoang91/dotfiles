.PHONY: all
all: stow

.PHONY: stow
stow:
	@stow -t ~ tmux gitmux git ruby ripgrep bazel shellcheck netrc zsh bash tig brew iterm p10k tmuxp

	mkdir -p ~/.config/alacritty
	@stow -t ~/.config/alacritty alacritty

	mkdir -p ~/.config/nvim
	@stow -t ~/.config/nvim nvim

	mkdir -p ~/.ssh
	@stow -t ~/.ssh ssh

	mkdir -p ~/.ctags.d
	@stow -t ~/.ctags.d ctags

	mkdir -p ~/Library/Application\ Support/k9s
	@stow -t ~/Library/Application\ Support/k9s k9s

	mkdir -p ~/Library/Application\ Support/lazygit
	@stow -t ~/Library/Application\ Support/lazygit lazygit

	mkdir -p ~/Library/Application\ Support/lazydocker
	@stow -t ~/Library/Application\ Support/lazydocker lazydocker

.PHONY: unstow
unstow:
	@stow -D -t ~ tmux gitmux git ruby ripgrep bazel shellcheck netrc zsh bash tig brew iterm p10k tmuxp
	@stow -D -t ~/.config/alacritty alacritty
	@stow -D -t ~/.config/nvim nvim
	@stow -D -t ~/.ssh ssh
	@stow -D -t ~/.ctags.d ctags
	@stow -D -t ~/Library/Application\ Support/lazygit lazygit
	@stow -D -t ~/Library/Application\ Support/k9s k9s
	@stow -D -t ~/Library/Application\ Support/lazydocker lazydocker

.PHONY: setup
setup:
	@./setup.sh

.PHONY: all
all: stow

.PHONY: stow
stow:
	@stow -t ~ tmux gitmux git ruby ripgrep bazel shellcheck netrc zsh bash tig p10k tmuxp

	mkdir -p ~/.config/alacritty
	@stow -t ~/.config/alacritty alacritty

	mkdir -p ~/.config/nvim
	@stow -t ~/.config/nvim nvim

	mkdir -p ~/.ssh
	@stow -t ~/.ssh ssh

	mkdir -p ~/.ctags.d
	@stow -t ~/.ctags.d ctags

	mkdir -p ~/.config/k9s
	@stow -t ~/.config/k9s k9s

	mkdir -p ~/Library/Application\ Support/lazygit
	@stow -t ~/Library/Application\ Support/lazygit lazygit

	mkdir -p ~/.agent-os
	@stow -t ~/.agent-os agent-os

	mkdir -p ~/.config/opencode
	@stow -t ~/.config/opencode opencode

.PHONY: unstow
unstow:
	@stow -D -t ~ tmux gitmux git ruby ripgrep bazel shellcheck netrc zsh bash tig p10k tmuxp
	@stow -D -t ~/.config/alacritty alacritty
	@stow -D -t ~/.config/nvim nvim
	@stow -D -t ~/.ssh ssh
	@stow -D -t ~/.ctags.d ctags
	@stow -D -t ~/.config/k9s k9s
	@stow -D -t ~/Library/Application\ Support/lazygit lazygit
	@stow -D -t ~/.agent-os agent-os
	@stow -D -t ~/.config/opencode opencode

.PHONY: setup
setup:
	@./setup.sh

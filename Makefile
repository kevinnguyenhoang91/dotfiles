.PHONY: all
all: stow

.PHONY: stow
stow:
	@stow -t ~ tmux gitmux git ruby ripgrep bazel shellcheck netrc

	mkdir -p ~/.config/alacritty
	@stow -t ~/.config/alacritty alacritty

	mkdir -p ~/.config/nvim
	@stow -t ~/.config/nvim nvim

	mkdir -p ~/.ssh
	@stow -t ~/.ssh ssh

	mkdir -p ~/.ctags.d
	@stow -t ~/.ctags.d ctags

.PHONY: unstow
unstow:
	@stow -D -t ~ tmux gitmux git ruby ripgrep bazel shellcheck netrc
	@stow -D -t ~/.config/alacritty alacritty
	@stow -D -t ~/.config/nvim nvim
	@stow -D -t ~/.ssh ssh
	@stow -D -t ~/.ctags.d ctags

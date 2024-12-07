.PHONY: all
all: stow

.PHONY: stow
stow:
	@stow -t ~ tmux gitmux git
	@stow -t ~/.config/alacritty alacritty

.PHONY: unstow
unstow:
	@stow -D -t ~ tmux gitmux git
	@stow -D -t ~/.config/alacritty alacritty

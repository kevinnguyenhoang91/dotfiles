.PHONY: all
all: stow

.PHONY: stow
stow:
	@stow -t ~ tmux gitmux
	@stow -t ~/.config/alacritty alacritty

.PHONY: unstow
unstow:
	@stow -D -t ~ tmux gitmux
	@stow -D -t ~/.config/alacritty alacritty

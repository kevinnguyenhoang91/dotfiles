.PHONY: all
all: stow

.PHONY: stow
stow:
	@stow -t ~ tmux gitmux

.PHONY: unstow
unstow:
	@stow -D -t ~ tmux gitmux

.PHONY: all
all: stow

.PHONY: stow
stow:
	@stow -t ~ sample

.PHONY: unstow
unstow:
	@stow -D -t ~ sample

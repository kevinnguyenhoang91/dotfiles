.PHONY: all
all: stow

.PHONY: stow
stow:
	@stow -t ~ tmux gitmux git
	mkdir -p ~/.config/alacritty
	@stow -t ~/.config/alacritty alacritty
	mkdir -p ~/.config/nvim
	@stow -t ~/.config/nvim nvim
	mkdir -p ~/.config/nvim_huyvohcmc
	@stow -t ~/.config/nvim_huyvohcmc nvim_huyvohcmc

.PHONY: unstow
unstow:
	@stow -D -t ~ tmux gitmux git
	@stow -D -t ~/.config/alacritty alacritty
	@stow -D -t ~/.config/nvim nvim
	@stow -D -t ~/.config/nvim_huyvohcmc nvim_huyvohcmc

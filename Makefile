.PHONY: all
all: stow

.PHONY: stow
stow:
	@stow -t ~ tmux zsh git tig ruby ripgrep
	
	mkdir -p ~/.config/nvim
	@stow -t ~/.config/nvim nvim
	
	mkdir -p ~/.ssh
	@stow -t ~/.ssh ssh
	
	mkdir -p ~/.config/alacritty
	@stow -t ~/.config/alacritty alacritty
	
	mkdir -p ~/.ctags.d
	@stow -t ~/.ctags.d ctags

.PHONY: unstow
unstow:
	@stow -D -t ~ tmux zsh git tig ruby ripgrep ctags
	@stow -D -t ~/.config/nvim nvim
	@stow -D -t ~/.ssh ssh
	@stow -D -t ~/.config/alacritty alacritty

.PHONY: brew_bundle
brew_bundle:
	cd macos && brew bundle

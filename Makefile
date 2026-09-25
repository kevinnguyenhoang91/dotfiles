.PHONY: all
all: stow

.PHONY: stow
stow:
	@stow -t ~ tmux gitmux git ruby ripgrep bazel shellcheck netrc zsh bash tig brew iterm p10k tmuxp

	mkdir -p ~/.config/alacritty
	@stow -t ~/.config/alacritty alacritty

	mkdir -p ~/.config/nvim
	@stow -t ~/.config/nvim nvim

	mkdir -p ~/.config/herdr
	@stow -t ~/.config/herdr herdr

	mkdir -p ~/.config/kitty
	@stow -t ~/.config/kitty kitty

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
	
	mkdir -p ~/.config/opencode
	@stow -t ~/.config/opencode opencode

	mkdir -p ~/.claude
	@stow -t ~/.claude claude

	mkdir -p ~/.omp
	@stow -t ~/.omp omp

	mkdir -p ~/.omo
	@stow -t ~/.omo omo

.PHONY: unstow
unstow:
	@stow -D -t ~ tmux gitmux git ruby ripgrep bazel shellcheck netrc zsh bash tig brew iterm p10k tmuxp
	@stow -D -t ~/.config/alacritty alacritty
	@stow -D -t ~/.config/nvim nvim
	@stow -D -t ~/.config/herdr herdr
	@stow -D -t ~/.config/kitty kitty
	@stow -D -t ~/.ssh ssh
	@stow -D -t ~/.ctags.d ctags
	@stow -D -t ~/Library/Application\ Support/lazygit lazygit
	@stow -D -t ~/Library/Application\ Support/k9s k9s
	@stow -D -t ~/Library/Application\ Support/lazydocker lazydocker
	@stow -D -t ~/.config/opencode opencode
	@stow -D -t ~/.claude claude
	@stow -D -t ~/.omp omp
	@stow -D -t ~/.omo omo

.PHONY: setup
setup:
	@./setup.sh

# Re-links herdr after a plugin rewrites ~/.config/herdr/config.toml as a real file:
# adopts the current target content into the package, then re-symlinks.
.PHONY: herdr-sync
herdr-sync:
	@stow --adopt -t ~/.config/herdr herdr

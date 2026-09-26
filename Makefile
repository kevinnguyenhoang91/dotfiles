.PHONY: all
all: stow

.PHONY: stow
stow:
	@stow -t ~ tmux gitmux git ruby ripgrep bazel shellcheck netrc zsh bash tig p10k tmuxp

	mkdir -p ~/.config/alacritty
	@stow -t ~/.config/alacritty alacritty

	mkdir -p ~/.config/nvim
	@stow -t ~/.config/nvim nvim

	mkdir -p ~/.config/herdr
	@stow -t ~/.config/herdr herdr

	mkdir -p ~/.ssh
	@stow -t ~/.ssh ssh

	mkdir -p ~/.ctags.d
	@stow -t ~/.ctags.d ctags

	mkdir -p ~/.config/k9s
	@stow -t ~/.config/k9s k9s

	mkdir -p ~/.config/lazygit
	@stow -t ~/.config/lazygit lazygit

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
	@stow -D -t ~ tmux gitmux git ruby ripgrep bazel shellcheck netrc zsh bash tig p10k tmuxp
	@stow -D -t ~/.config/alacritty alacritty
	@stow -D -t ~/.config/nvim nvim
	@stow -D -t ~/.config/herdr herdr
	@stow -D -t ~/.ssh ssh
	@stow -D -t ~/.ctags.d ctags
	@stow -D -t ~/.config/k9s k9s
	@stow -D -t ~/.config/lazygit lazygit
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

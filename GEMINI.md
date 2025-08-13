# Gemini Workspace Context: Dotfiles

This directory, `~/dotfiles`, contains personal configuration files for various development tools. It is managed using `stow` to symlink the files into their correct locations.

## Overview

This is a classic "dotfiles" repository. The primary purpose is to maintain a consistent development environment across different machines. The configurations are highly customized, indicating a sophisticated user who prefers a terminal-centric workflow.

The core components of this setup are:

*   **Shell:** Zsh (with Oh My Zsh) and Bash as a fallback. Powerlevel10k is used for the Zsh prompt.
*   **Terminal Multiplexer:** `tmux` with a rich set of plugins.
*   **Editor:** Neovim (LazyVim distribution) with Lua-based configuration.
*   **Version Control:** Git with several aliases and configurations for `delta` as a pager.
*   **Package Management:** Homebrew is used to install various command-line tools.

## Key Technologies & Tools

*   **Shell:** `zsh`, `bash`, `oh-my-zsh`, `powerlevel10k`
*   **Editor:** `nvim` (Neovim), configured with Lua and LazyVim.
*   **Terminal:** `tmux`, `alacritty`
*   **Version Control:** `git`, `lazygit`, `gitmux`
*   **Package Managers:** `brew`, `nvm`, `asdf`
*   **Languages/Runtimes:** Node.js, Go, Rust, Ruby, Python, Java, Flutter/Dart
*   **Tools:** `fzf`, `ripgrep`, `fd`, `lazydocker`, `thefuck`, `atuin`, `btop`, `direnv`, `k9s`

## Building and Running

There is no "building" or "running" in the traditional sense. The primary action is to "install" the dotfiles using `stow`.

The `Makefile` provides the following targets:

*   `make stow`: Symlinks the configuration files to the appropriate locations in the user's home directory.
*   `make unstow`: Removes the symlinks.
*   `make setup`: Runs the `setup.sh` script, which likely installs dependencies.

## Development Conventions

This repository is for personal configuration, so there are no formal contribution guidelines. However, the structure is well-organized by tool.

*   Each tool's configuration is contained within its own directory (e.g., `nvim/`, `tmux/`, `zsh/`).
*   `stow` is used to manage the symlinking of these configurations.
*   Secrets are likely managed in a separate, untracked file (`.secrets.zsh`).
*   Platform-specific configurations are handled via `.bash_platform` and `.zplatform` files.
*   The user prefers the Catppuccin theme (Frappé flavor) across multiple tools (Alacritty, Neovim, tmux).

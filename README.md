# Kevin Nguyen's Dotfiles

This repository contains my personal dotfiles, meticulously configured for a streamlined and efficient development workflow. The setup is managed with `stow` and is centered around a terminal-based environment using tools like Zsh, Neovim, and tmux.

![Catppuccin Theme](https://raw.githubusercontent.com/catppuccin/catppuccin/main/assets/palette/frappe.png)

The entire setup is themed with the beautiful **Catppuccin (Frappé)** color scheme for a consistent look and feel across all tools.

## Features

This dotfiles setup includes configurations for:

*   **Shell:** Zsh with Oh My Zsh, Powerlevel10k, and numerous plugins for enhanced productivity.
*   **Editor:** Neovim (using the LazyVim distribution) with extensive Lua-based customizations.
*   **Terminal:** Alacritty as the terminal emulator and tmux for session management, both heavily customized.
*   **Version Control:** Git with useful aliases, `lazygit` for a terminal UI, and `delta` for beautiful diffs.
*   **Package Managers:** Homebrew for system packages, `nvm` for Node.js, and `asdf` for managing multiple runtime versions.
*   **Tools:** A suite of powerful command-line tools like `fzf`, `ripgrep`, `fd`, `lazydocker`, `k9s`, and more.

## Installation

1.  **Clone the repository:**

    ```sh
    git clone https://github.com/kevinnguyenhoang91/dotfiles.git "$HOME/dotfiles"
    cd "$HOME/dotfiles"
    ```

2.  **Install Dependencies:**

    This setup relies on several tools. You can install them using the provided `setup.sh` script (which assumes you have Homebrew on macOS or Linux).

    ```sh
    ./setup.sh
    ```

    Alternatively, you can review the `brew/Brewfile` and install the packages manually with your system's package manager. You will also need `stow`.

3.  **Stow the Dotfiles:**

    Before proceeding, **back up your existing dotfiles**. This process will overwrite them.

    Use the `Makefile` to symlink the configurations into your home directory.

    ```sh
    make stow
    ```

4.  **Post-installation:**

    *   Open `tmux` and press `Ctrl-b` + `I` to install the tmux plugins.
    *   Launch Neovim (`nvim`) and the Lazy.nvim plugin manager will automatically install all the plugins.

## Usage

*   **Symlinking:** The `Makefile` contains the primary commands for managing the dotfiles:
    *   `make stow`: Creates the symlinks.
    *   `make unstow`: Removes the symlinks.
*   **Secrets:** Create a `.secrets.zsh` file in your home directory to store any private environment variables. This file is sourced by `.zshrc` but is not tracked by git.

## Acknowledgement

- [huyvohcmc’s dotfiles](https://github.com/huyvohcmc/dotfiles)

## License

This repository is available under the [MIT license](LICENSE). Feel free to fork and modify the dotfiles as you please.
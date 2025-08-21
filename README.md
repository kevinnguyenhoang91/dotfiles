# **kevinnguyenhoang91's** Dotfiles

This repository contains my personal dotfiles for various tools I use in my daily development workflow.

## Prerequisites

Before you begin, ensure you have the following tools installed:

- [Git](https://git-scm.com/) for cloning the repository.
- [Stow](https://www.gnu.org/software/stow/) for managing dotfiles symlinks.
- [curl](https://curl.se/) for downloading installers.

You can typically install these using your system's package manager (e.g., Homebrew on macOS).

## Installation

The installation process is divided into two main steps: running the setup script and stowing the dotfiles.

**Step 1: Run the Setup Script**

First, clone the repository to your local machine:

```sh
git clone https://github.com/kevinnguyenhoang91/dotfiles.git "$HOME/dotfiles"
cd "$HOME/dotfiles"
```

Next, run the main setup script. This will install necessary system tools, applications, and configure your environment.

```sh
./setup.sh
```

The `setup.sh` script will:
- Install Xcode Command Line Tools.
- Install Homebrew and packages from the `brew/Brewfile`.
- Set up Oh My Zsh with plugins.
- Configure macOS defaults for a better user experience.
- Install and configure `asdf` with a wide range of plugins for managing different language versions.
- Set up plugin managers for Tmux and Neovim.

**Step 2: Stow the Dotfiles**

After the setup script completes, use the `Makefile` to create symlinks for the dotfiles in your home directory:

```sh
make stow
```

To remove the symlinks, you can use:

```sh
make unstow
```

## Configured Tools

These dotfiles include configurations for the following tools:

- **Shell:** Zsh, Bash, Oh My Zsh, Powerlevel10k
- **Terminal:** Alacritty, iTerm2
- **Editors:** Neovim, VSCode
- **Multiplexers:** Tmux, tmuxp
- **Git:** Git, Lazygit, Gitmux
- **Containerization:** Lazydocker
- **Kubernetes:** k9s
- **Languages & Runtimes:** Managed via `asdf` (e.g., Node.js, Python, Go, Ruby, Rust, and many more)
- **Other Tools:** Ripgrep, Tig, Bazel, Shellcheck, and more.

## Customization

You can customize the setup by:

- **Adding or removing Homebrew packages:** Modify the `brew/Brewfile` and rerun `brew bundle` from within the `brew` directory.
- **Adding or removing `asdf` plugins:** Edit the `setup.sh` script to include or exclude `asdf` plugins for the languages and tools you need.
- **Customizing tool configurations:** Most configurations are located in their respective directories (e.g., `nvim/`, `alacritty/`). You can edit these files to match your preferences.

## Acknowledgement

- [huyvohcmc’s dotfiles](https://github.com/huyvohcmc/dotfiles)

## License

This repository is available under the [MIT license](LICENSE). Feel free to fork and modify the dotfiles as you please.
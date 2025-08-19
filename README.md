# 🏠 Dotfiles Configuration

A comprehensive, terminal-centric development environment featuring the beautiful **Catppuccin (Frappé)** theme for a consistent, productive workflow across all tools.

![Catppuccin Frappé Theme](https://raw.githubusercontent.com/catppuccin/catppuccin/main/assets/palette/frappe.png)

## 🌟 Overview

This dotfiles repository provides a complete development environment setup, optimized for terminal-based workflows with modern tools and thoughtful configurations. Every component is carefully themed with Catppuccin Frappé for visual consistency and enhanced productivity.

## 📦 What's Included

### 🐚 Shell & Terminal
- **Zsh** with Oh My Zsh framework
- **af-magic** theme with extensive plugin ecosystem
- **Alacritty** terminal emulator with GPU acceleration
- **tmux** session management with rich status bar
- Advanced shell history with **atuin**
- Smart directory navigation with **direnv** and **autoenv**

### ⚡ Development Tools
- **Neovim** with LazyVim distribution
- **Git** with powerful aliases and **delta** diff viewer
- **lazygit** for intuitive Git operations
- **lazydocker** for Docker management
- **fzf** fuzzy finder integration
- **ripgrep** for blazing-fast search

### 🔧 System Utilities
- **btop** system monitor
- **fd** file finder
- **thefuck** command correction
- **tmuxp** session templates
- **k9s** Kubernetes management

### 🎨 Theming & UI
- Consistent **Catppuccin Frappé** color scheme
- **SauceCodePro Nerd Font** with icon support
- Customized status bars and prompts
- Terminal transparency and modern aesthetics

## 🚀 Quick Start

### Prerequisites
- macOS or Linux
- Homebrew (will be installed automatically)
- Git

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/kevinnguyenhoang91/dotfiles.git "$HOME/dotfiles"
   cd "$HOME/dotfiles"
   ```

2. **Run the automated setup:**
   ```bash
   ./setup.sh
   ```
   This script will:
   - Install Homebrew (if not present)
   - Install all required packages from `Brewfile`
   - Set up Oh My Zsh with plugins
   - Install Nerd Fonts
   - Configure additional tools

3. **Deploy configurations:**
   ```bash
   make stow
   ```

4. **Complete the setup:**
   - Launch tmux and press `Ctrl-b + I` to install plugins
   - Open Neovim (`nvim`) for automatic plugin installation
   - Restart your terminal

### Manual Installation Options

**Install dependencies only:**
```bash
make setup
```

**Uninstall (remove symlinks):**
```bash
make unstow
```

## 📁 Repository Structure

```
dotfiles/
├── 🗂️  .github/           # GitHub templates & workflows
├── 📺  alacritty/          # Terminal emulator config
├── 🐚  bash/               # Bash configuration
├── 🔨  bazel/              # Bazel build tool config
├── 🍺  brew/               # Homebrew package definitions
├── 🏷️   ctags/             # Code indexing configuration
├── 🌟  extra/              # Additional utilities & scripts
├── 📝  git/                # Git configuration & aliases
├── 📊  gitmux/             # Git status for tmux
├── 🎮  k9s/                # Kubernetes management UI
├── 🦥  lazygit/            # Git terminal UI configuration
├── 🔐  netrc/              # Network authentication
├── 💻  nvim/               # Neovim configuration
├── ⚡  p10k/               # Powerlevel10k theme
├── 🔍  ripgrep/            # Search tool configuration
├── 💎  ruby/               # Ruby/Gem configuration
├── 🔍  shellcheck/         # Shell script linting
├── 🔑  ssh/                # SSH configuration
├── 📊  tig/                # Git repository browser
├── 🖥️   tmux/               # Terminal multiplexer
├── 📑  tmuxp/              # tmux session templates
├── 💼  vscode/             # VS Code profile
└── 🐚  zsh/                # Zsh shell configuration
```

## ⚙️ Detailed Configuration

### 🐚 Zsh Configuration
**Location:** `zsh/.zshrc`

**Key Features:**
- 35+ plugins for enhanced functionality
- Custom aliases and functions
- Advanced history management
- Smart completion system
- Integration with modern tools (fzf, atuin, direnv)

**Essential Aliases:**
```bash
v='$EDITOR'           # Quick editor access
lg='lazygit'          # Git UI
lzd='lazydocker'      # Docker UI
nv='nvim -c "lua require\"persistence\".load()"'  # Restore Neovim session
```

**Plugin Highlights:**
- `zsh-autosuggestions` - Fish-like command suggestions
- `zsh-syntax-highlighting` - Command syntax highlighting
- `fzf` - Fuzzy finding integration
- `vi-mode` - Vim keybindings in shell
- `thefuck` - Command correction

### 💻 Neovim Setup
**Location:** `nvim/`

**Distribution:** LazyVim with extensive customizations

**Language Support:**
- TypeScript/JavaScript (Angular, Vue)
- Python (Black formatting)
- Go, Rust, Kotlin, Java
- Docker, Kubernetes, Terraform
- Markdown, LaTeX, YAML, TOML

**Key Features:**
- GitHub Copilot integration
- Advanced debugging (DAP)
- Code refactoring tools
- Project management
- REST client
- Git integration (fugitive, octo)

**Notable Plugins:**
- `telescope` - Fuzzy finder
- `harpoon2` - Quick file navigation
- `mini-files` - File explorer
- `overseer` - Task runner
- `aerial` - Code outline

### 🖥️ tmux Configuration
**Location:** `tmux/.tmux.conf`

**Features:**
- Catppuccin Frappé theme
- Rich status bar with system information
- Vim-style navigation
- Plugin ecosystem (TPM)
- Session persistence
- Pane management

**Status Bar Components:**
- Session info with prefix indicator
- Current directory and command
- Git status (via gitmux)
- Pomodoro timer
- Battery status
- Network connectivity
- CPU/Memory usage
- Weather information
- Date/time

**Key Bindings:**
- `Ctrl-b + v` - Split pane horizontally
- `Ctrl-b + b` - Split pane vertically  
- `Ctrl-b + C-f` - Fuzzy pane finder
- `Alt + 1-9` - Quick window switching

### 📺 Alacritty Terminal
**Location:** `alacritty/alacritty.toml`

**Configuration:**
- Catppuccin Frappé color scheme
- SauceCodePro Nerd Font (14pt)
- GPU acceleration
- Vi-mode support
- Clipboard integration
- Window transparency

### 📝 Git Configuration
**Location:** `git/.gitconfig`

**Enhanced Workflow:**
- Delta diff viewer with syntax highlighting
- Useful aliases for common operations
- Neovim as merge/diff tool
- Auto-pruning and rebasing
- LFS support

**Useful Aliases:**
```bash
git l      # Compact log with graph
git ld     # Detailed log with dates
git tree   # Full repository tree view
git branches # Recent branches with info
```

### 🔍 Search & Navigation
**ripgrep** (`ripgrep/.rgrc`):
- Optimized search patterns
- Smart case sensitivity
- File type associations

**fzf Integration:**
- Command history search
- File finding
- Git integration
- tmux session switching

## 🛠️ Package Management

### Homebrew Packages
**Location:** `brew/Brewfile`

**Core Tools:**
- `atuin` - Enhanced shell history
- `btop` - System resource monitor  
- `direnv` - Directory-based environments
- `fd` - Fast file finder
- `fzf` - Fuzzy finder
- `lazydocker` - Docker management UI
- `lazygit` - Git terminal UI
- `node` - JavaScript runtime
- `ripgrep` - Fast text search
- `thefuck` - Command correction
- `tmuxp` - tmux session manager

### Runtime Management
- **asdf** - Multiple runtime version manager
- **nvm** - Node.js version management
- **cargo** - Rust package manager

## 🔧 Customization

### Environment Variables
Create `~/.secrets.zsh` for private configurations:
```bash
export GITHUB_TOKEN="your_token_here"
export OPENAI_API_KEY="your_key_here"
# Additional private vars...
```

### Local Git Configuration
Create `~/.gitconfig.local` for user-specific settings:
```ini
[user]
    name = Your Name
    email = your.email@example.com
[github]
    user = yourusername
```

### Platform-Specific Settings
Use `~/.zplatform` for OS-specific configurations:
```bash
# macOS specific
if [[ "$OSTYPE" == "darwin"* ]]; then
    export BROWSER="open"
fi

# Linux specific  
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    export BROWSER="xdg-open"
fi
```

## 🎯 Workflow Integration

### Development Workflow
1. **Session Management:** Use tmuxp templates for project-specific setups
2. **Code Navigation:** Harpoon2 for quick file switching in Neovim
3. **Git Operations:** lazygit for visual Git operations
4. **Container Management:** lazydocker for Docker workflows
5. **Kubernetes:** k9s for cluster management

### Productivity Features
- **Pomodoro Timer:** Built into tmux status bar
- **History Search:** atuin for enhanced command history
- **Quick Navigation:** z.lua for smart directory jumping
- **Command Correction:** thefuck for typo fixing
- **Fuzzy Everything:** fzf integration throughout the system

## 🔄 Updates & Maintenance

### Updating Packages
```bash
# Update Homebrew packages
brew update && brew upgrade

# Update Oh My Zsh
omz update

# Update tmux plugins  
# In tmux: Ctrl-b + U

# Update Neovim plugins
# In nvim: :Lazy update
```

### Backup Existing Configuration
Before installation, backup your current configs:
```bash
mkdir ~/dotfiles-backup
cp ~/.zshrc ~/dotfiles-backup/
cp ~/.gitconfig ~/dotfiles-backup/
cp -r ~/.config/nvim ~/dotfiles-backup/
cp -r ~/.config/alacritty ~/dotfiles-backup/
```

## 🐛 Troubleshooting

### Common Issues

**Permission denied for setup.sh:**
```bash
chmod +x setup.sh
```

**tmux plugins not installing:**
```bash
# In tmux session
Ctrl-b + I
# Or manually:
~/.tmux/plugins/tpm/bin/install_plugins
```

**Fonts not displaying correctly:**
```bash
# Reinstall Nerd Fonts
getnf -i 'Noto,FiraMono,FiraCode,Meslo'
```

**Neovim plugins not loading:**
```bash
# Clear plugin cache
rm -rf ~/.local/share/nvim
# Restart Neovim
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📚 References & Inspiration

- [huyvohcmc's dotfiles](https://github.com/huyvohcmc/dotfiles) - Primary inspiration
- [Catppuccin Theme](https://github.com/catppuccin/catppuccin) - Color scheme
- [LazyVim](https://github.com/LazyVim/LazyVim) - Neovim distribution
- [Oh My Zsh](https://github.com/ohmyzsh/ohmyzsh) - Zsh framework

## 📄 License

This project is licensed under the [MIT License](LICENSE). Feel free to use, modify, and distribute as needed.

---

**Happy coding! 🚀**
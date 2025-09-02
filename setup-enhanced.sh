#!/bin/bash
# setup-enhanced.sh - Enhanced setup script with modular architecture
# This is the new enhanced version of setup.sh with improved error handling,
# logging, and modular design

set -euo pipefail

# Script metadata
readonly SCRIPT_VERSION="2.0.0"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_ROOT="$SCRIPT_DIR"

# Source the setup library
# shellcheck source=lib/setup-lib.sh
source "${SCRIPT_DIR}/lib/setup-lib.sh"

# Setup operation definitions
declare -A SETUP_OPERATIONS=(
    ["homebrew"]="Install Homebrew package manager"
    ["homebrew_packages"]="Install Homebrew packages from Brewfile"
    ["oh_my_zsh"]="Install Oh My Zsh framework"
    ["zsh_plugins"]="Install Zsh plugins"
    ["zsh_theme"]="Configure Zsh theme"
    ["powerlevel10k"]="Install Powerlevel10k theme"
    ["nerd_fonts"]="Install Nerd Fonts"
    ["atuin"]="Configure atuin shell history"
    ["superfile"]="Install superfile terminal file manager"
)

# Installation Functions
#######################################

#######################################
# Install Homebrew package manager
# Returns:
#   0 on success, 1 on failure
#######################################
install_homebrew() {
    local operation="homebrew"
    
    if is_operation_completed "$operation"; then
        log_info "Homebrew already installed, skipping"
        return 0
    fi
    
    log_info "Installing Homebrew package manager..."
    
    if command -v brew >/dev/null 2>&1; then
        log_info "Homebrew already available"
        mark_operation_completed "$operation"
        return 0
    fi
    
    # Install Homebrew
    if ! /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
        handle_error "E007" "Failed to install Homebrew"
        return 1
    fi
    
    # Setup Homebrew environment for Linux
    if [[ -f /home/linuxbrew/.linuxbrew/bin/brew ]]; then
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    fi
    
    # Setup Homebrew environment for macOS
    if [[ -f /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
    
    # Verify installation
    if ! command -v brew >/dev/null 2>&1; then
        handle_error "E007" "Homebrew installation verification failed"
        return 1
    fi
    
    mark_operation_completed "$operation"
    log_info "Homebrew installed successfully"
    return 0
}

#######################################
# Install Homebrew packages from Brewfile
# Returns:
#   0 on success, 1 on failure
#######################################
install_homebrew_packages() {
    local operation="homebrew_packages"
    
    if is_operation_completed "$operation"; then
        log_info "Homebrew packages already installed, skipping"
        return 0
    fi
    
    log_info "Installing Homebrew packages from Brewfile..."
    
    # Ensure Homebrew is available
    if ! command -v brew >/dev/null 2>&1; then
        handle_error "E002" "Homebrew not found, cannot install packages"
        return 1
    fi
    
    # Check if Brewfile exists
    if [[ ! -f "$PROJECT_ROOT/brew/Brewfile" ]]; then
        handle_error "E004" "Brewfile not found at brew/Brewfile"
        return 1
    fi
    
    # Change to brew directory and run bundle
    if ! (cd "$PROJECT_ROOT/brew" && brew bundle); then
        handle_error "E007" "Failed to install Homebrew packages"
        return 1
    fi
    
    mark_operation_completed "$operation"
    log_info "Homebrew packages installed successfully"
    return 0
}

#######################################
# Install Oh My Zsh framework
# Returns:
#   0 on success, 1 on failure
#######################################
install_oh_my_zsh() {
    local operation="oh_my_zsh"
    
    if is_operation_completed "$operation"; then
        log_info "Oh My Zsh already installed, skipping"
        return 0
    fi
    
    log_info "Installing Oh My Zsh framework..."
    
    # Check if already installed
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        log_info "Oh My Zsh already exists"
        mark_operation_completed "$operation"
        return 0
    fi
    
    # Install Oh My Zsh
    if ! sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended; then
        handle_error "E007" "Failed to install Oh My Zsh"
        return 1
    fi
    
    mark_operation_completed "$operation"
    log_info "Oh My Zsh installed successfully"
    return 0
}

#######################################
# Install Zsh plugins
# Returns:
#   0 on success, 1 on failure
#######################################
install_zsh_plugins() {
    local operation="zsh_plugins"
    
    if is_operation_completed "$operation"; then
        log_info "Zsh plugins already installed, skipping"
        return 0
    fi
    
    log_info "Installing Zsh plugins..."
    
    local custom_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
    
    # Install zsh-autosuggestions
    local autosuggestions_dir="$custom_dir/plugins/zsh-autosuggestions"
    if [[ ! -d "$autosuggestions_dir" ]]; then
        if ! git clone https://github.com/zsh-users/zsh-autosuggestions "$autosuggestions_dir"; then
            handle_error "E007" "Failed to install zsh-autosuggestions"
            return 1
        fi
    fi
    
    # Install zsh-syntax-highlighting
    local syntax_highlighting_dir="$custom_dir/plugins/zsh-syntax-highlighting"
    if [[ ! -d "$syntax_highlighting_dir" ]]; then
        if ! git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$syntax_highlighting_dir"; then
            handle_error "E007" "Failed to install zsh-syntax-highlighting"
            return 1
        fi
    fi
    
    mark_operation_completed "$operation"
    log_info "Zsh plugins installed successfully"
    return 0
}

#######################################
# Configure Zsh theme (Catppuccin)
# Returns:
#   0 on success, 1 on failure
#######################################
install_zsh_theme() {
    local operation="zsh_theme"
    
    if is_operation_completed "$operation"; then
        log_info "Zsh theme already configured, skipping"
        return 0
    fi
    
    log_info "Configuring Zsh theme (Catppuccin)..."
    
    # Create .zsh directory
    mkdir -p "$HOME/.zsh"
    
    # Install Catppuccin theme for zsh-syntax-highlighting
    local temp_dir
    temp_dir=$(mktemp -d)
    
    if ! git clone https://github.com/catppuccin/zsh-syntax-highlighting.git "$temp_dir"; then
        handle_error "E007" "Failed to clone Catppuccin theme"
        return 1
    fi
    
    # Copy theme file
    if ! cp -f "$temp_dir/themes/catppuccin_mocha-zsh-syntax-highlighting.zsh" "$HOME/.zsh/"; then
        handle_error "E004" "Failed to copy Catppuccin theme"
        return 1
    fi
    
    # Cleanup
    rm -rf "$temp_dir"
    
    mark_operation_completed "$operation"
    log_info "Zsh theme configured successfully"
    return 0
}

#######################################
# Install Powerlevel10k theme
# Returns:
#   0 on success, 1 on failure
#######################################
install_powerlevel10k() {
    local operation="powerlevel10k"
    
    if is_operation_completed "$operation"; then
        log_info "Powerlevel10k already installed, skipping"
        return 0
    fi
    
    log_info "Installing Powerlevel10k theme..."
    
    local custom_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
    local p10k_dir="$custom_dir/themes/powerlevel10k"
    
    if [[ -d "$p10k_dir" ]]; then
        log_info "Powerlevel10k already exists"
        mark_operation_completed "$operation"
        return 0
    fi
    
    if ! git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$p10k_dir"; then
        handle_error "E007" "Failed to install Powerlevel10k"
        return 1
    fi
    
    mark_operation_completed "$operation"
    log_info "Powerlevel10k installed successfully"
    return 0
}

#######################################
# Install Nerd Fonts
# Returns:
#   0 on success, 1 on failure
#######################################
install_nerd_fonts() {
    local operation="nerd_fonts"
    
    if is_operation_completed "$operation"; then
        log_info "Nerd Fonts already installed, skipping"
        return 0
    fi
    
    log_info "Installing Nerd Fonts..."
    
    # Create fonts directory
    mkdir -p "$HOME/.local/share/fonts"
    
    # Install getnf if not available
    if ! command -v getnf >/dev/null 2>&1; then
        if ! curl -fsSL https://raw.githubusercontent.com/getnf/getnf/main/install.sh | bash; then
            handle_error "E007" "Failed to install getnf"
            return 1
        fi
    fi
    
    # Install specific Nerd Fonts
    if ! getnf -i 'Noto,FiraMono,FiraCode,Meslo'; then
        handle_error "E007" "Failed to install Nerd Fonts"
        return 1
    fi
    
    mark_operation_completed "$operation"
    log_info "Nerd Fonts installed successfully"
    return 0
}

#######################################
# Configure atuin shell history
# Returns:
#   0 on success, 1 on failure
#######################################
install_atuin() {
    local operation="atuin"
    
    if is_operation_completed "$operation"; then
        log_info "Atuin already configured, skipping"
        return 0
    fi
    
    log_info "Configuring atuin shell history..."
    
    if command -v atuin >/dev/null 2>&1; then
        # Initialize atuin for zsh
        if ! eval "$(atuin init zsh)"; then
            log_warn "Failed to initialize atuin, but continuing..."
        fi
    else
        log_warn "Atuin not found, skipping configuration"
    fi
    
    mark_operation_completed "$operation"
    log_info "Atuin configured successfully"
    return 0
}

#######################################
# Install superfile terminal file manager
# Returns:
#   0 on success, 1 on failure
#######################################
install_superfile() {
    local operation="superfile"
    
    if is_operation_completed "$operation"; then
        log_info "Superfile already installed, skipping"
        return 0
    fi
    
    log_info "Installing superfile terminal file manager..."
    
    if ! bash -c "$(curl -sLo- https://superfile.netlify.app/install.sh)"; then
        handle_error "E007" "Failed to install superfile"
        return 1
    fi
    
    mark_operation_completed "$operation"
    log_info "Superfile installed successfully"
    return 0
}

# Main Setup Functions
#######################################

#######################################
# Display setup summary
#######################################
show_setup_summary() {
    echo "🚀 Enhanced Dotfiles Setup Script (v$SCRIPT_VERSION)"
    echo "=================================================="
    echo ""
    echo "This script will install and configure:"
    echo ""
    
    local step=1
    for operation in "${!SETUP_OPERATIONS[@]}"; do
        local description="${SETUP_OPERATIONS[$operation]}"
        local status="⏳ Pending"
        
        if is_operation_completed "$operation"; then
            status="✅ Completed"
        fi
        
        printf "%2d. %-30s %s\n" "$step" "$description" "$status"
        ((step++))
    done
    
    echo ""
    echo "System Information:"
    echo "  OS: $(detect_os)"
    echo "  Package Manager: $(detect_package_manager)"
    echo "  Project Directory: $PROJECT_ROOT"
    echo "  Log File: $LOG_FILE"
    echo ""
}

#######################################
# Run all setup operations
# Returns:
#   0 on success, 1 on failure
#######################################
run_setup() {
    log_info "Starting enhanced dotfiles setup..."
    
    # Validate prerequisites
    if ! validate_prerequisites; then
        exit_with_error "E001" "System prerequisites not met"
    fi
    
    # List of operations in order
    local -a operations=(
        "homebrew"
        "homebrew_packages"
        "oh_my_zsh"
        "zsh_plugins"
        "zsh_theme"
        "powerlevel10k"
        "nerd_fonts"
        "atuin"
        "superfile"
    )
    
    local total_operations=${#operations[@]}
    local current_step=1
    local failed_operations=()
    
    # Execute each operation
    for operation in "${operations[@]}"; do
        local description="${SETUP_OPERATIONS[$operation]}"
        
        update_progress "$current_step" "$total_operations" "$description"
        
        case "$operation" in
            "homebrew")
                install_homebrew || failed_operations+=("$operation")
                ;;
            "homebrew_packages")
                install_homebrew_packages || failed_operations+=("$operation")
                ;;
            "oh_my_zsh")
                install_oh_my_zsh || failed_operations+=("$operation")
                ;;
            "zsh_plugins")
                install_zsh_plugins || failed_operations+=("$operation")
                ;;
            "zsh_theme")
                install_zsh_theme || failed_operations+=("$operation")
                ;;
            "powerlevel10k")
                install_powerlevel10k || failed_operations+=("$operation")
                ;;
            "nerd_fonts")
                install_nerd_fonts || failed_operations+=("$operation")
                ;;
            "atuin")
                install_atuin || failed_operations+=("$operation")
                ;;
            "superfile")
                install_superfile || failed_operations+=("$operation")
                ;;
        esac
        
        ((current_step++))
    done
    
    echo ""
    echo "=================================================="
    
    # Report results
    if [[ ${#failed_operations[@]} -eq 0 ]]; then
        echo "🎉 Setup completed successfully!"
        echo ""
        echo "Next steps:"
        echo "  1. Run 'make stow' to deploy configurations"
        echo "  2. Restart your terminal"
        echo "  3. Launch tmux and press Ctrl-b + I to install plugins"
        echo "  4. Open Neovim for automatic plugin installation"
        echo ""
        log_info "Setup completed successfully"
        return 0
    else
        echo "⚠️  Setup completed with errors:"
        for operation in "${failed_operations[@]}"; do
            echo "  ❌ ${SETUP_OPERATIONS[$operation]}"
        done
        echo ""
        echo "Check the log file for details: $LOG_FILE"
        log_error "Setup completed with ${#failed_operations[@]} failures"
        return 1
    fi
}

#######################################
# Show usage information
#######################################
show_usage() {
    cat << EOF
Enhanced Dotfiles Setup Script (v$SCRIPT_VERSION)

Usage: $0 [OPTIONS]

Options:
  --help, -h          Show this help message
  --summary, -s       Show setup summary without executing
  --reset             Reset all operation states and run fresh setup
  --log-level LEVEL   Set log level (DEBUG, INFO, WARN, ERROR)
  --log-file FILE     Set log file path
  --version, -v       Show version information

Examples:
  $0                  Run full setup
  $0 --summary        Show what would be installed
  $0 --reset          Reset and run fresh setup
  $0 --log-level DEBUG --log-file setup-debug.log

EOF
}

#######################################
# Main function
#######################################
main() {
    local show_summary_only=false
    local reset_state=false
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --help|-h)
                show_usage
                exit 0
                ;;
            --summary|-s)
                show_summary_only=true
                shift
                ;;
            --reset)
                reset_state=true
                shift
                ;;
            --log-level)
                set_log_level "$2"
                shift 2
                ;;
            --log-file)
                LOG_FILE="$2"
                shift 2
                ;;
            --version|-v)
                echo "Enhanced Dotfiles Setup Script v$SCRIPT_VERSION"
                exit 0
                ;;
            *)
                echo "Unknown option: $1" >&2
                show_usage >&2
                exit 1
                ;;
        esac
    done
    
    # Reset state if requested
    if [[ "$reset_state" == "true" ]]; then
        log_info "Resetting all operation states..."
        for operation in "${!SETUP_OPERATIONS[@]}"; do
            reset_operation_state "$operation"
        done
    fi
    
    # Show summary
    show_setup_summary
    
    # Exit if only showing summary
    if [[ "$show_summary_only" == "true" ]]; then
        exit 0
    fi
    
    # Ask for confirmation
    echo "Do you want to proceed with the setup? (y/N)"
    read -r response
    case "$response" in
        [yY]|[yY][eE][sS])
            echo ""
            run_setup
            ;;
        *)
            echo "Setup cancelled."
            exit 0
            ;;
    esac
}

# Only run main if script is executed directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
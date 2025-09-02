#!/bin/bash
# setup-lib.sh - Core library for enhanced setup script architecture
# Provides modular functions for system detection, logging, error handling, and configuration

set -euo pipefail

# Library metadata
readonly SETUP_LIB_VERSION="1.0.0"

# Set SCRIPT_DIR only if not already set
if [[ -z "${SCRIPT_DIR:-}" ]]; then
    readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi

# Set PROJECT_ROOT only if not already set
if [[ -z "${PROJECT_ROOT:-}" ]]; then
    readonly PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
fi

# Global configuration
readonly CONFIG_DIR="${PROJECT_ROOT}/config"
readonly LOG_DIR="${PROJECT_ROOT}/logs"
readonly CACHE_DIR="${PROJECT_ROOT}/.cache"
readonly STATE_FILE="${CACHE_DIR}/setup_state.conf"

# Default log level (DEBUG, INFO, WARN, ERROR)
LOG_LEVEL="${LOG_LEVEL:-INFO}"
LOG_FILE="${LOG_FILE:-${LOG_DIR}/setup.log}"

# Error codes
declare -A ERROR_CODES=(
    ["E001"]="System requirements not met"
    ["E002"]="Package manager not found"
    ["E003"]="Network connection failed"
    ["E004"]="File operation failed"
    ["E005"]="Configuration error"
    ["E006"]="Permission denied"
    ["E007"]="Tool installation failed"
    ["E008"]="Dependency conflict detected"
)

# System Detection Functions
#######################################

#######################################
# Detect the operating system
# Returns:
#   macos, linux, or unknown
#######################################
detect_os() {
    case "$(uname -s)" in
        Darwin)
            echo "macos"
            ;;
        Linux)
            echo "linux"
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

#######################################
# Detect the package manager
# Returns:
#   homebrew, apt, yum, pacman, or unknown
#######################################
detect_package_manager() {
    if command -v brew >/dev/null 2>&1; then
        echo "homebrew"
    elif command -v apt >/dev/null 2>&1; then
        echo "apt"
    elif command -v yum >/dev/null 2>&1; then
        echo "yum"
    elif command -v pacman >/dev/null 2>&1; then
        echo "pacman"
    else
        echo "unknown"
    fi
}

#######################################
# Detect existing tools and their versions
# Returns:
#   Space-separated list of installed tools
#######################################
detect_existing_tools() {
    local -a tools=("git" "stow" "brew" "zsh" "tmux" "nvim" "alacritty")
    local installed_tools=()
    
    for tool in "${tools[@]}"; do
        if command -v "$tool" >/dev/null 2>&1; then
            local version=""
            case "$tool" in
                git)
                    version=$(git --version 2>/dev/null | cut -d' ' -f3 || echo "unknown")
                    ;;
                brew)
                    version=$(brew --version 2>/dev/null | head -n1 | cut -d' ' -f2 || echo "unknown")
                    ;;
                *)
                    version=$($tool --version 2>/dev/null | head -n1 | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -n1 || echo "unknown")
                    ;;
            esac
            installed_tools+=("${tool}:${version}")
        fi
    done
    
    printf '%s\n' "${installed_tools[@]}"
}

# Logging Framework Functions
#######################################

#######################################
# Set the global log level and log file
# Arguments:
#   $1 - Log level (DEBUG, INFO, WARN, ERROR)
#   $2 - Log file path (optional)
# Returns:
#   0 on success, 1 on failure
#######################################
set_log_level() {
    local level="$1"
    local log_file="${2:-$LOG_FILE}"
    
    case "$level" in
        DEBUG|INFO|WARN|ERROR)
            LOG_LEVEL="$level"
            LOG_FILE="$log_file"
            
            # Ensure log directory exists
            mkdir -p "$(dirname "$LOG_FILE")"
            return 0
            ;;
        *)
            echo "ERROR: Invalid log level: $level" >&2
            return 1
            ;;
    esac
}

#######################################
# Check if log level should be displayed
# Arguments:
#   $1 - Message log level
# Returns:
#   0 if should log, 1 if should skip
#######################################
_should_log() {
    local msg_level="$1"
    local -A levels=([DEBUG]=0 [INFO]=1 [WARN]=2 [ERROR]=3)
    
    local current_level_num=${levels[$LOG_LEVEL]:-1}
    local msg_level_num=${levels[$msg_level]:-1}
    
    [[ $msg_level_num -ge $current_level_num ]]
}

#######################################
# Log an info message
# Arguments:
#   $* - Message to log
#######################################
log_info() {
    if _should_log "INFO"; then
        local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
        echo "[INFO] $*"
        echo "[$timestamp] [INFO] $*" >> "$LOG_FILE"
    fi
}

#######################################
# Log a warning message
# Arguments:
#   $* - Message to log
#######################################
log_warn() {
    if _should_log "WARN"; then
        local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
        echo "[WARN] $*" >&2
        echo "[$timestamp] [WARN] $*" >> "$LOG_FILE"
    fi
}

#######################################
# Log an error message
# Arguments:
#   $* - Message to log
#######################################
log_error() {
    if _should_log "ERROR"; then
        local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
        echo "[ERROR] $*" >&2
        echo "[$timestamp] [ERROR] $*" >> "$LOG_FILE"
    fi
}

#######################################
# Log a debug message
# Arguments:
#   $* - Message to log
#######################################
log_debug() {
    if _should_log "DEBUG"; then
        local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
        echo "[DEBUG] $*" >&2
        echo "[$timestamp] [DEBUG] $*" >> "$LOG_FILE"
    fi
}

# Error Handling Functions
#######################################

#######################################
# Get error message for error code
# Arguments:
#   $1 - Error code
# Returns:
#   Error message or empty string
#######################################
get_error_message() {
    local error_code="$1"
    echo "${ERROR_CODES[$error_code]:-Unknown error}"
}

#######################################
# Handle error with proper logging and cleanup
# Arguments:
#   $1 - Error code
#   $2 - Additional context (optional)
# Returns:
#   Always returns 1 (error)
#######################################
handle_error() {
    local error_code="$1"
    local context="${2:-}"
    local error_msg
    
    error_msg=$(get_error_message "$error_code")
    
    if [[ -n "$context" ]]; then
        log_error "$error_code: $error_msg - $context"
    else
        log_error "$error_code: $error_msg"
    fi
    
    # Trigger cleanup handlers
    _execute_cleanup_handlers
    
    return 1
}

#######################################
# Exit with error code and message
# Arguments:
#   $1 - Error code
#   $2 - Additional context (optional)
# Exits:
#   Always exits with status 1
#######################################
exit_with_error() {
    handle_error "$@"
    exit 1
}

#######################################
# Validate system prerequisites
# Returns:
#   0 if valid, 1 if invalid
#######################################
validate_prerequisites() {
    local errors=0
    
    # Check if we're in the right directory
    if [[ ! -f "$PROJECT_ROOT/setup.sh" ]]; then
        handle_error "E004" "Not in dotfiles directory"
        ((errors++))
    fi
    
    # Check network connectivity
    if ! curl -s --head --request GET https://github.com >/dev/null 2>&1; then
        handle_error "E003" "No internet connection available"
        ((errors++))
    fi
    
    # Check write permissions
    if [[ ! -w "$HOME" ]]; then
        handle_error "E006" "No write permission to home directory"
        ((errors++))
    fi
    
    return $errors
}

# Configuration Management Functions
#######################################

#######################################
# Load configuration from file
# Arguments:
#   $1 - Configuration file path
# Returns:
#   0 on success, 1 on failure
#######################################
load_config() {
    local config_file="$1"
    
    if [[ ! -f "$config_file" ]]; then
        log_warn "Configuration file not found: $config_file"
        return 1
    fi
    
    if [[ ! -r "$config_file" ]]; then
        handle_error "E006" "Cannot read configuration file: $config_file"
        return 1
    fi
    
    # shellcheck source=/dev/null
    source "$config_file"
    log_debug "Loaded configuration from: $config_file"
    
    return 0
}

#######################################
# Save configuration value
# Arguments:
#   $1 - Key
#   $2 - Value
#   $3 - Configuration file (optional, defaults to state file)
# Returns:
#   0 on success, 1 on failure
#######################################
save_config() {
    local key="$1"
    local value="$2"
    local config_file="${3:-$STATE_FILE}"
    
    # Ensure directory exists
    mkdir -p "$(dirname "$config_file")"
    
    # Remove existing key and append new value
    if [[ -f "$config_file" ]]; then
        grep -v "^${key}=" "$config_file" > "${config_file}.tmp" || true
        mv "${config_file}.tmp" "$config_file"
    fi
    
    echo "${key}=${value}" >> "$config_file"
    log_debug "Saved config: $key=$value to $config_file"
    
    return 0
}

#######################################
# Get configuration value
# Arguments:
#   $1 - Key
#   $2 - Default value (optional)
#   $3 - Configuration file (optional, defaults to state file)
# Returns:
#   Configuration value or default
#######################################
get_config_value() {
    local key="$1"
    local default="${2:-}"
    local config_file="${3:-$STATE_FILE}"
    
    if [[ -f "$config_file" ]]; then
        local value
        value=$(grep "^${key}=" "$config_file" 2>/dev/null | cut -d'=' -f2- || echo "$default")
        echo "$value"
    else
        echo "$default"
    fi
}

# Idempotent Operation Functions
#######################################

#######################################
# Check if operation has been completed
# Arguments:
#   $1 - Operation name
# Returns:
#   0 if completed, 1 if not completed
#######################################
is_operation_completed() {
    local operation="$1"
    local completed
    
    completed=$(get_config_value "COMPLETED_${operation}" "false")
    [[ "$completed" == "true" ]]
}

#######################################
# Mark operation as completed
# Arguments:
#   $1 - Operation name
# Returns:
#   0 on success
#######################################
mark_operation_completed() {
    local operation="$1"
    
    save_config "COMPLETED_${operation}" "true"
    log_debug "Marked operation as completed: $operation"
}

#######################################
# Reset operation state
# Arguments:
#   $1 - Operation name
# Returns:
#   0 on success
#######################################
reset_operation_state() {
    local operation="$1"
    
    save_config "COMPLETED_${operation}" "false"
    log_debug "Reset operation state: $operation"
}

# Progress Tracking Functions
#######################################

#######################################
# Show progress indicator
# Arguments:
#   $1 - Current step
#   $2 - Total steps
#   $3 - Operation description
#######################################
show_progress() {
    local current="$1"
    local total="$2"
    local operation="$3"
    
    local percentage=$((current * 100 / total))
    printf "\r[%d/%d] %s... (%d%%)" "$current" "$total" "$operation" "$percentage"
    
    if [[ $current -eq $total ]]; then
        echo " ✅ Done!"
    fi
}

#######################################
# Update progress and log
# Arguments:
#   $1 - Current step
#   $2 - Total steps
#   $3 - Operation description
#######################################
update_progress() {
    local current="$1"
    local total="$2"
    local operation="$3"
    
    show_progress "$current" "$total" "$operation"
    log_info "Progress: [$current/$total] $operation"
}

# Cleanup Management
#######################################

# Array to store cleanup handlers
declare -a CLEANUP_HANDLERS=()

#######################################
# Register a cleanup handler function
# Arguments:
#   $1 - Function name to call on cleanup
#######################################
register_cleanup_handler() {
    local handler="$1"
    CLEANUP_HANDLERS+=("$handler")
    log_debug "Registered cleanup handler: $handler"
}

#######################################
# Execute all registered cleanup handlers
#######################################
_execute_cleanup_handlers() {
    log_debug "Executing cleanup handlers..."
    
    for handler in "${CLEANUP_HANDLERS[@]}"; do
        if declare -F "$handler" >/dev/null; then
            log_debug "Running cleanup handler: $handler"
            $handler || log_warn "Cleanup handler failed: $handler"
        else
            log_warn "Cleanup handler not found: $handler"
        fi
    done
}

#######################################
# Default cleanup function for temporary files
#######################################
cleanup_temp_files() {
    if [[ -n "${TEMP_DIR:-}" && -d "$TEMP_DIR" ]]; then
        log_debug "Cleaning up temporary directory: $TEMP_DIR"
        rm -rf "$TEMP_DIR" || log_warn "Failed to cleanup temp directory: $TEMP_DIR"
    fi
    
    # Clean up any temporary files in the project
    find "$PROJECT_ROOT" -name "*.tmp" -type f -delete 2>/dev/null || true
}

# Interactive Configuration System
#######################################

#######################################
# Display the main interactive menu
# Outputs:
#   Formatted menu with options
#######################################
show_main_menu() {
    echo ""
    echo "┌─────────────────────────────────────────────┐"
    echo "│              Main Setup Menu               │"
    echo "├─────────────────────────────────────────────┤"
    echo "│                                             │"
    echo "│  1) Full Installation (Recommended)        │"
    echo "│  2) Custom Component Selection             │"
    echo "│  3) Minimal Installation                   │"
    echo "│  4) Resume Previous Installation           │"
    echo "│  5) View Current Configuration             │"
    echo "│                                             │"
    echo "│  h) Help & Documentation                   │"
    echo "│  q) Quit                                   │"
    echo "│                                             │"
    echo "└─────────────────────────────────────────────┘"
    echo ""
}

#######################################
# Display the component selection menu
# Outputs:
#   Formatted component selection interface
#######################################
show_component_selection_menu() {
    echo ""
    echo "┌─────────────────────────────────────────────┐"
    echo "│           Component Selection              │"
    echo "├─────────────────────────────────────────────┤"
    echo "│                                             │"
    echo "│  Shell & Terminal:                         │"
    echo "│    • Zsh with Oh My Zsh                    │"
    echo "│    • Powerlevel10k theme                   │"
    echo "│    • Alacritty terminal                    │"
    echo "│    • tmux with custom config               │"
    echo "│                                             │"
    echo "│  Development Tools:                        │"
    echo "│    • Neovim with LazyVim                   │"
    echo "│    • Homebrew package manager              │"
    echo "│    • Node.js & development tools           │"
    echo "│    • Python & pip packages                │"
    echo "│                                             │"
    echo "│  Git & Version Control:                    │"
    echo "│    • Git configuration                     │"
    echo "│    • GitHub CLI                           │"
    echo "│    • Lazygit terminal UI                   │"
    echo "│                                             │"
    echo "│  Optional Components:                      │"
    echo "│    • Docker & container tools              │"
    echo "│    • Kubernetes tools                      │"
    echo "│    • Additional CLI utilities              │"
    echo "│                                             │"
    echo "└─────────────────────────────────────────────┘"
    echo ""
}

#######################################
# Validate menu choice input
# Arguments:
#   $1 - User input choice
# Returns:
#   0 for valid choice, 1 for invalid
#######################################
validate_menu_choice() {
    local choice="$1"
    
    case "$choice" in
        [1-5]|h|H|q|Q) return 0 ;;
        *) return 1 ;;
    esac
}

#######################################
# Get user menu choice with validation
# Returns:
#   Valid menu choice via stdout
#######################################
get_menu_choice() {
    local choice
    local prompt="Enter your choice: "
    
    while true; do
        read -p "$prompt" -r choice
        
        if validate_menu_choice "$choice"; then
            echo "$choice"
            return 0
        else
            echo "❌ Invalid choice. Please select 1-5, h (help), or q (quit)."
            echo ""
        fi
    done
}

#######################################
# Handle main menu selection
# Arguments:
#   $1 - Menu choice
# Returns:
#   0 on success, 1 on quit, 2 on error
#######################################
handle_menu_selection() {
    local choice="$1"
    
    case "$choice" in
        1)
            log_info "Selected: Full Installation"
            start_full_installation
            ;;
        2)
            log_info "Selected: Custom Component Selection"
            start_custom_installation
            ;;
        3)
            log_info "Selected: Minimal Installation"
            start_minimal_installation
            ;;
        4)
            log_info "Selected: Resume Previous Installation"
            resume_installation
            ;;
        5)
            log_info "Selected: View Current Configuration"
            show_current_configuration
            ;;
        h|H)
            show_help_documentation
            ;;
        q|Q)
            log_info "Setup cancelled by user"
            return 1
            ;;
        *)
            log_error "Invalid menu choice: $choice"
            return 2
            ;;
    esac
    
    return 0
}

#######################################
# Display interactive configuration menu
# Returns:
#   0 on successful selection, 1 on quit
#######################################
interactive_menu() {
    local choice
    
    log_info "Starting interactive configuration menu"
    
    while true; do
        clear
        echo "🚀 Enhanced Dotfiles Setup"
        echo "=========================="
        
        show_main_menu
        choice=$(get_menu_choice)
        
        if handle_menu_selection "$choice"; then
            # Successful operation, continue or exit based on choice
            case "$choice" in
                [1-5]) return 0 ;;  # Installation choices return success
                q|Q) return 1 ;;    # Quit returns 1
            esac
        elif [[ $? -eq 1 ]]; then
            # User quit
            return 1
        else
            # Error occurred, show message and continue menu
            echo ""
            echo "Press Enter to continue..."
            read -r
        fi
    done
}

# User Input Validation Functions
#######################################

#######################################
# Validate yes/no input
# Arguments:
#   $1 - User input
# Returns:
#   0 for yes, 1 for no, 2 for invalid
#######################################
validate_yes_no_input() {
    local input="$1"
    
    case "${input,,}" in  # Convert to lowercase
        y|yes) return 0 ;;
        n|no) return 1 ;;
        *) return 2 ;;
    esac
}

#######################################
# Get user confirmation with validation
# Arguments:
#   $1 - Prompt message (optional)
#   $2 - Default choice (y/n, optional)
# Returns:
#   0 for yes, 1 for no
#######################################
get_user_confirmation() {
    local prompt="${1:-Continue?}"
    local default="${2:-n}"
    local response
    local display_default
    
    # Format default display
    case "${default,,}" in
        y|yes) display_default="Y/n" ;;
        n|no) display_default="y/N" ;;
        *) display_default="y/n" ;;
    esac
    
    while true; do
        read -p "$prompt ($display_default): " -r response
        
        # Use default if empty
        if [[ -z "$response" ]]; then
            response="$default"
        fi
        
        validate_yes_no_input "$response"
        local result=$?
        
        case $result in
            0) return 0 ;;  # Yes
            1) return 1 ;;  # No
            2) echo "Please answer yes (y) or no (n)." ;;
        esac
    done
}

#######################################
# Validate configuration key format
# Arguments:
#   $1 - Configuration key
# Returns:
#   0 for valid, 1 for invalid
#######################################
validate_config_key() {
    local key="$1"
    
    # Key must be non-empty, alphanumeric with underscores, max 50 chars
    if [[ -n "$key" && "$key" =~ ^[a-zA-Z][a-zA-Z0-9_]{1,49}$ ]]; then
        return 0
    else
        return 1
    fi
}

#######################################
# Validate component category
# Arguments:
#   $1 - Component category
# Returns:
#   0 for valid, 1 for invalid
#######################################
validate_component_category() {
    local category="$1"
    
    case "$category" in
        shell|editor|git|development|all|minimal) return 0 ;;
        *) return 1 ;;
    esac
}

# Component Selection Functions
#######################################

#######################################
# Save component selection to file
# Arguments:
#   $1 - Config file path
#   $@ - Component names (remaining arguments)
# Returns:
#   0 on success, 1 on failure
#######################################
save_component_selection() {
    local config_file="$1"
    shift
    local components=("$@")
    
    if [[ ${#components[@]} -eq 0 ]]; then
        log_error "No components provided to save"
        return 1
    fi
    
    # Create directory if needed
    mkdir -p "$(dirname "$config_file")"
    
    # Save components, one per line
    printf '%s\n' "${components[@]}" > "$config_file" || {
        log_error "Failed to save component selection to: $config_file"
        return 1
    }
    
    log_debug "Saved ${#components[@]} components to: $config_file"
    return 0
}

#######################################
# Load component selection from file
# Arguments:
#   $1 - Config file path
# Outputs:
#   Component names, one per line
# Returns:
#   0 on success, 1 on failure
#######################################
load_component_selection() {
    local config_file="$1"
    
    if [[ ! -f "$config_file" ]]; then
        log_error "Component selection file not found: $config_file"
        return 1
    fi
    
    # Read components from file
    while IFS= read -r component; do
        if [[ -n "$component" ]]; then
            echo "$component"
        fi
    done < "$config_file"
    
    return 0
}

# Configuration Management Functions
#######################################

#######################################
# Load configuration defaults from file
# Arguments:
#   $1 - Defaults file path
# Returns:
#   0 on success, 1 on failure
#######################################
load_config_defaults() {
    local defaults_file="$1"
    
    if [[ ! -f "$defaults_file" ]]; then
        log_warn "Defaults file not found: $defaults_file"
        return 1
    fi
    
    # Source the defaults file to set environment variables
    while IFS='=' read -r key value; do
        # Skip empty lines and comments
        [[ -z "$key" || "$key" =~ ^[[:space:]]*# ]] && continue
        
        # Validate key format
        if validate_config_key "$key"; then
            # Export as CONFIG_ prefixed environment variable
            export "CONFIG_${key^^}"="$value"
            log_debug "Loaded config default: CONFIG_${key^^}=$value"
        else
            log_warn "Invalid config key format: $key"
        fi
    done < "$defaults_file"
    
    return 0
}

#######################################
# Save user preferences to associative array file
# Arguments:
#   $1 - Preferences file path
#   $2 - Associative array name (passed by reference)
# Returns:
#   0 on success, 1 on failure
#######################################
save_user_preferences() {
    local prefs_file="$1"
    local -n prefs_array=$2
    
    # Create directory if needed
    mkdir -p "$(dirname "$prefs_file")"
    
    # Save preferences in key=value format
    {
        echo "# User preferences saved on $(date -Iseconds)"
        for key in "${!prefs_array[@]}"; do
            echo "${key}=${prefs_array[$key]}"
        done
    } > "$prefs_file" || {
        log_error "Failed to save user preferences to: $prefs_file"
        return 1
    }
    
    log_debug "Saved ${#prefs_array[@]} preferences to: $prefs_file"
    return 0
}

#######################################
# Load user preferences into associative array
# Arguments:
#   $1 - Preferences file path
#   $2 - Associative array name (passed by reference)
# Returns:
#   0 on success, 1 on failure
#######################################
load_user_preferences() {
    local prefs_file="$1"
    local -n load_prefs_array=$2
    
    if [[ ! -f "$prefs_file" ]]; then
        log_warn "Preferences file not found: $prefs_file"
        return 1
    fi
    
    # Load preferences from file
    while IFS='=' read -r key value; do
        # Skip empty lines and comments
        [[ -z "$key" || "$key" =~ ^[[:space:]]*# ]] && continue
        
        # Store in associative array
        load_prefs_array["$key"]="$value"
        log_debug "Loaded preference: $key=$value"
    done < "$prefs_file"
    
    return 0
}

# Installation State Management
#######################################

#######################################
# Mark a component as completed
# Arguments:
#   $1 - Component name
# Returns:
#   0 on success, 1 on failure
#######################################
mark_component_completed() {
    local component="$1"
    local state_dir="${SETUP_STATE_DIR:-${CACHE_DIR}/state}"
    local state_file="${state_dir}/.${component}_completed"
    
    mkdir -p "$state_dir"
    
    if touch "$state_file"; then
        log_debug "Marked component completed: $component"
        return 0
    else
        log_error "Failed to mark component completed: $component"
        return 1
    fi
}

#######################################
# Check if a component is completed
# Arguments:
#   $1 - Component name
# Returns:
#   0 if completed, 1 if not completed
#######################################
is_component_completed() {
    local component="$1"
    local state_dir="${SETUP_STATE_DIR:-${CACHE_DIR}/state}"
    local state_file="${state_dir}/.${component}_completed"
    
    [[ -f "$state_file" ]]
}

#######################################
# Get list of incomplete components
# Arguments:
#   $1 - Array name containing all components (passed by reference)
# Outputs:
#   Incomplete component names, one per line
# Returns:
#   0 on success
#######################################
get_incomplete_components() {
    local -n all_components_array=$1
    
    for component in "${all_components_array[@]}"; do
        if ! is_component_completed "$component"; then
            echo "$component"
        fi
    done
    
    return 0
}

# Resume/Checkpoint Functions
#######################################

#######################################
# Save installation checkpoint
# Arguments:
#   $1 - Checkpoint file path
#   $2 - Associative array name with checkpoint data (passed by reference)
# Returns:
#   0 on success, 1 on failure
#######################################
save_installation_checkpoint() {
    local checkpoint_file="$1"
    local -n checkpoint_data=$2
    
    # Create directory if needed
    mkdir -p "$(dirname "$checkpoint_file")"
    
    # Save checkpoint data
    {
        echo "# Installation checkpoint saved on $(date -Iseconds)"
        for key in "${!checkpoint_data[@]}"; do
            echo "${key}=${checkpoint_data[$key]}"
        done
    } > "$checkpoint_file" || {
        log_error "Failed to save installation checkpoint to: $checkpoint_file"
        return 1
    }
    
    log_info "Installation checkpoint saved to: $checkpoint_file"
    return 0
}

#######################################
# Load installation checkpoint
# Arguments:
#   $1 - Checkpoint file path
#   $2 - Associative array name to load data into (passed by reference)
# Returns:
#   0 on success, 1 on failure
#######################################
load_installation_checkpoint() {
    local checkpoint_file="$1"
    local -n load_checkpoint_data=$2
    
    if [[ ! -f "$checkpoint_file" ]]; then
        log_error "Checkpoint file not found: $checkpoint_file"
        return 1
    fi
    
    # Load checkpoint data
    while IFS='=' read -r key value; do
        # Skip empty lines and comments
        [[ -z "$key" || "$key" =~ ^[[:space:]]*# ]] && continue
        
        # Store in associative array
        load_checkpoint_data["$key"]="$value"
        log_debug "Loaded checkpoint data: $key=$value"
    done < "$checkpoint_file"
    
    log_info "Installation checkpoint loaded from: $checkpoint_file"
    return 0
}

#######################################
# Check if installation can be resumed
# Arguments:
#   $1 - Checkpoint file path
# Returns:
#   0 if can resume, 1 if cannot
#######################################
can_resume_installation() {
    local checkpoint_file="$1"
    
    # File must exist and be readable
    if [[ ! -f "$checkpoint_file" || ! -r "$checkpoint_file" ]]; then
        return 1
    fi
    
    # File must contain required checkpoint data
    if grep -q "current_step=" "$checkpoint_file" && 
       grep -q "timestamp=" "$checkpoint_file"; then
        return 0
    else
        return 1
    fi
}

# Placeholder Installation Functions (to be implemented in subsequent tasks)
#######################################

start_full_installation() {
    log_info "Full installation mode selected"
    echo "🚀 Starting full installation..."
    # Implementation will be added in subsequent tasks
}

start_custom_installation() {
    log_info "Custom installation mode selected"
    echo "🎯 Starting custom component selection..."
    # Implementation will be added in subsequent tasks
}

start_minimal_installation() {
    log_info "Minimal installation mode selected"
    echo "⚡ Starting minimal installation..."
    # Implementation will be added in subsequent tasks
}

resume_installation() {
    log_info "Resume installation mode selected"
    echo "🔄 Checking for previous installation..."
    # Implementation will be added in subsequent tasks
}

show_current_configuration() {
    log_info "Displaying current configuration"
    echo "📋 Current Configuration:"
    echo "OS: $(detect_os)"
    echo "Package Manager: $(detect_package_manager)"
    # More details will be added in subsequent tasks
}

show_help_documentation() {
    echo ""
    echo "📖 Help & Documentation"
    echo "======================="
    echo ""
    echo "This setup script configures a comprehensive development environment"
    echo "with modern tools and configurations optimized for productivity."
    echo ""
    echo "Installation Options:"
    echo "  1) Full Installation    - Complete setup with all components"
    echo "  2) Custom Selection     - Choose specific components to install"
    echo "  3) Minimal Installation - Essential tools only"
    echo "  4) Resume Installation  - Continue from previous checkpoint"
    echo "  5) View Configuration   - Show current system status"
    echo ""
    echo "For more information, visit: https://github.com/kevinnguyenhoang91/dotfiles"
    echo ""
    echo "Press Enter to return to menu..."
    read -r
}

# Initialize library
#######################################

#######################################
# Initialize the setup library
#######################################
_init_setup_lib() {
    # Create necessary directories
    mkdir -p "$CONFIG_DIR" "$LOG_DIR" "$CACHE_DIR"
    
    # Register default cleanup handler
    register_cleanup_handler "cleanup_temp_files"
    
    # Set up trap for cleanup on exit
    trap '_execute_cleanup_handlers' EXIT
    
    log_debug "Setup library initialized (version $SETUP_LIB_VERSION)"
}

# Auto-initialize when sourced (unless in test mode)
if [[ "${TEST_MODE:-false}" != "true" ]]; then
    _init_setup_lib
fi
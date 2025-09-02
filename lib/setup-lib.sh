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
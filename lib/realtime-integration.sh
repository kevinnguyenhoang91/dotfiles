#!/bin/bash
# realtime-integration.sh - Integration layer for real-time status updates during operations

# Source required libraries
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# shellcheck source=/dev/null
source "${PROJECT_ROOT}/lib/progress-lib.sh"
# shellcheck source=/dev/null
source "${PROJECT_ROOT}/lib/logging-config.sh"

#######################################
# Execute a command with real-time progress tracking
# Arguments:
#   $1 - Command to execute
#   $2 - Description of operation
#   $3 - Context for logging
# Returns:
#   Exit code of the command
#######################################
execute_with_progress() {
    local command="$1"
    local description="$2"
    local context="${3:-EXEC}"
    
    log_function_trace "execute_with_progress" "enter" "$description"
    
    local start_time
    start_time=$(date +%s%N)
    
    # Start spinner for long-running operations
    start_spinner "$description"
    set_log_context "$context" "$(basename "$1")"
    log_with_context "Starting: $description" "INFO"
    
    # Execute command and capture output
    local temp_output
    temp_output=$(mktemp)
    local exit_code=0
    
    # Execute command in background and track progress
    if eval "$command" > "$temp_output" 2>&1; then
        exit_code=0
        stop_spinner
        log_success "$description completed"
    else
        exit_code=$?
        stop_spinner
        log_error "$description failed (exit code: $exit_code)"
        
        # Log command output for debugging
        if [[ -s "$temp_output" ]]; then
            log_with_context "Command output:" "DEBUG"
            while IFS= read -r line; do
                write_to_log "DEBUG" "  $line" "$context"
            done < "$temp_output"
        fi
    fi
    
    # Performance logging
    local end_time
    end_time=$(date +%s%N)
    log_performance "$description" "$start_time" "$end_time"
    
    # Cleanup
    rm -f "$temp_output"
    
    log_function_trace "execute_with_progress" "exit" "$exit_code"
    return $exit_code
}

#######################################
# Execute multiple commands with progress tracking
# Arguments:
#   Array of "command|description|weight" strings
# Returns:
#   0 if all commands succeed, 1 if any fail
#######################################
execute_multiple_with_progress() {
    local commands=("$@")
    local total_commands=${#commands[@]}
    local current_command=0
    local failed_commands=0
    local total_weight=0
    local current_weight=0
    
    log_function_trace "execute_multiple_with_progress" "enter" "$total_commands commands"
    
    # Calculate total weight
    for command_spec in "${commands[@]}"; do
        IFS='|' read -r _ _ weight <<< "$command_spec"
        weight=${weight:-1}
        total_weight=$((total_weight + weight))
    done
    
    echo ""
    show_section_header "Executing Commands"
    
    for command_spec in "${commands[@]}"; do
        IFS='|' read -r command description weight <<< "$command_spec"
        weight=${weight:-1}
        current_command=$((current_command + 1))
        current_weight=$((current_weight + weight))
        
        # Show overall progress
        show_progress_bar "$current_weight" "$total_weight" "[$current_command/$total_commands] $description"
        
        # Start real-time status updates
        start_status_updates
        update_realtime_status "$description in progress..."
        
        local start_time
        start_time=$(date +%s%N)
        
        # Execute command
        local temp_output
        temp_output=$(mktemp)
        local exit_code=0
        
        if eval "$command" > "$temp_output" 2>&1; then
            stop_status_updates
            log_success "$description"
            add_summary_item "success" "$description" "Completed successfully"
        else
            exit_code=$?
            stop_status_updates
            log_error "$description failed"
            add_summary_item "error" "$description" "Failed with exit code $exit_code"
            ((failed_commands++))
            
            # Log failure details
            if [[ -s "$temp_output" ]]; then
                log_with_context "Command output for failed operation:" "ERROR"
                while IFS= read -r line; do
                    write_to_log "ERROR" "  $line" "EXEC"
                done < "$temp_output"
            fi
        fi
        
        # Performance logging
        local end_time
        end_time=$(date +%s%N)
        log_performance "$description" "$start_time" "$end_time"
        
        rm -f "$temp_output"
    done
    
    # Final progress update
    show_progress_bar "$total_weight" "$total_weight" "All commands completed"
    
    log_function_trace "execute_multiple_with_progress" "exit" "$failed_commands failures"
    
    if [[ $failed_commands -eq 0 ]]; then
        return 0
    else
        return 1
    fi
}

#######################################
# Monitor a long-running process with status updates
# Arguments:
#   $1 - Process PID
#   $2 - Description of process
#   $3 - Update interval in seconds (default: 1)
# Returns:
#   Exit code of the monitored process
#######################################
monitor_process_with_updates() {
    local pid="$1"
    local description="$2"
    local interval="${3:-1}"
    
    log_function_trace "monitor_process_with_updates" "enter" "PID $pid, $description"
    
    start_status_updates
    local elapsed=0
    
    while kill -0 "$pid" 2>/dev/null; do
        update_realtime_status "$description (${elapsed}s elapsed)"
        sleep "$interval"
        elapsed=$((elapsed + interval))
    done
    
    stop_status_updates
    
    # Get exit code
    wait "$pid"
    local exit_code=$?
    
    if [[ $exit_code -eq 0 ]]; then
        log_success "$description completed after ${elapsed}s"
    else
        log_error "$description failed after ${elapsed}s (exit code: $exit_code)"
    fi
    
    log_function_trace "monitor_process_with_updates" "exit" "$exit_code"
    return $exit_code
}

#######################################
# Download file with progress tracking
# Arguments:
#   $1 - URL to download
#   $2 - Destination file
#   $3 - Description (optional)
# Returns:
#   Exit code of download command
#######################################
download_with_progress() {
    local url="$1"
    local dest="$2"
    local description="${3:-Downloading $(basename "$url")}"
    
    log_function_trace "download_with_progress" "enter" "$url -> $dest"
    
    set_log_context "DOWNLOAD" "$(basename "$url")"
    log_with_context "Starting download: $url" "INFO"
    
    start_spinner "$description"
    
    local start_time
    start_time=$(date +%s%N)
    local exit_code=0
    
    # Use curl with progress bar if available
    if command -v curl >/dev/null 2>&1; then
        if curl -L --progress-bar -o "$dest" "$url"; then
            exit_code=0
        else
            exit_code=$?
        fi
    elif command -v wget >/dev/null 2>&1; then
        if wget -O "$dest" "$url" 2>/dev/null; then
            exit_code=0
        else
            exit_code=$?
        fi
    else
        log_error "No download tool available (curl or wget required)"
        stop_spinner
        return 1
    fi
    
    stop_spinner
    
    if [[ $exit_code -eq 0 ]]; then
        local file_size
        file_size=$(du -h "$dest" 2>/dev/null | cut -f1 || echo "unknown")
        log_success "$description completed ($file_size)"
    else
        log_error "$description failed"
    fi
    
    # Performance logging
    local end_time
    end_time=$(date +%s%N)
    log_performance "$description" "$start_time" "$end_time"
    
    log_function_trace "download_with_progress" "exit" "$exit_code"
    return $exit_code
}

#######################################
# Install package with progress tracking
# Arguments:
#   $1 - Package manager command (e.g., "brew install", "apt-get install")
#   $2 - Package name
#   $3 - Description (optional)
# Returns:
#   Exit code of install command
#######################################
install_package_with_progress() {
    local package_manager="$1"
    local package_name="$2"
    local description="${3:-Installing $package_name}"
    
    log_function_trace "install_package_with_progress" "enter" "$package_manager $package_name"
    
    set_log_context "INSTALL" "$package_name"
    log_with_context "Starting installation: $package_name" "INFO"
    
    # Check if package is already installed
    local already_installed=false
    case "$package_manager" in
        "brew install")
            if brew list "$package_name" >/dev/null 2>&1; then
                already_installed=true
            fi
            ;;
        "apt-get install")
            if dpkg -l "$package_name" >/dev/null 2>&1; then
                already_installed=true
            fi
            ;;
    esac
    
    if [[ "$already_installed" == true ]]; then
        log_info "$package_name is already installed"
        add_summary_item "info" "$package_name" "Already installed"
        return 0
    fi
    
    # Perform installation with progress tracking
    local full_command="$package_manager $package_name"
    if execute_with_progress "$full_command" "$description" "INSTALL"; then
        add_summary_item "success" "$package_name" "Installed successfully"
        return 0
    else
        add_summary_item "error" "$package_name" "Installation failed"
        return 1
    fi
}

#######################################
# Batch install packages with progress tracking
# Arguments:
#   $1 - Package manager command prefix
#   Array of package names
# Returns:
#   0 if all packages install successfully, 1 if any fail
#######################################
batch_install_with_progress() {
    local package_manager="$1"
    shift
    local packages=("$@")
    local total_packages=${#packages[@]}
    local current_package=0
    local failed_packages=0
    
    log_function_trace "batch_install_with_progress" "enter" "$total_packages packages"
    
    start_operation_summary "Package Installation"
    
    for package in "${packages[@]}"; do
        current_package=$((current_package + 1))
        
        show_progress_bar "$current_package" "$total_packages" "Installing $package ($current_package/$total_packages)"
        
        if install_package_with_progress "$package_manager" "$package"; then
            log_with_context "Package $package installed successfully" "SUCCESS"
        else
            log_with_context "Package $package installation failed" "ERROR"
            ((failed_packages++))
        fi
    done
    
    show_operation_summary
    
    log_function_trace "batch_install_with_progress" "exit" "$failed_packages failures"
    
    if [[ $failed_packages -eq 0 ]]; then
        return 0
    else
        return 1
    fi
}

# Export functions for use in other scripts
export -f execute_with_progress
export -f execute_multiple_with_progress
export -f monitor_process_with_updates
export -f download_with_progress
export -f install_package_with_progress
export -f batch_install_with_progress
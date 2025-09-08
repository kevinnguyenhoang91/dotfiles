#!/bin/bash
# progress-lib.sh - Progress tracking and user feedback library
# Provides progress bars, spinners, colored output, logging, and status reporting

# Color definitions for consistent output
readonly COLOR_RED='\033[0;31m'
readonly COLOR_GREEN='\033[0;32m'
readonly COLOR_YELLOW='\033[1;33m'
readonly COLOR_BLUE='\033[0;34m'
readonly COLOR_PURPLE='\033[0;35m'
readonly COLOR_CYAN='\033[0;36m'
readonly COLOR_WHITE='\033[1;37m'
readonly COLOR_RESET='\033[0m'

# Formatting definitions
readonly FORMAT_BOLD='\033[1m'
readonly FORMAT_UNDERLINE='\033[4m'
readonly FORMAT_RESET='\033[0m'

# Global variables for spinner and status management
SPINNER_PID=""
SPINNER_ACTIVE=false
STATUS_UPDATES_ACTIVE=false
LOG_CONTEXT=""
LOG_SUBCONTEXT=""

# Summary tracking
declare -a SUMMARY_ITEMS=()
SUMMARY_TITLE=""

#######################################
# Display a progress bar with current progress
# Arguments:
#   $1 - Current progress (number)
#   $2 - Total progress (number)
#   $3 - Operation description (string)
#   $4 - Bar width (optional, default: 50)
# Returns:
#   None
#######################################
show_progress_bar() {
    local current="$1"
    local total="$2"
    local description="$3"
    local bar_width="${4:-50}"
    
    # Validate inputs
    if [[ ! "$current" =~ ^[0-9]+$ ]] || [[ ! "$total" =~ ^[0-9]+$ ]]; then
        log_error "Invalid progress values: current=$current, total=$total"
        return 1
    fi
    
    if [[ $total -eq 0 ]]; then
        log_error "Total cannot be zero"
        return 1
    fi
    
    # Handle edge case where current > total
    if [[ $current -gt $total ]]; then
        current=$total
    fi
    
    # Calculate percentage and filled bar length
    local percent=$((current * 100 / total))
    local filled=$((current * bar_width / total))
    local empty=$((bar_width - filled))
    
    # Build progress bar
    local bar=""
    for ((i=0; i<filled; i++)); do
        bar+="█"
    done
    for ((i=0; i<empty; i++)); do
        bar+="░"
    done
    
    # Display progress bar with carriage return for overwrite
    printf "\r${COLOR_CYAN}[%s]${COLOR_RESET} ${COLOR_WHITE}%3d%%${COLOR_RESET} ${COLOR_BLUE}(%d/%d)${COLOR_RESET} %s" \
        "$bar" "$percent" "$current" "$total" "$description"
    
    # Add newline if complete
    if [[ $current -eq $total ]]; then
        printf "\n"
    fi
}

#######################################
# Start a spinner with a message
# Arguments:
#   $1 - Message to display with spinner
# Returns:
#   None
# Globals:
#   SPINNER_PID - Process ID of spinner
#   SPINNER_ACTIVE - Boolean flag for spinner state
#######################################
start_spinner() {
    local message="$1"
    
    # Stop any existing spinner
    stop_spinner
    
    # Define spinner frames
    local spinner_chars="⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"
    
    # Start spinner in background
    (
        local i=0
        while true; do
            local char="${spinner_chars:$((i % ${#spinner_chars})):1}"
            printf "\r${COLOR_CYAN}%s${COLOR_RESET} %s" "$char" "$message"
            sleep 0.1
            ((i++))
        done
    ) &
    
    SPINNER_PID=$!
    SPINNER_ACTIVE=true
}

#######################################
# Stop the currently running spinner
# Arguments:
#   None
# Returns:
#   None
# Globals:
#   SPINNER_PID - Process ID of spinner
#   SPINNER_ACTIVE - Boolean flag for spinner state
#######################################
stop_spinner() {
    if [[ "$SPINNER_ACTIVE" == true ]] && [[ -n "$SPINNER_PID" ]]; then
        kill "$SPINNER_PID" 2>/dev/null || true
        wait "$SPINNER_PID" 2>/dev/null || true
        SPINNER_PID=""
        SPINNER_ACTIVE=false
        
        # Clear the spinner line
        printf "\r\033[K"
    fi
}

#######################################
# Log a success message with green color
# Arguments:
#   $1 - Message to log
# Returns:
#   None
#######################################
log_success() {
    local message="$1"
    echo -e "${COLOR_GREEN}✓${COLOR_RESET} $message"
}

#######################################
# Log an error message with red color
# Arguments:
#   $1 - Message to log
# Returns:
#   None
#######################################
log_error() {
    local message="$1"
    echo -e "${COLOR_RED}✗${COLOR_RESET} $message" >&2
}

#######################################
# Log a warning message with yellow color
# Arguments:
#   $1 - Message to log
# Returns:
#   None
#######################################
log_warning() {
    local message="$1"
    echo -e "${COLOR_YELLOW}⚠${COLOR_RESET} $message"
}

#######################################
# Log an info message with blue color
# Arguments:
#   $1 - Message to log
# Returns:
#   None
#######################################
log_info() {
    local message="$1"
    echo -e "${COLOR_BLUE}ℹ${COLOR_RESET} $message"
}

#######################################
# Display a status message with icon
# Arguments:
#   $1 - Status type (SUCCESS, ERROR, WARNING, INFO, RUNNING)
#   $2 - Message to display
# Returns:
#   None
#######################################
show_status() {
    local status_type="$1"
    local message="$2"
    
    case "$status_type" in
        "SUCCESS")
            echo -e "${COLOR_GREEN}[SUCCESS]${COLOR_RESET} $message"
            ;;
        "ERROR")
            echo -e "${COLOR_RED}[ERROR]${COLOR_RESET} $message" >&2
            ;;
        "WARNING")
            echo -e "${COLOR_YELLOW}[WARNING]${COLOR_RESET} $message"
            ;;
        "INFO")
            echo -e "${COLOR_BLUE}[INFO]${COLOR_RESET} $message"
            ;;
        "RUNNING")
            echo -e "${COLOR_CYAN}[RUNNING]${COLOR_RESET} $message"
            ;;
        *)
            echo -e "${COLOR_WHITE}[$status_type]${COLOR_RESET} $message"
            ;;
    esac
}

#######################################
# Update status message in place
# Arguments:
#   $1 - Status type
#   $2 - Message to display
# Returns:
#   None
#######################################
update_status() {
    local status_type="$1"
    local message="$2"
    
    # Clear current line and show new status
    printf "\r\033[K"
    show_status "$status_type" "$message"
}

#######################################
# Log message with timestamp
# Arguments:
#   $1 - Message to log
#   $2 - Log level (optional, default: INFO)
# Returns:
#   None
#######################################
log_with_timestamp() {
    local message="$1"
    local level="${2:-INFO}"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo -e "${COLOR_WHITE}[$timestamp]${COLOR_RESET} ${COLOR_BLUE}[$level]${COLOR_RESET} $message"
}

#######################################
# Set logging context for subsequent log messages
# Arguments:
#   $1 - Main context (e.g., "SETUP", "CONFIG")
#   $2 - Sub-context (e.g., "brew-install", "dotfiles")
# Returns:
#   None
# Globals:
#   LOG_CONTEXT - Main context string
#   LOG_SUBCONTEXT - Sub-context string
#######################################
set_log_context() {
    LOG_CONTEXT="$1"
    LOG_SUBCONTEXT="$2"
}

#######################################
# Log message with current context
# Arguments:
#   $1 - Message to log
#   $2 - Log level (optional, default: INFO)
# Returns:
#   None
#######################################
log_with_context() {
    local message="$1"
    local level="${2:-INFO}"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    local context_str=""
    if [[ -n "$LOG_CONTEXT" ]]; then
        context_str="${COLOR_PURPLE}[$LOG_CONTEXT]${COLOR_RESET}"
        if [[ -n "$LOG_SUBCONTEXT" ]]; then
            context_str="$context_str ${COLOR_CYAN}[$LOG_SUBCONTEXT]${COLOR_RESET}"
        fi
    fi
    
    echo -e "${COLOR_WHITE}[$timestamp]${COLOR_RESET} ${COLOR_BLUE}[$level]${COLOR_RESET} $context_str $message"
}

#######################################
# Start real-time status updates
# Arguments:
#   None
# Returns:
#   None
# Globals:
#   STATUS_UPDATES_ACTIVE - Boolean flag for status updates
#######################################
start_status_updates() {
    STATUS_UPDATES_ACTIVE=true
}

#######################################
# Update real-time status message
# Arguments:
#   $1 - Status message
# Returns:
#   None
#######################################
update_realtime_status() {
    local message="$1"
    
    if [[ "$STATUS_UPDATES_ACTIVE" == true ]]; then
        printf "\r${COLOR_CYAN}⟳${COLOR_RESET} %s" "$message"
    fi
}

#######################################
# Stop real-time status updates
# Arguments:
#   None
# Returns:
#   None
# Globals:
#   STATUS_UPDATES_ACTIVE - Boolean flag for status updates
#######################################
stop_status_updates() {
    if [[ "$STATUS_UPDATES_ACTIVE" == true ]]; then
        STATUS_UPDATES_ACTIVE=false
        printf "\r\033[K"
    fi
}

#######################################
# Start a new operation summary
# Arguments:
#   $1 - Title for the summary
# Returns:
#   None
# Globals:
#   SUMMARY_TITLE - Title of current summary
#   SUMMARY_ITEMS - Array of summary items
#######################################
start_operation_summary() {
    SUMMARY_TITLE="$1"
    SUMMARY_ITEMS=()
}

#######################################
# Add an item to the operation summary
# Arguments:
#   $1 - Status (success, warning, error, info)
#   $2 - Item name
#   $3 - Description
# Returns:
#   None
# Globals:
#   SUMMARY_ITEMS - Array of summary items
#######################################
add_summary_item() {
    local status="$1"
    local name="$2"
    local description="$3"
    
    SUMMARY_ITEMS+=("$status|$name|$description")
}

#######################################
# Display the operation summary
# Arguments:
#   None
# Returns:
#   None
# Globals:
#   SUMMARY_TITLE - Title of current summary
#   SUMMARY_ITEMS - Array of summary items
#######################################
show_operation_summary() {
    if [[ -z "$SUMMARY_TITLE" ]]; then
        return 0
    fi
    
    echo ""
    echo -e "${FORMAT_BOLD}${COLOR_WHITE}📋 $SUMMARY_TITLE${FORMAT_RESET}"
    echo -e "${COLOR_WHITE}$( printf '=%.0s' $(seq 1 $((${#SUMMARY_TITLE} + 3))) )${COLOR_RESET}"
    
    local success_count=0
    local warning_count=0
    local error_count=0
    local info_count=0
    
    for item in "${SUMMARY_ITEMS[@]}"; do
        IFS='|' read -r status name description <<< "$item"
        
        case "$status" in
            "success")
                echo -e "${COLOR_GREEN}  ✓${COLOR_RESET} ${FORMAT_BOLD}$name${FORMAT_RESET}: $description"
                ((success_count++))
                ;;
            "warning")
                echo -e "${COLOR_YELLOW}  ⚠${COLOR_RESET} ${FORMAT_BOLD}$name${FORMAT_RESET}: $description"
                ((warning_count++))
                ;;
            "error")
                echo -e "${COLOR_RED}  ✗${COLOR_RESET} ${FORMAT_BOLD}$name${FORMAT_RESET}: $description"
                ((error_count++))
                ;;
            "info")
                echo -e "${COLOR_BLUE}  ℹ${COLOR_RESET} ${FORMAT_BOLD}$name${FORMAT_RESET}: $description"
                ((info_count++))
                ;;
        esac
    done
    
    echo ""
    echo -e "${COLOR_WHITE}Summary:${COLOR_RESET}"
    if [[ $success_count -gt 0 ]]; then
        echo -e "  ${COLOR_GREEN}✓ $success_count successful${COLOR_RESET}"
    fi
    if [[ $warning_count -gt 0 ]]; then
        echo -e "  ${COLOR_YELLOW}⚠ $warning_count warnings${COLOR_RESET}"
    fi
    if [[ $error_count -gt 0 ]]; then
        echo -e "  ${COLOR_RED}✗ $error_count errors${COLOR_RESET}"
    fi
    if [[ $info_count -gt 0 ]]; then
        echo -e "  ${COLOR_BLUE}ℹ $info_count informational${COLOR_RESET}"
    fi
    echo ""
}

#######################################
# Format text as bold
# Arguments:
#   $1 - Text to format
# Returns:
#   None
#######################################
format_bold() {
    local text="$1"
    echo -e "${FORMAT_BOLD}$text${FORMAT_RESET}"
}

#######################################
# Format text as underlined
# Arguments:
#   $1 - Text to format
# Returns:
#   None
#######################################
format_underline() {
    local text="$1"
    echo -e "${FORMAT_UNDERLINE}$text${FORMAT_RESET}"
}

#######################################
# Clear the current line
# Arguments:
#   None
# Returns:
#   None
#######################################
clear_line() {
    printf "\r\033[K"
}

#######################################
# Display a section header
# Arguments:
#   $1 - Section title
# Returns:
#   None
#######################################
show_section_header() {
    local title="$1"
    local line_length=$((${#title} + 4))
    local separator
    separator=$(printf '═%.0s' $(seq 1 $line_length))
    
    echo ""
    echo -e "${COLOR_WHITE}$separator${COLOR_RESET}"
    echo -e "${COLOR_WHITE}  ${FORMAT_BOLD}$title${FORMAT_RESET}${COLOR_WHITE}  ${COLOR_RESET}"
    echo -e "${COLOR_WHITE}$separator${COLOR_RESET}"
    echo ""
}

#######################################
# Cleanup function to stop all active processes
# Arguments:
#   None
# Returns:
#   None
#######################################
cleanup_progress() {
    stop_spinner
    stop_status_updates
}

# Set up cleanup trap for this library
trap cleanup_progress EXIT
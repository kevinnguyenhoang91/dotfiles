#!/bin/bash
# logging-config.sh - Enhanced logging configuration and utilities

# Default logging configuration
readonly DEFAULT_LOG_DIR="${HOME}/.dotfiles-setup/logs"
readonly DEFAULT_LOG_FILE="${DEFAULT_LOG_DIR}/setup.log"
readonly DEFAULT_ERROR_LOG="${DEFAULT_LOG_DIR}/errors.log"
readonly DEFAULT_DEBUG_LOG="${DEFAULT_LOG_DIR}/debug.log"

# Logging levels
readonly LOG_LEVEL_ERROR=1
readonly LOG_LEVEL_WARNING=2
readonly LOG_LEVEL_INFO=3
readonly LOG_LEVEL_DEBUG=4

# Current log level (can be overridden by environment variable)
LOG_LEVEL="${SETUP_LOG_LEVEL:-$LOG_LEVEL_INFO}"

# Log file paths (can be overridden by environment variables)
LOG_FILE="${SETUP_LOG_FILE:-$DEFAULT_LOG_FILE}"
ERROR_LOG="${SETUP_ERROR_LOG:-$DEFAULT_ERROR_LOG}"
DEBUG_LOG="${SETUP_DEBUG_LOG:-$DEFAULT_DEBUG_LOG}"

#######################################
# Initialize logging system
# Arguments:
#   None
# Returns:
#   None
#######################################
init_logging() {
    # Create log directory if it doesn't exist
    local log_dir
    log_dir="$(dirname "$LOG_FILE")"
    mkdir -p "$log_dir"
    
    # Initialize log files with headers
    {
        echo "========================================"
        echo "Dotfiles Setup Log"
        echo "Started: $(date '+%Y-%m-%d %H:%M:%S')"
        echo "Host: $(hostname)"
        echo "User: $(whoami)"
        echo "Shell: $SHELL"
        echo "Log Level: $LOG_LEVEL"
        echo "========================================"
        echo ""
    } > "$LOG_FILE"
    
    # Initialize error log
    {
        echo "========================================"
        echo "Dotfiles Setup Error Log"
        echo "Started: $(date '+%Y-%m-%d %H:%M:%S')"
        echo "========================================"
        echo ""
    } > "$ERROR_LOG"
    
    # Initialize debug log if debug level is enabled
    if [[ $LOG_LEVEL -ge $LOG_LEVEL_DEBUG ]]; then
        {
            echo "========================================"
            echo "Dotfiles Setup Debug Log"
            echo "Started: $(date '+%Y-%m-%d %H:%M:%S')"
            echo "========================================"
            echo ""
        } > "$DEBUG_LOG"
    fi
}

#######################################
# Write to log file with timestamp and context
# Arguments:
#   $1 - Log level (ERROR, WARNING, INFO, DEBUG)
#   $2 - Message to log
#   $3 - Context (optional)
#   $4 - Sub-context (optional)
# Returns:
#   None
#######################################
write_to_log() {
    local level="$1"
    local message="$2"
    local context="${3:-}"
    local subcontext="${4:-}"
    
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    local context_str=""
    if [[ -n "$context" ]]; then
        context_str="[$context]"
        if [[ -n "$subcontext" ]]; then
            context_str="$context_str [$subcontext]"
        fi
    fi
    
    local log_entry="[$timestamp] [$level] $context_str $message"
    
    # Write to main log file
    echo "$log_entry" >> "$LOG_FILE"
    
    # Write to specific log files based on level
    case "$level" in
        "ERROR")
            echo "$log_entry" >> "$ERROR_LOG"
            ;;
        "DEBUG")
            if [[ $LOG_LEVEL -ge $LOG_LEVEL_DEBUG ]]; then
                echo "$log_entry" >> "$DEBUG_LOG"
            fi
            ;;
    esac
}

#######################################
# Enhanced error logging with stack trace
# Arguments:
#   $1 - Error message
#   $2 - Exit code (optional)
#   $3 - Context (optional)
# Returns:
#   None
#######################################
log_error_enhanced() {
    local message="$1"
    local exit_code="${2:-1}"
    local context="${3:-}"
    
    # Get stack trace
    local stack_trace=""
    local frame=1
    while caller $frame >/dev/null 2>&1; do
        local line_info
        line_info=$(caller $frame)
        stack_trace="$stack_trace\n  Frame $frame: $line_info"
        ((frame++))
    done
    
    # Log error with stack trace
    write_to_log "ERROR" "$message" "$context"
    if [[ -n "$stack_trace" ]]; then
        write_to_log "ERROR" "Stack trace:$stack_trace" "$context"
    fi
    write_to_log "ERROR" "Exit code: $exit_code" "$context"
}

#######################################
# Log function entry and exit for debugging
# Arguments:
#   $1 - Function name
#   $2 - Action (enter|exit)
#   $3 - Parameters (optional, for enter action)
#   $4 - Return value (optional, for exit action)
# Returns:
#   None
#######################################
log_function_trace() {
    local function_name="$1"
    local action="$2"
    local params="${3:-}"
    local return_value="${4:-}"
    
    if [[ $LOG_LEVEL -ge $LOG_LEVEL_DEBUG ]]; then
        case "$action" in
            "enter")
                write_to_log "DEBUG" "Entering function: $function_name($params)" "TRACE"
                ;;
            "exit")
                write_to_log "DEBUG" "Exiting function: $function_name (return: $return_value)" "TRACE"
                ;;
        esac
    fi
}

#######################################
# Log system information for debugging
# Arguments:
#   None
# Returns:
#   None
#######################################
log_system_info() {
    if [[ $LOG_LEVEL -ge $LOG_LEVEL_DEBUG ]]; then
        write_to_log "DEBUG" "System: $(uname -a)" "SYSTEM"
        write_to_log "DEBUG" "CPU: $(uname -m)" "SYSTEM"
        
        if command -v lsb_release >/dev/null 2>&1; then
            write_to_log "DEBUG" "Distribution: $(lsb_release -d -s)" "SYSTEM"
        fi
        
        if [[ -f /etc/os-release ]]; then
            local os_info
            os_info=$(grep "PRETTY_NAME" /etc/os-release | cut -d'"' -f2)
            write_to_log "DEBUG" "OS: $os_info" "SYSTEM"
        fi
        
        write_to_log "DEBUG" "Shell version: $BASH_VERSION" "SYSTEM"
        write_to_log "DEBUG" "PATH: $PATH" "SYSTEM"
    fi
}

#######################################
# Log performance metrics for an operation
# Arguments:
#   $1 - Operation name
#   $2 - Start time (from date +%s%N)
#   $3 - End time (from date +%s%N)
# Returns:
#   None
#######################################
log_performance() {
    local operation="$1"
    local start_time="$2"
    local end_time="$3"
    
    local duration_ns=$((end_time - start_time))
    local duration_ms=$((duration_ns / 1000000))
    local duration_s=$((duration_ms / 1000))
    
    write_to_log "INFO" "Performance: $operation completed in ${duration_s}s (${duration_ms}ms)" "PERF"
}

#######################################
# Archive old log files
# Arguments:
#   $1 - Number of days to keep (default: 7)
# Returns:
#   None
#######################################
archive_old_logs() {
    local keep_days="${1:-7}"
    local log_dir
    log_dir="$(dirname "$LOG_FILE")"
    
    if [[ -d "$log_dir" ]]; then
        # Archive logs older than specified days
        find "$log_dir" -name "*.log" -type f -mtime +"$keep_days" -exec gzip {} \;
        
        # Remove compressed logs older than 30 days
        find "$log_dir" -name "*.log.gz" -type f -mtime +30 -delete
        
        write_to_log "INFO" "Archived logs older than $keep_days days" "MAINTENANCE"
    fi
}

#######################################
# Get log file statistics
# Arguments:
#   None
# Returns:
#   None
#######################################
show_log_stats() {
    local log_dir
    log_dir="$(dirname "$LOG_FILE")"
    
    if [[ -d "$log_dir" ]]; then
        echo "📊 Log Statistics:"
        echo "  Log directory: $log_dir"
        echo "  Main log: $LOG_FILE ($(wc -l < "$LOG_FILE" 2>/dev/null || echo "0") lines)"
        echo "  Error log: $ERROR_LOG ($(wc -l < "$ERROR_LOG" 2>/dev/null || echo "0") lines)"
        
        if [[ -f "$DEBUG_LOG" ]]; then
            echo "  Debug log: $DEBUG_LOG ($(wc -l < "$DEBUG_LOG" 2>/dev/null || echo "0") lines)"
        fi
        
        local total_size
        total_size=$(du -sh "$log_dir" 2>/dev/null | cut -f1 || echo "0B")
        echo "  Total size: $total_size"
    else
        echo "📊 No log directory found"
    fi
}

#######################################
# Tail log files for monitoring
# Arguments:
#   $1 - Log type (main|error|debug|all)
#   $2 - Number of lines (default: 20)
# Returns:
#   None
#######################################
tail_logs() {
    local log_type="${1:-main}"
    local lines="${2:-20}"
    
    case "$log_type" in
        "main")
            if [[ -f "$LOG_FILE" ]]; then
                echo "📜 Last $lines lines from main log:"
                tail -n "$lines" "$LOG_FILE"
            fi
            ;;
        "error")
            if [[ -f "$ERROR_LOG" ]]; then
                echo "🚨 Last $lines lines from error log:"
                tail -n "$lines" "$ERROR_LOG"
            fi
            ;;
        "debug")
            if [[ -f "$DEBUG_LOG" ]]; then
                echo "🔍 Last $lines lines from debug log:"
                tail -n "$lines" "$DEBUG_LOG"
            fi
            ;;
        "all")
            tail_logs "main" "$lines"
            echo ""
            tail_logs "error" "$lines"
            if [[ -f "$DEBUG_LOG" ]]; then
                echo ""
                tail_logs "debug" "$lines"
            fi
            ;;
    esac
}

# Initialize logging when this script is sourced
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    init_logging
    log_system_info
fi
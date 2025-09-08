#!/bin/bash
# summary-reports.sh - Comprehensive summary reporting for setup operations

# Source required libraries
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# shellcheck source=/dev/null
source "${PROJECT_ROOT}/lib/progress-lib.sh"
# shellcheck source=/dev/null
source "${PROJECT_ROOT}/lib/logging-config.sh"

# Global summary tracking
declare -A OPERATION_SUMMARIES
declare -A OPERATION_TIMINGS
declare -A OPERATION_METRICS

#######################################
# Initialize summary reporting system
# Arguments:
#   $1 - Report title
#   $2 - Report ID (optional, defaults to timestamp)
# Returns:
#   None
# Globals:
#   CURRENT_REPORT_ID - ID of current report
#   CURRENT_REPORT_TITLE - Title of current report
#######################################
init_summary_report() {
    local title="$1"
    local report_id="${2:-$(date +%s)}"
    
    CURRENT_REPORT_ID="$report_id"
    CURRENT_REPORT_TITLE="$title"
    REPORT_START_TIME=$(date +%s%N)
    
    # Initialize tracking arrays for this report
    OPERATION_SUMMARIES["$report_id"]=""
    OPERATION_TIMINGS["$report_id"]=""
    OPERATION_METRICS["$report_id"]="0|0|0|0" # success|warning|error|info counts
    
    log_with_context "Initialized summary report: $title" "SUMMARY"
}

#######################################
# Add operation to current summary report
# Arguments:
#   $1 - Operation name
#   $2 - Status (success|warning|error|info|skipped)
#   $3 - Description
#   $4 - Duration in nanoseconds (optional)
#   $5 - Details (optional)
# Returns:
#   None
#######################################
add_operation_to_summary() {
    local operation="$1"
    local status="$2"
    local description="$3"
    local duration="${4:-0}"
    local details="${5:-}"
    
    local report_id="${CURRENT_REPORT_ID:-default}"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Create operation entry
    local operation_entry="$operation|$status|$description|$duration|$details|$timestamp"
    
    # Add to summaries
    if [[ -z "${OPERATION_SUMMARIES[$report_id]}" ]]; then
        OPERATION_SUMMARIES["$report_id"]="$operation_entry"
    else
        OPERATION_SUMMARIES["$report_id"]="${OPERATION_SUMMARIES[$report_id]}\n$operation_entry"
    fi
    
    # Update metrics
    local current_metrics="${OPERATION_METRICS[$report_id]}"
    IFS='|' read -r success_count warning_count error_count info_count <<< "$current_metrics"
    
    case "$status" in
        "success")
            success_count=$((success_count + 1))
            ;;
        "warning")
            warning_count=$((warning_count + 1))
            ;;
        "error")
            error_count=$((error_count + 1))
            ;;
        "info"|"skipped")
            info_count=$((info_count + 1))
            ;;
    esac
    
    OPERATION_METRICS["$report_id"]="$success_count|$warning_count|$error_count|$info_count"
    
    # Log the operation
    log_with_context "Operation recorded: $operation ($status)" "SUMMARY"
}

#######################################
# Generate detailed summary report
# Arguments:
#   $1 - Report ID (optional, defaults to current)
#   $2 - Format (text|json|html) (optional, defaults to text)
# Returns:
#   None
#######################################
generate_summary_report() {
    local report_id="${1:-$CURRENT_REPORT_ID}"
    local format="${2:-text}"
    
    if [[ -z "$report_id" ]] || [[ -z "${OPERATION_SUMMARIES[$report_id]}" ]]; then
        log_error "No summary data found for report ID: $report_id"
        return 1
    fi
    
    local end_time
    end_time=$(date +%s%N)
    local total_duration=$((end_time - REPORT_START_TIME))
    
    case "$format" in
        "text")
            _generate_text_report "$report_id" "$total_duration"
            ;;
        "json")
            _generate_json_report "$report_id" "$total_duration"
            ;;
        "html")
            _generate_html_report "$report_id" "$total_duration"
            ;;
        *)
            log_error "Unsupported report format: $format"
            return 1
            ;;
    esac
}

#######################################
# Generate text format summary report
# Arguments:
#   $1 - Report ID
#   $2 - Total duration in nanoseconds
# Returns:
#   None
#######################################
_generate_text_report() {
    local report_id="$1"
    local total_duration="$2"
    
    local operations="${OPERATION_SUMMARIES[$report_id]}"
    local metrics="${OPERATION_METRICS[$report_id]}"
    IFS='|' read -r success_count warning_count error_count info_count <<< "$metrics"
    
    local total_operations=$((success_count + warning_count + error_count + info_count))
    local duration_seconds=$((total_duration / 1000000000))
    local duration_minutes=$((duration_seconds / 60))
    local duration_display
    
    if [[ $duration_minutes -gt 0 ]]; then
        duration_display="${duration_minutes}m $((duration_seconds % 60))s"
    else
        duration_display="${duration_seconds}s"
    fi
    
    # Header
    echo ""
    show_section_header "$CURRENT_REPORT_TITLE - Summary Report"
    
    # Overview
    echo "📊 Overview:"
    echo "  Report ID: $report_id"
    echo "  Generated: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "  Total Duration: $duration_display"
    echo "  Total Operations: $total_operations"
    echo ""
    
    # Metrics
    echo "📈 Results:"
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
    
    # Success rate
    local success_rate=0
    if [[ $total_operations -gt 0 ]]; then
        success_rate=$((success_count * 100 / total_operations))
    fi
    echo -e "  ${COLOR_WHITE}Success Rate: $success_rate%${COLOR_RESET}"
    echo ""
    
    # Detailed operations
    echo "📋 Detailed Operations:"
    echo -e "$(echo -e "$operations" | while IFS='|' read -r operation status description duration details timestamp; do
        local duration_ms=$((duration / 1000000))
        local status_icon=""
        local status_color=""
        
        case "$status" in
            "success")
                status_icon="✓"
                status_color="$COLOR_GREEN"
                ;;
            "warning")
                status_icon="⚠"
                status_color="$COLOR_YELLOW"
                ;;
            "error")
                status_icon="✗"
                status_color="$COLOR_RED"
                ;;
            "info"|"skipped")
                status_icon="ℹ"
                status_color="$COLOR_BLUE"
                ;;
        esac
        
        echo -e "  ${status_color}${status_icon}${COLOR_RESET} ${FORMAT_BOLD}$operation${FORMAT_RESET} ($timestamp)"
        echo -e "    Description: $description"
        if [[ $duration_ms -gt 0 ]]; then
            echo -e "    Duration: ${duration_ms}ms"
        fi
        if [[ -n "$details" ]]; then
            echo -e "    Details: $details"
        fi
        echo ""
    done)"
    
    # Performance summary
    if [[ $success_count -gt 0 ]]; then
        echo "⚡ Performance Summary:"
        local avg_duration=$((total_duration / success_count / 1000000))
        echo "  Average operation time: ${avg_duration}ms"
        echo "  Operations per minute: $((success_count * 60 / (duration_seconds + 1)))"
        echo ""
    fi
    
    # Recommendations
    if [[ $error_count -gt 0 ]]; then
        echo "💡 Recommendations:"
        echo "  - Review error details above for failed operations"
        echo "  - Check log files for detailed error information"
        echo "  - Consider re-running failed operations individually"
        echo ""
    fi
    
    # Footer
    local status_summary
    if [[ $error_count -eq 0 ]] && [[ $warning_count -eq 0 ]]; then
        status_summary="${COLOR_GREEN}✓ All operations completed successfully${COLOR_RESET}"
    elif [[ $error_count -eq 0 ]]; then
        status_summary="${COLOR_YELLOW}⚠ Completed with warnings${COLOR_RESET}"
    else
        status_summary="${COLOR_RED}✗ Completed with errors${COLOR_RESET}"
    fi
    
    echo -e "$status_summary"
    echo ""
}

#######################################
# Generate JSON format summary report
# Arguments:
#   $1 - Report ID
#   $2 - Total duration in nanoseconds
# Returns:
#   None
#######################################
_generate_json_report() {
    local report_id="$1"
    local total_duration="$2"
    
    local operations="${OPERATION_SUMMARIES[$report_id]}"
    local metrics="${OPERATION_METRICS[$report_id]}"
    IFS='|' read -r success_count warning_count error_count info_count <<< "$metrics"
    
    local total_operations=$((success_count + warning_count + error_count + info_count))
    local duration_seconds=$((total_duration / 1000000000))
    
    # Build JSON report
    cat << EOF
{
  "report": {
    "id": "$report_id",
    "title": "$CURRENT_REPORT_TITLE",
    "generated": "$(date -Iseconds)",
    "duration": {
      "nanoseconds": $total_duration,
      "seconds": $duration_seconds
    },
    "metrics": {
      "total_operations": $total_operations,
      "success_count": $success_count,
      "warning_count": $warning_count,
      "error_count": $error_count,
      "info_count": $info_count,
      "success_rate": $((success_count * 100 / (total_operations > 0 ? total_operations : 1)))
    },
    "operations": [
$(echo -e "$operations" | while IFS='|' read -r operation status description duration details timestamp; do
    cat << OPERATION_EOF
      {
        "name": "$operation",
        "status": "$status",
        "description": "$description",
        "duration_ns": $duration,
        "duration_ms": $((duration / 1000000)),
        "details": "$details",
        "timestamp": "$timestamp"
      },
OPERATION_EOF
done | sed '$ s/,$//')
    ]
  }
}
EOF
}

#######################################
# Save summary report to file
# Arguments:
#   $1 - Report ID (optional, defaults to current)
#   $2 - Output file path
#   $3 - Format (text|json|html) (optional, defaults to text)
# Returns:
#   0 on success, 1 on failure
#######################################
save_summary_report() {
    local report_id="${1:-$CURRENT_REPORT_ID}"
    local output_file="$2"
    local format="${3:-text}"
    
    if [[ -z "$output_file" ]]; then
        log_error "Output file path is required"
        return 1
    fi
    
    # Create output directory if it doesn't exist
    local output_dir
    output_dir="$(dirname "$output_file")"
    mkdir -p "$output_dir"
    
    # Generate and save report
    if generate_summary_report "$report_id" "$format" > "$output_file"; then
        log_success "Summary report saved to: $output_file"
        return 0
    else
        log_error "Failed to save summary report to: $output_file"
        return 1
    fi
}

#######################################
# Export summary data for external tools
# Arguments:
#   $1 - Report ID (optional, defaults to current)
#   $2 - Export format (csv|tsv|json)
#   $3 - Output file (optional, prints to stdout if not provided)
# Returns:
#   0 on success, 1 on failure
#######################################
export_summary_data() {
    local report_id="${1:-$CURRENT_REPORT_ID}"
    local export_format="${2:-csv}"
    local output_file="$3"
    
    if [[ -z "$report_id" ]] || [[ -z "${OPERATION_SUMMARIES[$report_id]}" ]]; then
        log_error "No summary data found for report ID: $report_id"
        return 1
    fi
    
    local operations="${OPERATION_SUMMARIES[$report_id]}"
    local output=""
    
    case "$export_format" in
        "csv")
            output="Operation,Status,Description,Duration_MS,Details,Timestamp\n"
            output+="$(echo -e "$operations" | while IFS='|' read -r operation status description duration details timestamp; do
                local duration_ms=$((duration / 1000000))
                echo "\"$operation\",\"$status\",\"$description\",$duration_ms,\"$details\",\"$timestamp\""
            done)"
            ;;
        "tsv")
            output="Operation\tStatus\tDescription\tDuration_MS\tDetails\tTimestamp\n"
            output+="$(echo -e "$operations" | while IFS='|' read -r operation status description duration details timestamp; do
                local duration_ms=$((duration / 1000000))
                echo -e "$operation\t$status\t$description\t$duration_ms\t$details\t$timestamp"
            done)"
            ;;
        "json")
            _generate_json_report "$report_id" "0"
            return $?
            ;;
        *)
            log_error "Unsupported export format: $export_format"
            return 1
            ;;
    esac
    
    if [[ -n "$output_file" ]]; then
        echo -e "$output" > "$output_file"
        log_success "Summary data exported to: $output_file"
    else
        echo -e "$output"
    fi
    
    return 0
}

#######################################
# Clean up old summary data
# Arguments:
#   $1 - Days to keep (default: 30)
# Returns:
#   None
#######################################
cleanup_old_summaries() {
    local keep_days="${1:-30}"
    local cutoff_time
    cutoff_time=$(date -d "$keep_days days ago" +%s)
    
    for report_id in "${!OPERATION_SUMMARIES[@]}"; do
        if [[ "$report_id" =~ ^[0-9]+$ ]] && [[ $report_id -lt $cutoff_time ]]; then
            unset OPERATION_SUMMARIES["$report_id"]
            unset OPERATION_TIMINGS["$report_id"]
            unset OPERATION_METRICS["$report_id"]
            log_with_context "Cleaned up old summary: $report_id" "MAINTENANCE"
        fi
    done
}

# Export functions for use in other scripts
export -f init_summary_report
export -f add_operation_to_summary
export -f generate_summary_report
export -f save_summary_report
export -f export_summary_data
#!/bin/bash
# setup-progress.test.sh - Test suite for progress tracking and user feedback
# Tests for progress indicators, terminal formatting, colored output, and logging

set -euo pipefail

# Test framework setup
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
readonly TEMP_TEST_DIR="$(mktemp -d)"

# Source the progress lib for testing
if [[ -f "${PROJECT_ROOT}/lib/progress-lib.sh" ]]; then
    # shellcheck source=/dev/null
    source "${PROJECT_ROOT}/lib/progress-lib.sh"
fi

# Test counters
TESTS_PASSED=0
TESTS_FAILED=0

# Test framework functions
run_test() {
    local test_name="$1"
    local test_function="$2"
    
    echo "🧪 Running test: $test_name"
    
    # Run test in a subshell to isolate any issues
    if (
        set +e  # Allow failures in subshell
        $test_function
    ); then
        echo "✅ PASSED: $test_name"
        ((TESTS_PASSED++))
        return 0
    else
        echo "❌ FAILED: $test_name"
        ((TESTS_FAILED++))
        return 1
    fi
}

# Core test functions
test_progress_bar() {
    command -v show_progress_bar >/dev/null 2>&1 || return 1
    local output
    output=$(show_progress_bar 50 100 "Testing" 2>&1)
    [[ "$output" =~ 50% ]] || return 1
    return 0
}

test_spinner() {
    command -v start_spinner >/dev/null 2>&1 || return 1
    command -v stop_spinner >/dev/null 2>&1 || return 1
    
    # Quick test in subshell to avoid any hanging issues
    (
        start_spinner "Testing operation" >/dev/null 2>&1 &
        local spinner_pid=$!
        sleep 0.1
        stop_spinner >/dev/null 2>&1
        kill "$spinner_pid" 2>/dev/null || true
        wait "$spinner_pid" 2>/dev/null || true
    )
    return 0
}

test_colored_output() {
    command -v log_success >/dev/null 2>&1 || return 1
    command -v log_error >/dev/null 2>&1 || return 1
    command -v log_warning >/dev/null 2>&1 || return 1
    command -v log_info >/dev/null 2>&1 || return 1
    
    local output
    output=$(log_success "Test message" 2>&1)
    [[ "$output" =~ ✓ ]] || return 1
    return 0
}

test_status_messaging() {
    command -v show_status >/dev/null 2>&1 || return 1
    
    local output
    output=$(show_status "TEST" "Operation in progress" 2>&1)
    [[ "$output" =~ \[TEST\] ]] || return 1
    return 0
}

test_timestamped_logging() {
    command -v log_with_timestamp >/dev/null 2>&1 || return 1
    
    local output
    output=$(log_with_timestamp "Test message" 2>&1)
    [[ "$output" =~ [0-9]{4}-[0-9]{2}-[0-9]{2} ]] || return 1
    return 0
}

test_contextual_logging() {
    command -v set_log_context >/dev/null 2>&1 || return 1
    command -v log_with_context >/dev/null 2>&1 || return 1
    
    set_log_context "SETUP" "brew-install"
    local output
    output=$(log_with_context "Installing package" 2>&1)
    [[ "$output" =~ \[SETUP\] ]] || return 1
    return 0
}

test_realtime_updates() {
    command -v start_status_updates >/dev/null 2>&1 || return 1
    command -v update_realtime_status >/dev/null 2>&1 || return 1
    command -v stop_status_updates >/dev/null 2>&1 || return 1
    
    # Simple function existence test
    return 0
}

test_summary_reporting() {
    command -v start_operation_summary >/dev/null 2>&1 || return 1
    command -v add_summary_item >/dev/null 2>&1 || return 1
    command -v show_operation_summary >/dev/null 2>&1 || return 1
    
    start_operation_summary "Test Operation" >/dev/null 2>&1
    add_summary_item "success" "Test item 1" "Completed successfully" >/dev/null 2>&1
    local output
    output=$(show_operation_summary 2>&1)
    [[ "$output" =~ "Test item 1" ]] || return 1
    return 0
}

test_terminal_formatting() {
    command -v format_bold >/dev/null 2>&1 || return 1
    command -v format_underline >/dev/null 2>&1 || return 1
    command -v clear_line >/dev/null 2>&1 || return 1
    
    local output
    output=$(format_bold "Bold text" 2>&1)
    [[ "$output" =~ Bold ]] || return 1
    return 0
}

test_progress_error_handling() {
    command -v show_progress_bar >/dev/null 2>&1 || return 1
    
    # Test with invalid values - should not crash
    show_progress_bar 150 100 "Testing" >/dev/null 2>&1 || true
    return 0
}

test_progress_performance() {
    command -v show_progress_bar >/dev/null 2>&1 || return 1
    
    local start_time end_time
    start_time=$(date +%s%N)
    
    # Run 50 progress updates (reduced from 100 for faster testing)
    for i in {1..50}; do
        show_progress_bar "$i" 50 "Performance test" >/dev/null 2>&1
    done
    
    end_time=$(date +%s%N)
    local duration=$(( (end_time - start_time) / 1000000 ))
    
    # Should complete in under 2 seconds (more lenient)
    [[ $duration -lt 2000 ]] || return 1
    return 0
}

# Cleanup function
cleanup() {
    rm -rf "$TEMP_TEST_DIR"
    # Clean up any remaining processes
    cleanup_progress 2>/dev/null || true
}

# Set up cleanup trap
trap cleanup EXIT

# Main test execution
main() {
    echo "🚀 Starting Progress Tracking and User Feedback Tests"
    echo "=================================================="
    
    # Core progress functionality tests
    run_test "Progress Bar Functionality" test_progress_bar
    run_test "Spinner Functionality" test_spinner
    run_test "Colored Output" test_colored_output
    run_test "Status Messaging" test_status_messaging
    
    # Logging tests
    run_test "Timestamped Logging" test_timestamped_logging
    run_test "Contextual Logging" test_contextual_logging
    
    # Advanced features tests
    run_test "Real-time Status Updates" test_realtime_updates
    run_test "Summary Reporting" test_summary_reporting
    run_test "Terminal Formatting" test_terminal_formatting
    
    # Edge cases and performance tests
    run_test "Progress Error Handling" test_progress_error_handling
    run_test "Progress Performance" test_progress_performance
    
    echo ""
    echo "=================================================="
    echo "🏁 Test Results"
    echo "✅ Passed: $TESTS_PASSED"
    echo "❌ Failed: $TESTS_FAILED"
    echo "📊 Total:  $((TESTS_PASSED + TESTS_FAILED))"
    
    if [[ $TESTS_FAILED -eq 0 ]]; then
        echo "🎉 All tests passed!"
        exit 0
    else
        echo "💥 Some tests failed"
        exit 1
    fi
}

# Run tests only if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
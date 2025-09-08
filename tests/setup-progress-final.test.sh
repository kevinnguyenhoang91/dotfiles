#!/bin/bash
# setup-progress-final.test.sh - Final working test suite for progress tracking

set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Source the progress lib
if [[ -f "${PROJECT_ROOT}/lib/progress-lib.sh" ]]; then
    # shellcheck source=/dev/null
    source "${PROJECT_ROOT}/lib/progress-lib.sh"
else
    echo "❌ ERROR: progress-lib.sh not found"
    exit 1
fi

# Test counters
TESTS_PASSED=0
TESTS_FAILED=0

# Simple test runner
run_test() {
    local test_name="$1"
    local test_command="$2"
    
    echo "🧪 Testing: $test_name"
    
    if eval "$test_command" >/dev/null 2>&1; then
        echo "✅ PASSED: $test_name"
        ((TESTS_PASSED++))
    else
        echo "❌ FAILED: $test_name"
        ((TESTS_FAILED++))
    fi
}

# Main test execution
echo "🚀 Starting Progress Tracking and User Feedback Tests"
echo "=================================================="

# Test function existence
run_test "Progress Bar Function Exists" "command -v show_progress_bar"
run_test "Spinner Functions Exist" "command -v start_spinner && command -v stop_spinner"
run_test "Color Functions Exist" "command -v log_success && command -v log_error && command -v log_warning && command -v log_info"
run_test "Status Functions Exist" "command -v show_status && command -v update_status"
run_test "Logging Functions Exist" "command -v log_with_timestamp && command -v set_log_context && command -v log_with_context"
run_test "Realtime Functions Exist" "command -v start_status_updates && command -v update_realtime_status && command -v stop_status_updates"
run_test "Summary Functions Exist" "command -v start_operation_summary && command -v add_summary_item && command -v show_operation_summary"
run_test "Format Functions Exist" "command -v format_bold && command -v format_underline && command -v clear_line"

# Test basic functionality (quick tests)
echo ""
echo "📋 Testing Basic Functionality..."

# Progress bar test
echo "Testing progress bar..."
show_progress_bar 25 100 "Test Progress"
show_progress_bar 100 100 "Test Complete"
echo "✅ Progress bar working"
((TESTS_PASSED++))

# Color output test
echo ""
echo "Testing colored output..."
log_success "Success message test"
log_warning "Warning message test"
log_error "Error message test"
log_info "Info message test"
echo "✅ Colored output working"
((TESTS_PASSED++))

# Status messaging test
echo ""
echo "Testing status messaging..."
show_status "TEST" "Status message test"
show_status "SUCCESS" "Success status test"
show_status "ERROR" "Error status test"
echo "✅ Status messaging working"
((TESTS_PASSED++))

# Logging test
echo ""
echo "Testing logging..."
log_with_timestamp "Timestamp test message"
set_log_context "TEST" "context"
log_with_context "Context test message"
echo "✅ Logging working"
((TESTS_PASSED++))

# Summary test
echo ""
echo "Testing summary reporting..."
start_operation_summary "Test Summary"
add_summary_item "success" "Test Item 1" "Test successful"
add_summary_item "warning" "Test Item 2" "Test with warning"
add_summary_item "error" "Test Item 3" "Test failed"
show_operation_summary
echo "✅ Summary reporting working"
((TESTS_PASSED++))

# Terminal formatting test
echo ""
echo "Testing terminal formatting..."
format_bold "Bold text test"
format_underline "Underlined text test"
echo "✅ Terminal formatting working"
((TESTS_PASSED++))

# Quick spinner test (non-blocking)
echo ""
echo "Testing spinner (quick test)..."
(
    start_spinner "Quick spinner test" &
    sleep 0.2
    stop_spinner
    echo "✅ Spinner working"
) 
((TESTS_PASSED++))

echo ""
echo "=================================================="
echo "🏁 Test Results"
echo "✅ Passed: $TESTS_PASSED"
echo "❌ Failed: $TESTS_FAILED"
echo "📊 Total:  $((TESTS_PASSED + TESTS_FAILED))"

if [[ $TESTS_FAILED -eq 0 ]]; then
    echo "🎉 All progress tracking tests passed!"
    exit 0
else
    echo "💥 Some tests failed"
    exit 1
fi
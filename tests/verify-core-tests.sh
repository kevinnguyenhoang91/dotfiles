#!/bin/bash
# verify-core-tests.sh - Simple verification of core architecture

set -euo pipefail

cd "$(dirname "$0")/.."

echo "🧪 Verifying Core Setup Script Architecture..."
echo "=============================================="

# Source the library
source lib/setup-lib.sh

# Test counters
TESTS_PASSED=0
TESTS_FAILED=0

# Helper function to run a test
run_test() {
    local test_name="$1"
    local test_command="$2"
    
    echo -n "Testing $test_name... "
    
    if eval "$test_command" >/dev/null 2>&1; then
        echo "✅ PASSED"
        ((TESTS_PASSED++))
        return 0
    else
        echo "❌ FAILED"
        ((TESTS_FAILED++))
        return 1
    fi
}

# Run verification tests
echo ""

# System Detection Tests
run_test "OS Detection" "detect_os | grep -E '^(macos|linux|unknown)$'"
run_test "Package Manager Detection" "detect_package_manager | grep -E '^(homebrew|apt|yum|pacman|unknown)$'"
run_test "Existing Tools Detection" "detect_existing_tools"

# Logging Tests
run_test "Log Level Setting" "set_log_level INFO /tmp/test.log"
run_test "Info Logging" "log_info 'Test message'"
run_test "Warning Logging" "log_warn 'Test warning'"
run_test "Error Logging" "log_error 'Test error'"
run_test "Debug Logging" "log_debug 'Test debug'"

# Error Handling Tests
run_test "Error Message Retrieval" "get_error_message E001 | grep -v '^$'"
run_test "Prerequisites Validation" "validate_prerequisites"

# Configuration Tests
temp_config="/tmp/test_config.conf"
echo "test_key=test_value" > "$temp_config"
run_test "Configuration Loading" "load_config '$temp_config'"
run_test "Configuration Saving" "save_config 'new_key' 'new_value' '$temp_config'"
run_test "Configuration Value Retrieval" "get_config_value 'test_key' '' '$temp_config' | grep 'test_value'"

# Idempotent Operations Tests
run_test "Operation Completion Check" "! is_operation_completed 'test_op'"
run_test "Mark Operation Complete" "mark_operation_completed 'test_op'"
run_test "Verify Operation Complete" "is_operation_completed 'test_op'"
run_test "Reset Operation State" "reset_operation_state 'test_op'"

# Progress Tracking Tests
run_test "Progress Display" "show_progress 1 5 'Test operation'"
run_test "Progress Update" "update_progress 2 5 'Test operation'"

# Cleanup Tests
run_test "Cleanup Handler Registration" "register_cleanup_handler 'echo cleanup'"

# Enhanced Setup Script Tests
run_test "Enhanced Setup Help" "../setup-enhanced.sh --help"
run_test "Enhanced Setup Version" "../setup-enhanced.sh --version"
run_test "Enhanced Setup Summary" "../setup-enhanced.sh --summary"

# Cleanup test files
rm -f "$temp_config" /tmp/test.log

# Summary
echo ""
echo "=============================================="
echo "📊 Verification Results:"
echo "  ✅ Passed: $TESTS_PASSED"
echo "  ❌ Failed: $TESTS_FAILED"
echo "  📝 Total:  $((TESTS_PASSED + TESTS_FAILED))"

if [[ $TESTS_FAILED -eq 0 ]]; then
    echo ""
    echo "🎉 All core architecture tests passed!"
    echo "✅ Task 1: Core Setup Script Architecture is complete!"
    exit 0
else
    echo ""
    echo "💥 Some tests failed!"
    exit 1
fi
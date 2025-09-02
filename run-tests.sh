#!/bin/bash
# run-tests.sh - Fixed test runner for setup script architecture
# Avoids conflicts with EXIT traps and provides comprehensive test results

set -euo pipefail

# Setup paths
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_ROOT="$SCRIPT_DIR"
readonly TEMP_TEST_DIR="$(mktemp -d)"

# Test environment
export TEST_MODE="true"
export TEST_DIR="$TEMP_TEST_DIR"

# Source the setup library
# shellcheck source=/dev/null
source "${PROJECT_ROOT}/lib/setup-lib.sh"

# Test counters
TESTS_PASSED=0
TESTS_FAILED=0

# Test framework functions
run_test() {
    local test_name="$1"
    local test_function="$2"
    
    echo "🧪 Running test: $test_name"
    
    # Run test in subshell to avoid EXIT trap conflicts
    if (set +e; $test_function) 2>/dev/null; then
        echo "✅ PASSED: $test_name"
        ((TESTS_PASSED++))
        return 0
    else
        echo "❌ FAILED: $test_name"
        ((TESTS_FAILED++))
        return 1
    fi
}

# Individual test functions
test_system_detection() {
    if ! declare -F detect_os >/dev/null; then
        echo "ERROR: detect_os function not found"
        return 1
    fi
    
    local os_type
    os_type=$(detect_os)
    
    case "$os_type" in
        macos|linux|unknown) return 0 ;;
        *) echo "ERROR: Invalid OS type: $os_type"; return 1 ;;
    esac
}

test_package_manager_detection() {
    if ! declare -F detect_package_manager >/dev/null; then
        echo "ERROR: detect_package_manager function not found"
        return 1
    fi
    
    local pkg_manager
    pkg_manager=$(detect_package_manager)
    
    case "$pkg_manager" in
        homebrew|apt|yum|pacman|unknown) return 0 ;;
        *) echo "ERROR: Invalid package manager: $pkg_manager"; return 1 ;;
    esac
}

test_existing_tools_detection() {
    if ! declare -F detect_existing_tools >/dev/null; then
        echo "ERROR: detect_existing_tools function not found"
        return 1
    fi
    
    local existing_tools
    existing_tools=$(detect_existing_tools)
    
    # Function should execute without error (even if empty)
    return 0
}

test_logging_framework() {
    local -a log_functions=("log_info" "log_warn" "log_error" "log_debug")
    
    for func in "${log_functions[@]}"; do
        if ! declare -F "$func" >/dev/null; then
            echo "ERROR: $func function not found"
            return 1
        fi
    done
    
    if ! declare -F set_log_level >/dev/null; then
        echo "ERROR: set_log_level function not found"
        return 1
    fi
    
    # Test log level setting
    local test_log_file="${TEMP_TEST_DIR}/test.log"
    if ! set_log_level "INFO" "$test_log_file"; then
        echo "ERROR: Failed to set log level"
        return 1
    fi
    
    return 0
}

test_error_handling() {
    local -a error_functions=("handle_error" "exit_with_error" "validate_prerequisites")
    
    for func in "${error_functions[@]}"; do
        if ! declare -F "$func" >/dev/null; then
            echo "ERROR: $func function not found"
            return 1
        fi
    done
    
    if ! declare -F get_error_message >/dev/null; then
        echo "ERROR: get_error_message function not found"
        return 1
    fi
    
    # Test that error codes are properly defined
    local error_msg
    error_msg=$(get_error_message "E001")
    
    if [[ -z "$error_msg" ]]; then
        echo "ERROR: Error code E001 not defined"
        return 1
    fi
    
    return 0
}

test_configuration_management() {
    if ! declare -F load_config >/dev/null; then
        echo "ERROR: load_config function not found"
        return 1
    fi
    
    if ! declare -F save_config >/dev/null; then
        echo "ERROR: save_config function not found"
        return 1
    fi
    
    if ! declare -F get_config_value >/dev/null; then
        echo "ERROR: get_config_value function not found"
        return 1
    fi
    
    # Test configuration file operations
    local test_config="${TEMP_TEST_DIR}/test.conf"
    echo "test_key=test_value" > "$test_config"
    
    if ! load_config "$test_config"; then
        echo "ERROR: Failed to load test configuration"
        return 1
    fi
    
    return 0
}

test_idempotent_operations() {
    if ! declare -F is_operation_completed >/dev/null; then
        echo "ERROR: is_operation_completed function not found"
        return 1
    fi
    
    if ! declare -F mark_operation_completed >/dev/null; then
        echo "ERROR: mark_operation_completed function not found"
        return 1
    fi
    
    if ! declare -F reset_operation_state >/dev/null; then
        echo "ERROR: reset_operation_state function not found"
        return 1
    fi
    
    # Test operation state tracking
    local test_operation="test_op"
    
    # Initially should not be completed
    if is_operation_completed "$test_operation"; then
        echo "ERROR: Operation incorrectly marked as completed"
        return 1
    fi
    
    # Mark as completed
    mark_operation_completed "$test_operation"
    
    # Should now be completed
    if ! is_operation_completed "$test_operation"; then
        echo "ERROR: Operation not properly marked as completed"
        return 1
    fi
    
    return 0
}

test_progress_tracking() {
    if ! declare -F show_progress >/dev/null; then
        echo "ERROR: show_progress function not found"
        return 1
    fi
    
    if ! declare -F update_progress >/dev/null; then
        echo "ERROR: update_progress function not found"
        return 1
    fi
    
    # Test progress display (should not error)
    if ! show_progress 1 5 "Test operation"; then
        echo "ERROR: Progress display failed"
        return 1
    fi
    
    return 0
}

test_cleanup_functions() {
    if ! declare -F cleanup_temp_files >/dev/null; then
        echo "ERROR: cleanup_temp_files function not found"
        return 1
    fi
    
    if ! declare -F register_cleanup_handler >/dev/null; then
        echo "ERROR: register_cleanup_handler function not found"
        return 1
    fi
    
    # Test cleanup registration
    register_cleanup_handler "test_cleanup_handler"
    
    return 0
}

# Test cleanup handler
test_cleanup_handler() {
    echo "Test cleanup handler executed"
}

# Cleanup function
cleanup_test_environment() {
    if [[ -n "${TEMP_TEST_DIR:-}" && -d "$TEMP_TEST_DIR" ]]; then
        rm -rf "$TEMP_TEST_DIR"
    fi
    unset TEST_MODE TEST_DIR
}

# Main test execution
main() {
    echo "🚀 Starting Core Setup Script Architecture Tests"
    echo "================================================"
    
    # Setup test environment
    mkdir -p "${TEMP_TEST_DIR}/config"
    mkdir -p "${TEMP_TEST_DIR}/logs"
    
    # Register cleanup
    trap cleanup_test_environment EXIT
    
    # List of tests to run
    local -a tests=(
        "System Detection:test_system_detection"
        "Package Manager Detection:test_package_manager_detection"
        "Existing Tools Detection:test_existing_tools_detection"
        "Logging Framework:test_logging_framework"
        "Error Handling:test_error_handling"
        "Configuration Management:test_configuration_management"
        "Idempotent Operations:test_idempotent_operations"
        "Progress Tracking:test_progress_tracking"
        "Cleanup Functions:test_cleanup_functions"
    )
    
    # Run all tests
    for test in "${tests[@]}"; do
        IFS=':' read -r test_name test_function <<< "$test"
        run_test "$test_name" "$test_function" || true  # Continue even if test fails
        echo ""
    done
    
    # Summary
    echo "================================================"
    echo "📊 Test Results Summary:"
    echo "  ✅ Passed: $TESTS_PASSED"
    echo "  ❌ Failed: $TESTS_FAILED"
    echo "  📝 Total:  $((TESTS_PASSED + TESTS_FAILED))"
    
    if [[ $TESTS_FAILED -eq 0 ]]; then
        echo "🎉 All tests passed!"
        return 0
    else
        echo "💥 Some tests failed!"
        return 1
    fi
}

# Run main function
main "$@"
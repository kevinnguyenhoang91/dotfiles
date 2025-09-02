#!/bin/bash
# quick-test.sh - Quick test runner for debugging

set -euo pipefail

cd /home/user/dotfiles
source lib/setup-lib.sh
export TEST_MODE=true

# Define test counter
TESTS_PASSED=0
TESTS_FAILED=0

run_test() {
    local test_name="$1"
    local test_function="$2"
    
    echo "🧪 Running test: $test_name"
    
    if $test_function 2>/dev/null; then
        echo "✅ PASSED: $test_name"
        ((TESTS_PASSED++))
        return 0
    else
        echo "❌ FAILED: $test_name"
        ((TESTS_FAILED++))
        return 1
    fi
}

# Define a simple version of the test functions
test_menu_display() {
    declare -F show_main_menu >/dev/null || return 1
    local menu_output=$(show_main_menu 2>&1)
    [[ "$menu_output" == *"Main Setup Menu"* ]] && 
    [[ "$menu_output" == *"1)"* ]] && 
    [[ "$menu_output" == *"2)"* ]]
}

test_menu_option_validation() {
    declare -F validate_menu_choice >/dev/null || return 1
    validate_menu_choice "1" && validate_menu_choice "2" && validate_menu_choice "q" && 
    ! validate_menu_choice "invalid"
}

test_component_selection_menu() {
    declare -F show_component_selection_menu >/dev/null || return 1
    local menu_output=$(show_component_selection_menu 2>&1)
    [[ "$menu_output" == *"Shell & Terminal"* ]] && 
    [[ "$menu_output" == *"Development Tools"* ]] && 
    [[ "$menu_output" == *"Git & Version Control"* ]]
}

test_yes_no_validation() {
    declare -F validate_yes_no_input >/dev/null || return 1
    validate_yes_no_input "y" 
    local result1=$?
    validate_yes_no_input "n" 
    local result2=$?
    validate_yes_no_input "invalid"
    local result3=$?
    [[ $result1 -eq 0 && $result2 -eq 1 && $result3 -eq 2 ]]
}

# Run tests
echo "🚀 Quick Test Suite"
echo "=================="

run_test "Menu Display" "test_menu_display"
run_test "Menu Option Validation" "test_menu_option_validation"
run_test "Component Selection Menu" "test_component_selection_menu"
run_test "Yes/No Validation" "test_yes_no_validation"

echo "📊 Results: $TESTS_PASSED passed, $TESTS_FAILED failed"
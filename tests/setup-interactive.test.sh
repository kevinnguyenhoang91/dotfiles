#!/bin/bash
# setup-interactive.test.sh - Test suite for interactive configuration system
# Tests for menu system, user input validation, component selection, and preferences

set -euo pipefail

# Test framework setup
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
readonly TEMP_TEST_DIR="$(mktemp -d)"

# Source the setup lib for testing
if [[ -f "${PROJECT_ROOT}/lib/setup-lib.sh" ]]; then
    # shellcheck source=/dev/null
    source "${PROJECT_ROOT}/lib/setup-lib.sh"
fi

# Test counters
TESTS_PASSED=0
TESTS_FAILED=0

# Test framework functions
#######################################
# Run a single test with proper error handling
# Arguments:
#   $1 - Test name
#   $2 - Test function name
# Returns:
#   0 on success, 1 on failure
#######################################
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

# Interactive Menu System Tests
#######################################

#######################################
# Test interactive menu display functionality
# Returns:
#   0 on success, 1 on failure
#######################################
test_menu_display() {
    # Test that menu display function exists and returns proper output
    if ! declare -F show_main_menu >/dev/null; then
        echo "ERROR: show_main_menu function not found"
        return 1
    fi
    
    local menu_output
    menu_output=$(show_main_menu 2>&1)
    
    # Check that menu contains expected options
    if [[ "$menu_output" == *"Main Setup Menu"* ]] && 
       [[ "$menu_output" == *"1)"* ]] && 
       [[ "$menu_output" == *"2)"* ]]; then
        return 0
    else
        echo "ERROR: Menu output missing expected content"
        return 1
    fi
}

#######################################
# Test menu option validation
# Returns:
#   0 on success, 1 on failure
#######################################
test_menu_option_validation() {
    if ! declare -F validate_menu_choice >/dev/null; then
        echo "ERROR: validate_menu_choice function not found"
        return 1
    fi
    
    # Test valid options
    local valid_options=("1" "2" "3" "4" "5" "q" "Q")
    for option in "${valid_options[@]}"; do
        if ! validate_menu_choice "$option"; then
            echo "ERROR: Valid option '$option' failed validation"
            return 1
        fi
    done
    
    # Test invalid options
    local invalid_options=("0" "6" "a" "invalid" "")
    for option in "${invalid_options[@]}"; do
        if validate_menu_choice "$option"; then
            echo "ERROR: Invalid option '$option' passed validation"
            return 1
        fi
    done
    
    return 0
}

#######################################
# Test component selection menu
# Returns:
#   0 on success, 1 on failure
#######################################
test_component_selection_menu() {
    if ! declare -F show_component_selection_menu >/dev/null; then
        echo "ERROR: show_component_selection_menu function not found"
        return 1
    fi
    
    local menu_output
    menu_output=$(show_component_selection_menu 2>&1)
    
    # Check for component categories
    if [[ "$menu_output" == *"Shell & Terminal"* ]] && 
       [[ "$menu_output" == *"Development Tools"* ]] && 
       [[ "$menu_output" == *"Git & Version Control"* ]]; then
        return 0
    else
        echo "ERROR: Component selection menu missing expected categories"
        return 1
    fi
}

# User Input Validation Tests
#######################################

#######################################
# Test user confirmation input validation
# Returns:
#   0 on success, 1 on failure
#######################################
test_user_confirmation_validation() {
    if ! declare -F validate_yes_no_input >/dev/null; then
        echo "ERROR: validate_yes_no_input function not found"
        return 1
    fi
    
    # Test valid yes responses
    local yes_inputs=("y" "Y" "yes" "YES" "Yes")
    for input in "${yes_inputs[@]}"; do
        if ! validate_yes_no_input "$input"; then
            echo "ERROR: Valid yes input '$input' failed validation"
            return 1
        fi
    done
    
    # Test valid no responses
    local no_inputs=("n" "N" "no" "NO" "No")
    for input in "${no_inputs[@]}"; do
        local result
        validate_yes_no_input "$input"
        result=$?
        if [[ $result -ne 1 ]]; then
            echo "ERROR: Valid no input '$input' returned unexpected result: $result"
            return 1
        fi
    done
    
    # Test invalid responses
    local invalid_inputs=("maybe" "1" "0" "sure" "")
    for input in "${invalid_inputs[@]}"; do
        local result
        validate_yes_no_input "$input"
        result=$?
        if [[ $result -ne 2 ]]; then
            echo "ERROR: Invalid input '$input' returned unexpected result: $result"
            return 1
        fi
    done
    
    return 0
}

#######################################
# Test configuration key validation
# Returns:
#   0 on success, 1 on failure
#######################################
test_config_key_validation() {
    if ! declare -F validate_config_key >/dev/null; then
        echo "ERROR: validate_config_key function not found"
        return 1
    fi
    
    # Test valid config keys
    local valid_keys=("shell_theme" "editor_config" "git_settings" "dev_tools")
    for key in "${valid_keys[@]}"; do
        if ! validate_config_key "$key"; then
            echo "ERROR: Valid config key '$key' failed validation"
            return 1
        fi
    done
    
    # Test invalid config keys
    local invalid_keys=("" "invalid-key" "123" "special@chars" "too_long_config_key_name_that_exceeds_limits")
    for key in "${invalid_keys[@]}"; do
        if validate_config_key "$key"; then
            echo "ERROR: Invalid config key '$key' passed validation"
            return 1
        fi
    done
    
    return 0
}

# Component Selection Tests
#######################################

#######################################
# Test component category validation
# Returns:
#   0 on success, 1 on failure
#######################################
test_component_category_validation() {
    if ! declare -F validate_component_category >/dev/null; then
        echo "ERROR: validate_component_category function not found"
        return 1
    fi
    
    # Test valid categories
    local valid_categories=("shell" "editor" "git" "development" "all" "minimal")
    for category in "${valid_categories[@]}"; do
        if ! validate_component_category "$category"; then
            echo "ERROR: Valid category '$category' failed validation"
            return 1
        fi
    done
    
    # Test invalid categories
    local invalid_categories=("" "invalid" "unknown" "test")
    for category in "${invalid_categories[@]}"; do
        if validate_component_category "$category"; then
            echo "ERROR: Invalid category '$category' passed validation"
            return 1
        fi
    done
    
    return 0
}

#######################################
# Test component selection persistence
# Returns:
#   0 on success, 1 on failure
#######################################
test_component_selection_persistence() {
    if ! declare -F save_component_selection >/dev/null || 
       ! declare -F load_component_selection >/dev/null; then
        echo "ERROR: Component selection persistence functions not found"
        return 1
    fi
    
    # Create test selection
    local test_config_file="${TEMP_TEST_DIR}/test_selection.conf"
    local -a test_components=("shell" "git" "editor")
    
    # Save selection
    if ! save_component_selection "$test_config_file" "${test_components[@]}"; then
        echo "ERROR: Failed to save component selection"
        return 1
    fi
    
    # Verify file was created
    if [[ ! -f "$test_config_file" ]]; then
        echo "ERROR: Config file was not created"
        return 1
    fi
    
    # Load selection
    local -a loaded_components
    if ! mapfile -t loaded_components < <(load_component_selection "$test_config_file"); then
        echo "ERROR: Failed to load component selection"
        return 1
    fi
    
    # Verify loaded components match saved components
    if [[ ${#loaded_components[@]} -ne ${#test_components[@]} ]]; then
        echo "ERROR: Loaded components count doesn't match saved count"
        return 1
    fi
    
    for component in "${test_components[@]}"; do
        local found=false
        for loaded in "${loaded_components[@]}"; do
            if [[ "$loaded" == "$component" ]]; then
                found=true
                break
            fi
        done
        if [[ $found == false ]]; then
            echo "ERROR: Component '$component' not found in loaded selection"
            return 1
        fi
    done
    
    return 0
}

# Configuration Management Tests
#######################################

#######################################
# Test configuration defaults loading
# Returns:
#   0 on success, 1 on failure
#######################################
test_config_defaults_loading() {
    if ! declare -F load_config_defaults >/dev/null; then
        echo "ERROR: load_config_defaults function not found"
        return 1
    fi
    
    # Test loading defaults
    local defaults_file="${TEMP_TEST_DIR}/defaults.conf"
    cat > "$defaults_file" << 'EOF'
shell_theme=catppuccin-frappe
editor=nvim
git_user_name=Test User
git_user_email=test@example.com
dev_tools=minimal
EOF
    
    # Load defaults
    if ! load_config_defaults "$defaults_file"; then
        echo "ERROR: Failed to load config defaults"
        return 1
    fi
    
    # Verify defaults were loaded (check environment variables)
    if [[ "${CONFIG_SHELL_THEME:-}" != "catppuccin-frappe" ]] ||
       [[ "${CONFIG_EDITOR:-}" != "nvim" ]] ||
       [[ "${CONFIG_GIT_USER_NAME:-}" != "Test User" ]]; then
        echo "ERROR: Config defaults not properly loaded into environment"
        return 1
    fi
    
    return 0
}

#######################################
# Test user preference storage and recall
# Returns:
#   0 on success, 1 on failure
#######################################
test_user_preference_storage() {
    if ! declare -F save_user_preferences >/dev/null || 
       ! declare -F load_user_preferences >/dev/null; then
        echo "ERROR: User preference functions not found"
        return 1
    fi
    
    # Create test preferences
    local prefs_file="${TEMP_TEST_DIR}/user_prefs.conf"
    local -A test_prefs=(
        ["preferred_shell"]="zsh"
        ["color_scheme"]="dark"
        ["install_optional"]="true"
        ["skip_confirmation"]="false"
    )
    
    # Save preferences
    if ! save_user_preferences "$prefs_file" test_prefs; then
        echo "ERROR: Failed to save user preferences"
        return 1
    fi
    
    # Verify file was created
    if [[ ! -f "$prefs_file" ]]; then
        echo "ERROR: Preferences file was not created"
        return 1
    fi
    
    # Load preferences
    local -A loaded_prefs
    if ! load_user_preferences "$prefs_file" loaded_prefs; then
        echo "ERROR: Failed to load user preferences"
        return 1
    fi
    
    # Verify loaded preferences match saved preferences
    for key in "${!test_prefs[@]}"; do
        if [[ "${loaded_prefs[$key]:-}" != "${test_prefs[$key]}" ]]; then
            echo "ERROR: Preference '$key' value mismatch. Expected: '${test_prefs[$key]}', Got: '${loaded_prefs[$key]:-}'"
            return 1
        fi
    done
    
    return 0
}

# Skip/Resume Functionality Tests
#######################################

#######################################
# Test installation state tracking
# Returns:
#   0 on success, 1 on failure
#######################################
test_installation_state_tracking() {
    if ! declare -F mark_component_completed >/dev/null || 
       ! declare -F is_component_completed >/dev/null ||
       ! declare -F get_incomplete_components >/dev/null; then
        echo "ERROR: Installation state tracking functions not found"
        return 1
    fi
    
    local state_dir="${TEMP_TEST_DIR}/install_state"
    mkdir -p "$state_dir"
    export SETUP_STATE_DIR="$state_dir"
    
    # Test marking components as completed
    local test_components=("shell" "git" "editor" "dev_tools")
    for component in "${test_components[@]}"; do
        if ! mark_component_completed "$component"; then
            echo "ERROR: Failed to mark component '$component' as completed"
            return 1
        fi
    done
    
    # Test checking completion status
    for component in "${test_components[@]}"; do
        if ! is_component_completed "$component"; then
            echo "ERROR: Component '$component' not marked as completed"
            return 1
        fi
    done
    
    # Test incomplete component detection
    local all_components=("shell" "git" "editor" "dev_tools" "optional" "extra")
    local -a incomplete_components
    if ! mapfile -t incomplete_components < <(get_incomplete_components all_components); then
        echo "ERROR: Failed to get incomplete components"
        return 1
    fi
    
    # Should have 2 incomplete components (optional, extra)
    if [[ ${#incomplete_components[@]} -ne 2 ]]; then
        echo "ERROR: Expected 2 incomplete components, got ${#incomplete_components[@]}"
        return 1
    fi
    
    # Verify the incomplete components are correct
    local expected_incomplete=("optional" "extra")
    for expected in "${expected_incomplete[@]}"; do
        local found=false
        for incomplete in "${incomplete_components[@]}"; do
            if [[ "$incomplete" == "$expected" ]]; then
                found=true
                break
            fi
        done
        if [[ $found == false ]]; then
            echo "ERROR: Expected incomplete component '$expected' not found"
            return 1
        fi
    done
    
    return 0
}

#######################################
# Test resume functionality
# Returns:
#   0 on success, 1 on failure
#######################################
test_resume_functionality() {
    if ! declare -F save_installation_checkpoint >/dev/null || 
       ! declare -F load_installation_checkpoint >/dev/null ||
       ! declare -F can_resume_installation >/dev/null; then
        echo "ERROR: Resume functionality functions not found"
        return 1
    fi
    
    local checkpoint_file="${TEMP_TEST_DIR}/checkpoint.conf"
    
    # Create test checkpoint data
    local -A checkpoint_data=(
        ["current_step"]="3"
        ["total_steps"]="5"
        ["completed_components"]="shell,git"
        ["current_component"]="editor"
        ["installation_mode"]="interactive"
        ["timestamp"]="$(date -Iseconds)"
    )
    
    # Save checkpoint
    if ! save_installation_checkpoint "$checkpoint_file" checkpoint_data; then
        echo "ERROR: Failed to save installation checkpoint"
        return 1
    fi
    
    # Verify checkpoint file exists
    if [[ ! -f "$checkpoint_file" ]]; then
        echo "ERROR: Checkpoint file was not created"
        return 1
    fi
    
    # Test if we can resume
    if ! can_resume_installation "$checkpoint_file"; then
        echo "ERROR: Cannot resume installation with valid checkpoint"
        return 1
    fi
    
    # Load checkpoint
    local -A loaded_checkpoint
    if ! load_installation_checkpoint "$checkpoint_file" loaded_checkpoint; then
        echo "ERROR: Failed to load installation checkpoint"
        return 1
    fi
    
    # Verify loaded checkpoint data
    for key in "${!checkpoint_data[@]}"; do
        if [[ "${loaded_checkpoint[$key]:-}" != "${checkpoint_data[$key]}" ]]; then
            echo "ERROR: Checkpoint '$key' value mismatch. Expected: '${checkpoint_data[$key]}', Got: '${loaded_checkpoint[$key]:-}'"
            return 1
        fi
    done
    
    return 0
}

# Test Environment Setup and Cleanup
#######################################

#######################################
# Set up test environment with necessary directories and files
#######################################
setup_test_environment() {
    mkdir -p "${TEMP_TEST_DIR}/config"
    mkdir -p "${TEMP_TEST_DIR}/logs"
    mkdir -p "${TEMP_TEST_DIR}/state"
    export TEST_MODE="true"
    export TEST_DIR="$TEMP_TEST_DIR"
    export SETUP_CONFIG_DIR="${TEMP_TEST_DIR}/config"
    export SETUP_LOG_DIR="${TEMP_TEST_DIR}/logs"
    export SETUP_STATE_DIR="${TEMP_TEST_DIR}/state"
}

#######################################
# Clean up test environment
#######################################
cleanup_test_environment() {
    if [[ -n "${TEMP_TEST_DIR:-}" && -d "$TEMP_TEST_DIR" ]]; then
        rm -rf "$TEMP_TEST_DIR"
    fi
    unset TEST_MODE TEST_DIR SETUP_CONFIG_DIR SETUP_LOG_DIR SETUP_STATE_DIR
    unset CONFIG_SHELL_THEME CONFIG_EDITOR CONFIG_GIT_USER_NAME CONFIG_GIT_USER_EMAIL CONFIG_DEV_TOOLS
}

# Main test runner
#######################################
main() {
    echo "🚀 Starting Interactive Configuration System Tests"
    echo "=================================================="
    
    setup_test_environment
    trap cleanup_test_environment EXIT
    
    # Test array with descriptions and function names
    local -a tests=(
        "Menu Display:test_menu_display"
        "Menu Option Validation:test_menu_option_validation"
        "Component Selection Menu:test_component_selection_menu"
        "User Confirmation Validation:test_user_confirmation_validation"
        "Config Key Validation:test_config_key_validation"
        "Component Category Validation:test_component_category_validation"
        "Component Selection Persistence:test_component_selection_persistence"
        "Config Defaults Loading:test_config_defaults_loading"
        "User Preference Storage:test_user_preference_storage"
        "Installation State Tracking:test_installation_state_tracking"
        "Resume Functionality:test_resume_functionality"
    )
    
    # Execute all tests
    for test in "${tests[@]}"; do
        IFS=':' read -r test_name test_function <<< "$test"
        run_test "$test_name" "$test_function"
        echo ""
    done
    
    # Summary reporting
    echo "📊 Interactive Configuration System Test Results:"
    echo "  ✅ Passed: $TESTS_PASSED"
    echo "  ❌ Failed: $TESTS_FAILED"
    echo "  📝 Total:  $((TESTS_PASSED + TESTS_FAILED))"
    echo ""
    
    if [[ $TESTS_FAILED -eq 0 ]]; then
        echo "🎉 All tests passed successfully!"
        return 0
    else
        echo "❌ Some tests failed. Please review and fix issues."
        return 1
    fi
}

# Execute only when run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
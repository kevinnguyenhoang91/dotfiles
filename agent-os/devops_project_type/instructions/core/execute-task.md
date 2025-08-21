---
description: Rules to execute a DevOps engineering task and its sub-tasks using Agent OS
globs:
alwaysApply: false
version: 1.0
encoding: UTF-8
---

# DevOps Task Execution Rules

## Overview

Execute a specific DevOps engineering task and its sub-tasks systematically, following a test-driven development (TDD) workflow for infrastructure, automation, and operational reliability.

<pre_flight_check>
  EXECUTE: @.agent-os/instructions/meta/pre-flight.md
</pre_flight_check>

<process_flow>

<step number="1" name="task_understanding">

### Step 1: Task Understanding

Read and analyze the given parent DevOps task and all its sub-tasks from tasks.md to gain complete understanding of what needs to be built or automated.

<task_analysis>
  <read_from_tasks_md>
    - Parent DevOps task description
    - All sub-task descriptions
    - Task dependencies (e.g., environment, pipeline, infra)
    - Expected outcomes (e.g., deployment, monitoring, automation)
  </read_from_tasks_md>
</task_analysis>

<instructions>
  ACTION: Read the specific parent DevOps task and all its sub-tasks
  ANALYZE: Full scope of implementation required (e.g., CI/CD, infra-as-code, monitoring)
  UNDERSTAND: Dependencies and expected deliverables
  NOTE: Test/validation requirements for each sub-task
</instructions>

</step>

<step number="2" name="technical_spec_review">

### Step 2: Technical Specification Review

Search and extract relevant sections from technical-spec.md to understand the technical implementation approach for this DevOps task.

<selective_reading>
  <search_technical_spec>
    FIND sections in technical-spec.md related to:
    - Current DevOps task functionality (e.g., pipeline, infra, automation)
    - Implementation approach for this feature
    - Integration requirements (e.g., cloud, tools, APIs)
    - Performance, reliability, and security criteria
  </search_technical_spec>
</selective_reading>

<instructions>
  ACTION: Search technical-spec.md for DevOps task-relevant sections
  EXTRACT: Only implementation details for current DevOps task
  SKIP: Unrelated technical specifications
  FOCUS: Technical approach for this specific DevOps feature
</instructions>

</step>

<step number="3" subagent="context-fetcher" name="best_practices_review">

### Step 3: Best Practices Review

Use the context-fetcher subagent to retrieve relevant sections from @.agent-os/standards/best-practices.md that apply to the current DevOps technology stack and feature type.

<selective_reading>
  <search_best_practices>
    FIND sections relevant to:
    - DevOps technology stack (e.g., Terraform, Ansible, Docker, Kubernetes, CI/CD tools)
    - Feature type being implemented (e.g., pipeline, infra-as-code, monitoring)
    - Testing/validation approaches needed (e.g., pipeline tests, infra tests)
    - Code and configuration organization patterns
  </search_best_practices>
</selective_reading>

<instructions>
  ACTION: Use context-fetcher subagent
  REQUEST: "Find best practices sections relevant to:
            - DevOps technology stack: [CURRENT_TECH]
            - Feature type: [CURRENT_FEATURE_TYPE]
            - Testing/validation approaches needed
            - Code/config organization patterns"
  PROCESS: Returned best practices
  APPLY: Relevant patterns to implementation
</instructions>

</step>

<step number="4" subagent="context-fetcher" name="code_style_review">

### Step 4: Code Style Review

Use the context-fetcher subagent to retrieve relevant code style rules from @.agent-os/standards/code-style.md for the languages, configuration formats, and file types being used in this DevOps task.

<selective_reading>
  <search_code_style>
    FIND style rules for:
    - Languages/configs used in this task (e.g., YAML, HCL, Bash, Python)
    - File types being modified (e.g., pipeline configs, infra code, scripts)
    - Component patterns being implemented (e.g., modules, playbooks, manifests)
    - Testing/validation style guidelines
  </search_code_style>
</selective_reading>

<instructions>
  ACTION: Use context-fetcher subagent
  REQUEST: "Find code style rules for:
            - Languages/configs: [LANGUAGES_IN_TASK]
            - File types: [FILE_TYPES_BEING_MODIFIED]
            - Component patterns: [PATTERNS_BEING_IMPLEMENTED]
            - Testing/validation style guidelines"
  PROCESS: Returned style rules
  APPLY: Relevant formatting and patterns
</instructions>

</step>

<step number="5" name="task_execution">

### Step 5: Task and Sub-task Execution

Execute the parent DevOps task and all sub-tasks in order using test-driven development (TDD) for infrastructure, automation, and operational validation.

<typical_task_structure>
  <first_subtask>Write tests/validation for [DevOps feature]</first_subtask>
  <middle_subtasks>Implementation steps (e.g., pipeline, infra, automation)</middle_subtasks>
  <final_subtask>Verify all tests/validations pass</final_subtask>
</typical_task_structure>

<execution_order>
  <subtask_1_tests>
    IF sub-task 1 is "Write tests/validation for [DevOps feature]":
      - Write all tests/validation scripts for the parent feature (e.g., pipeline, infra, monitoring)
      - Include unit tests, integration tests, operational checks, edge cases
      - Run tests/validations to ensure they fail appropriately
      - Mark sub-task 1 complete
  </subtask_1_tests>

  <middle_subtasks_implementation>
    FOR each implementation sub-task (2 through n-1):
      - Implement the specific DevOps functionality (e.g., pipeline config, infra code, automation script)
      - Make relevant tests/validations pass
      - Update any adjacent/related tests/validations if needed
      - Refactor while keeping tests/validations green
      - Mark sub-task complete
  </middle_subtasks_implementation>

  <final_subtask_verification>
    IF final sub-task is "Verify all tests/validations pass":
      - Run entire test/validation suite for this feature
      - Fix any remaining failures
      - Ensure no regressions
      - Mark final sub-task complete
  </final_subtask_verification>
</execution_order>

<test_management>
  <new_tests>
    - Written in first sub-task
    - Cover all aspects of parent DevOps feature (e.g., deployment, rollback, monitoring)
    - Include edge cases and error handling
  </new_tests>
  <test_updates>
    - Made during implementation sub-tasks
    - Update expectations for changed behavior
    - Maintain backward compatibility
  </test_updates>
</test_management>

<instructions>
  ACTION: Execute sub-tasks in their defined order
  RECOGNIZE: First sub-task typically writes all tests/validations
  IMPLEMENT: Middle sub-tasks build functionality
  VERIFY: Final sub-task ensures all tests/validations pass
  UPDATE: Mark each sub-task complete as finished
</instructions>

</step>

<step number="6" subagent="test-runner" name="task_test_verification">

### Step 6: Task-Specific Test/Validation Verification

Use the test-runner subagent to run and verify only the tests/validations specific to this parent DevOps task (not the full test suite) to ensure the feature is working correctly.

<focused_test_execution>
  <run_only>
    - All new tests/validations written for this parent DevOps task
    - All tests/validations updated during this task
    - Tests/validations directly related to this feature
  </run_only>
  <skip>
    - Full test/validation suite (done later in execute-tasks.md)
    - Unrelated test/validation files
  </skip>
</focused_test_execution>

<final_verification>
  IF any test/validation failures:
    - Debug and fix the specific issue
    - Re-run only the failed tests/validations
  ELSE:
    - Confirm all task tests/validations passing
    - Ready to proceed
</final_verification>

<instructions>
  ACTION: Use test-runner subagent
  REQUEST: "Run tests/validations for [this parent DevOps task's test files]"
  WAIT: For test-runner analysis
  PROCESS: Returned failure information
  VERIFY: 100% pass rate for task-specific tests/validations
  CONFIRM: This feature's tests/validations are complete
</instructions>

</step>

<step number="7" name="task_status_updates">

### Step 7: Mark this DevOps task and sub-tasks complete

IMPORTANT: In the tasks.md file, mark this DevOps task and its sub-tasks complete by updating each task checkbox to [x].

<update_format>
  <completed>- [x] DevOps Task description</completed>
  <incomplete>- [ ] DevOps Task description</incomplete>
  <blocked>
    - [ ] DevOps Task description
    ⚠️ Blocking issue: [DESCRIPTION]
  </blocked>
</update_format>

<blocking_criteria>
  <attempts>maximum 3 different approaches</attempts>
  <action>document blocking issue</action>
  <emoji>⚠️</emoji>
</blocking_criteria>

<instructions>
  ACTION: Update tasks.md after each DevOps task completion
  MARK: [x] for completed items immediately
  DOCUMENT: Blocking issues with ⚠️ emoji
  LIMIT: 3 attempts before marking as blocked
</instructions>

</step>

</process_flow>

<post_flight_check>
  EXECUTE: @.agent-os/instructions/meta/post-flight.md
</post_flight_check>
</post_flight_check>

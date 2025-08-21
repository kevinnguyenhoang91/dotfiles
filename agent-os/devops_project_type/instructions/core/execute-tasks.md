---
description: Rules to initiate execution of a set of DevOps engineering tasks using Agent OS
globs:
alwaysApply: false
version: 1.0
encoding: UTF-8
---

# DevOps Task Execution Rules

## Overview

Initiate execution of one or more DevOps engineering tasks for a given project specification.

<pre_flight_check>
  EXECUTE: @.agent-os/instructions/meta/pre-flight.md
</pre_flight_check>

<process_flow>

<step number="1" name="task_assignment">

### Step 1: Task Assignment

Identify which DevOps tasks to execute from the spec (using spec_srd_reference file path and optional specific_tasks array), defaulting to the next uncompleted parent task if not specified. Typical tasks include CI/CD pipeline setup, infrastructure provisioning, environment configuration, monitoring integration, and automation scripting.

<task_selection>
  <explicit>user specifies exact DevOps task(s) (e.g., "setup CI pipeline", "deploy staging environment")</explicit>
  <implicit>find next uncompleted DevOps task in tasks.md</implicit>
</task_selection>

<instructions>
  ACTION: Identify DevOps task(s) to execute
  DEFAULT: Select next uncompleted parent DevOps task if not specified
  CONFIRM: Task selection with user
</instructions>

</step>

<step number="2" subagent="context-fetcher" name="context_analysis">

### Step 2: Context Analysis

Use the context-fetcher subagent to gather minimal context for DevOps task understanding by always loading spec tasks.md, and conditionally loading @.agent-os/product/mission-lite.md, spec-lite.md, and sub-specs/technical-spec.md if not already in context. Focus on environment requirements, infrastructure details, deployment targets, and automation needs.

<instructions>
  ACTION: Use context-fetcher subagent to:
    - REQUEST: "Get product pitch from mission-lite.md"
    - REQUEST: "Get spec summary from spec-lite.md"
    - REQUEST: "Get infrastructure and deployment details from technical-spec.md"
  PROCESS: Returned information
</instructions>

<context_gathering>
  <essential_docs>
    - tasks.md for DevOps task breakdown
  </essential_docs>
  <conditional_docs>
    - mission-lite.md for product alignment
    - spec-lite.md for feature summary
    - technical-spec.md for infrastructure and deployment details
  </conditional_docs>
</context_gathering>

</step>

<step number="3" name="environment_server_check">

### Step 3: Check for Running Environments

Check for any running development, staging, or production environments and ask user permission to shut down or redeploy if found to prevent conflicts (e.g., port, resource, or deployment collisions).

<server_check_flow>
  <if_running>
    ASK user to shut down or redeploy
    WAIT for response
  </if_running>
  <if_not_running>
    PROCEED immediately
  </if_not_running>
</server_check_flow>

<user_prompt>
  An environment (development/staging/production) is currently running.
  Should I shut it down or redeploy before proceeding? (yes/no)
</user_prompt>

<instructions>
  ACTION: Check for running environments or services
  CONDITIONAL: Ask permission only if environment is running
  PROCEED: Immediately if no environment detected
</instructions>

</step>

<step number="4" subagent="git-workflow" name="git_branch_management">

### Step 4: Git Branch Management

Use the git-workflow subagent to manage git branches to ensure proper isolation by creating or switching to the appropriate branch for the DevOps spec. This ensures infrastructure-as-code changes, pipeline configs, and automation scripts are tracked and isolated.

<instructions>
  ACTION: Use git-workflow subagent
  REQUEST: "Check and manage branch for spec: [SPEC_FOLDER]
            - Create branch if needed
            - Switch to correct branch
            - Handle any uncommitted changes"
  WAIT: For branch setup completion
</instructions>

<branch_naming>
  <source>spec folder name</source>
  <format>exclude date prefix</format>
  <example>
    - folder: 2025-03-15-ci-pipeline
    - branch: ci-pipeline
  </example>
</branch_naming>

</step>

<step number="5" name="task_execution_loop">

### Step 5: DevOps Task Execution Loop

Execute all assigned parent DevOps tasks and their subtasks using @.agent-os/instructions/core/execute-task.md instructions, continuing until all tasks are complete. Typical tasks include provisioning infrastructure, configuring CI/CD, deploying environments, and setting up monitoring.

<execution_flow>
  LOAD @.agent-os/instructions/core/execute-task.md ONCE

  FOR each parent_task assigned in Step 1:
    EXECUTE instructions from execute-task.md with:
      - parent_task_number
      - all associated subtasks
    WAIT for task completion
    UPDATE tasks.md status
  END FOR
</execution_flow>

<loop_logic>
  <continue_conditions>
    - More unfinished parent DevOps tasks exist
    - User has not requested stop
  </continue_conditions>
  <exit_conditions>
    - All assigned DevOps tasks marked complete
    - User requests early termination
    - Blocking issue prevents continuation
  </exit_conditions>
</loop_logic>

<task_status_check>
  AFTER each task execution:
    CHECK tasks.md for remaining DevOps tasks
    IF all assigned tasks complete:
      PROCEED to next step
    ELSE:
      CONTINUE with next task
</task_status_check>

<instructions>
  ACTION: Load execute-task.md instructions once at start
  REUSE: Same instructions for each parent DevOps task iteration
  LOOP: Through all assigned parent DevOps tasks
  UPDATE: Task status after each completion
  VERIFY: All DevOps tasks complete before proceeding
  HANDLE: Blocking issues appropriately
</instructions>

</step>

<step number="6" name="complete_tasks">

### Step 6: Run the DevOps task completion steps

After all DevOps tasks in tasks.md have been implemented, use @.agent-os/instructions/core/complete-tasks.md to run our series of steps we always run when finishing and delivering a new infrastructure or automation feature.

<instructions>
  LOAD: @.agent-os/instructions/core/complete-tasks.md once
  ACTION: execute all steps in the complete-tasks.md process_flow.
</instructions>

</step>

</process_flow>

<post_flight_check>
  EXECUTE: @.agent-os/instructions/meta/post-flight.md
</post_flight_check>
</post_flight_check>

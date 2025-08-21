---
description: Create an Agent OS DevOps tasks list from an approved feature spec
globs:
alwaysApply: false
version: 1.1
encoding: UTF-8
---

# DevOps Spec Creation Rules

## Overview

With the user's approval, proceed to creating a DevOps-focused tasks list based on the current feature spec.

<pre_flight_check>
  EXECUTE: @.agent-os/instructions/meta/pre-flight.md
</pre_flight_check>

<process_flow>

<step number="1" subagent="file-creator" name="create_tasks">

### Step 1: Create tasks.md

Use the file-creator subagent to create file: tasks.md inside of the current feature's spec folder.

<file_template>
  <header>
    # DevOps Spec Tasks
  </header>
</file_template>

<task_structure>
  <major_tasks>
    - count: 1-5
    - format: numbered checklist
    - grouping: by infrastructure component, CI/CD pipeline, monitoring, or automation feature
  </major_tasks>
  <subtasks>
    - count: up to 8 per major task
    - format: decimal notation (1.1, 1.2)
    - first_subtask: typically write infrastructure tests or pipeline validation
    - last_subtask: verify all tests and deployments pass
  </subtasks>
</task_structure>

<task_template>
  ## Tasks

  - [ ] 1. [MAJOR_TASK_DESCRIPTION]
    - [ ] 1.1 Write tests/validation for [INFRA/PIPELINE_COMPONENT]
    - [ ] 1.2 [IMPLEMENTATION_STEP] (e.g., provision infrastructure, configure CI/CD)
    - [ ] 1.3 [IMPLEMENTATION_STEP] (e.g., automate deployment, set up monitoring)
    - [ ] 1.4 Verify all tests and deployments pass

  - [ ] 2. [MAJOR_TASK_DESCRIPTION]
    - [ ] 2.1 Write tests/validation for [INFRA/PIPELINE_COMPONENT]
    - [ ] 2.2 [IMPLEMENTATION_STEP]
</task_template>

<ordering_principles>
  - Consider technical dependencies (e.g., infrastructure before deployment)
  - Follow TDD and Infrastructure as Code approach
  - Group related DevOps functionality
  - Build incrementally and automate wherever possible
</ordering_principles>

</step>

<step number="2" name="execution_readiness">

### Step 2: Execution Readiness Check

Evaluate readiness to begin implementation by presenting the first DevOps task summary and requesting user confirmation to proceed.

<readiness_summary>
  <present_to_user>
    - Spec name and description
    - First DevOps task summary from tasks.md
    - Estimated complexity/scope
    - Key deliverables for DevOps task 1
  </present_to_user>
</readiness_summary>

<execution_prompt>
  PROMPT: "The DevOps spec planning is complete. The first task is:

  **Task 1:** [FIRST_TASK_TITLE]
  [BRIEF_DESCRIPTION_OF_TASK_1_AND_SUBTASKS]

  Would you like me to proceed with implementing Task 1? I will focus only on this first DevOps task and its subtasks unless you specify otherwise.

  Type 'yes' to proceed with Task 1, or let me know if you'd like to review or modify the plan first."
</execution_prompt>

<execution_flow>
  IF user_confirms_yes:
    REFERENCE: @.agent-os/instructions/core/execute-tasks.md
    FOCUS: Only Task 1 and its subtasks
    CONSTRAINT: Do not proceed to additional tasks without explicit user request
  ELSE:
    WAIT: For user clarification or modifications
</execution_flow>

</step>

</process_flow>

<post_flight_check>
  EXECUTE: @.agent-os/instructions/meta/post-flight.md
</post_flight_check>

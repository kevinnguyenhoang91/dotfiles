---
description: Analyze Current Product & Install Agent OS (DevOps Focus)
globs:
alwaysApply: false
version: 1.0
encoding: UTF-8
---

# Analyze Current Product & Install Agent OS (DevOps Engineer Edition)

## Overview

Install Agent OS into an existing codebase, analyze current product state and operational readiness.  Builds on plan-product.md

<pre_flight_check>
  EXECUTE: @.agent-os/instructions/meta/pre-flight.md
</pre_flight_check>

<process_flow>

<step number="1" name="analyze_existing_codebase">

### Step 1: Analyze Existing Codebase & Infrastructure

Perform a deep analysis of the codebase and infrastructure to understand current operational state before documentation.

<analysis_areas>
  <project_structure>
    - Directory organization
    - File naming patterns
    - Module structure
    - Build configuration
    - Infrastructure as Code (IaC) files (Terraform, Ansible, etc.)
  </project_structure>
  <technology_stack>
    - Frameworks in use
    - Dependencies (package.json, Gemfile, requirements.txt, etc.)
    - Database systems
    - Infrastructure configuration (cloud providers, containers, orchestration)
    - CI/CD pipelines (GitHub Actions, Jenkins, etc.)
    - Monitoring & logging tools
  </technology_stack>
  <implementation_progress>
    - Deployed environments (dev, staging, prod)
    - Completed automation scripts
    - Security & compliance state
    - API endpoints
    - Database schema
  </implementation_progress>
  <code_patterns>
    - Coding style in use
    - Naming conventions
    - File organization patterns
    - Testing & deployment approach
  </code_patterns>
</analysis_areas>

<instructions>
  ACTION: Thoroughly analyze the codebase and infrastructure
  DOCUMENT: Technologies, deployment, automation, and monitoring setup
  IDENTIFY: Architectural and operational decisions already made
  NOTE: DevOps progress and completed work
</instructions>

</step>

<step number="2" subagent="context-fetcher" name="gather_product_context">

### Step 2: Gather Product & Operational Context

Use the context-fetcher subagent to supplement analysis with business, operational, and future plans.

<context_questions>
  Based on my analysis of your codebase and infrastructure, I can see you're building [OBSERVED_PRODUCT_TYPE].

  To properly set up Agent OS for DevOps, I need to understand:

  1. **Product Vision**: What problem does this solve? Who are the target users?
  2. **Operational Requirements**: Uptime, scalability, compliance, security needs?
  3. **Current State**: Any features or infrastructure not obvious from the code?
  4. **Roadmap**: Planned features, infrastructure changes, or major refactoring?
  5. **Team Preferences**: Coding, deployment, and operational standards I should capture?
</context_questions>

<instructions>
  ACTION: Ask user for product and operational context
  COMBINE: Merge user input with codebase/infrastructure analysis
  PREPARE: Information for plan-product.md execution
</instructions>

</step>

<step number="3" name="execute_plan_product">

### Step 3: Execute Plan-Product with DevOps Context

Execute our standard flow for installing Agent OS in existing products, with DevOps context.

<execution_parameters>
  <main_idea>[DERIVED_FROM_ANALYSIS_AND_USER_INPUT]</main_idea>
  <key_features>[IDENTIFIED_IMPLEMENTED_AND_PLANNED_FEATURES]</key_features>
  <target_users>[FROM_USER_CONTEXT]</target_users>
  <tech_stack>[DETECTED_FROM_CODEBASE_AND_INFRA]</tech_stack>
  <operational_stack>[CI/CD, monitoring, deployment, security]</operational_stack>
</execution_parameters>

<execution_prompt>
  @.agent-os/instructions/core/plan-product.md

  I'm installing Agent OS into an existing product. Here's what I've gathered:

  **Main Idea**: [SUMMARY_FROM_ANALYSIS_AND_CONTEXT]

  **Key Features**:
  - Already Implemented: [LIST_FROM_ANALYSIS]
  - Planned: [LIST_FROM_USER]

  **Target Users**: [FROM_USER_RESPONSE]

  **Tech Stack**: [DETECTED_STACK_WITH_VERSIONS]
  **Operational Stack**: [CI/CD, monitoring, deployment, security tools]
</execution_prompt>

<instructions>
  ACTION: Execute plan-product.md with gathered information
  PROVIDE: All context as structured input
  ALLOW: plan-product.md to create .agent-os/product/ structure
</instructions>

</step>

<step number="4" name="customize_generated_files">

### Step 4: Customize Generated Documentation

Refine generated documentation to ensure accuracy for the existing product and infrastructure by updating roadmap, tech stack, and operational decisions.

<customization_tasks>
  <roadmap_adjustment>
    - Mark completed features and infrastructure as done
    - Move implemented items to "Phase 0: Already Completed"
    - Adjust future phases based on actual progress
  </roadmap_adjustment>
  <tech_stack_verification>
    - Verify detected versions and infrastructure details
    - Add missing deployment, CI/CD, monitoring, and security info
    - Document actual operational setup
  </tech_stack_verification>
</customization_tasks>

<roadmap_template>
  ## Phase 0: Already Completed

  The following features and infrastructure have been implemented:

  - [x] [FEATURE_1] - [DESCRIPTION_FROM_CODE]
  - [x] [CI/CD Pipeline] - [DESCRIPTION]
  - [x] [Monitoring Setup] - [DESCRIPTION]

  ## Phase 1: Current Development

  - [ ] [IN_PROGRESS_FEATURE] - [DESCRIPTION]

  [CONTINUE_WITH_STANDARD_PHASES]
</roadmap_template>

</step>

<step number="5" name="final_verification">

### Step 5: Final Verification and Summary

Verify installation completeness and provide clear next steps for the user to start using Agent OS with their codebase and infrastructure.

<verification_checklist>
  - [ ] .agent-os/product/ directory created
  - [ ] Product documentation reflects codebase and infrastructure
  - [ ] Roadmap shows completed and planned features/infrastructure accurately
  - [ ] Tech and operational stack matches installed dependencies and setup
</verification_checklist>

<summary_template>
  ## ✅ Agent OS Successfully Installed (DevOps Edition)

  I've analyzed your [PRODUCT_TYPE] codebase and infrastructure, and set up Agent OS with documentation that reflects your actual implementation and operational setup.

  ### What I Found

  - **Tech Stack**: [SUMMARY_OF_DETECTED_STACK]
  - **Operational Stack**: [CI/CD, monitoring, deployment, security]
  - **Completed Features**: [COUNT] features and infrastructure already implemented
  - **Code & Infra Style**: [DETECTED_PATTERNS]
  - **Current Phase**: [IDENTIFIED_DEVELOPMENT_STAGE]

  ### What Was Created

  - ✓ Product documentation in `.agent-os/product/`
  - ✓ Roadmap with completed work in Phase 0
  - ✓ Tech and operational stack reflecting actual dependencies and setup

  ### Next Steps

  1. Review the generated documentation in `.agent-os/product/`
  2. Make any necessary adjustments to reflect your vision and operational needs
  3. See the Agent OS README for usage instructions: https://github.com/buildermethods/agent-os
  4. Start using Agent OS for your next feature or infrastructure improvement:
     ```
     @.agent-os/instructions/core/create-spec.md
     ```

  Your codebase and infrastructure are now Agent OS-enabled! 🚀
</summary_template>

</step>

</process_flow>

<post_flight_check>
  EXECUTE: @.agent-os/instructions/meta/post-flight.md
</post_flight_check>

# DevOps Code Style Guide

## Context

Global code style rules for Agent OS DevOps engineering projects.

<conditional-block context-check="general-formatting">
IF this General Formatting section already read in current context:
  SKIP: Re-reading this section
  NOTE: "Using General Formatting rules already in context"
ELSE:
  READ: The following formatting rules

## General Formatting

### Indentation
- Use 2 spaces for indentation (never tabs)
- Maintain consistent indentation throughout scripts, config files, and manifests
- Align nested structures for readability (e.g., YAML, JSON, shell scripts)

### Naming Conventions
- **Scripts and Variables**: Use snake_case (e.g., `deploy_app`, `backup_database`)
- **Resources and Modules**: Use PascalCase (e.g., `AppServer`, `DatabaseBackup`)
- **Constants and Environment Variables**: Use UPPER_SNAKE_CASE (e.g., `MAX_RETRY_COUNT`, `DB_HOST`)

### String Formatting
- Use single quotes for strings in shell scripts: `'Hello World'`
- Use double quotes only when interpolation is needed
- Use template literals or heredocs for multi-line strings or complex interpolation (where supported)

### Code Comments
- Add brief comments above non-obvious automation logic or infrastructure steps
- Document complex deployment flows or configuration logic
- Explain the "why" behind implementation choices, especially for infrastructure-as-code
- Never remove existing comments unless removing the associated code
- Update comments when modifying code to maintain accuracy
- Keep comments concise and relevant
</conditional-block>

<conditional-block task-condition="html-css-tailwind" context-check="html-css-style">
IF current task involves writing or updating HTML, CSS, or TailwindCSS (e.g., for dashboards or UIs in DevOps tools):
  IF html-style.md AND css-style.md already in context:
    SKIP: Re-reading these files
    NOTE: "Using HTML/CSS style guides already in context"
  ELSE:
    <context_fetcher_strategy>
      IF current agent is Claude Code AND context-fetcher agent exists:
        USE: @agent:context-fetcher
        REQUEST: "Get HTML formatting rules from code-style/html-style.md"
        REQUEST: "Get CSS and TailwindCSS rules from code-style/css-style.md"
        PROCESS: Returned style rules
      ELSE:
        READ the following style guides (only if not already in context):
        - @.agent-os/standards/code-style/html-style.md (if not in context)
        - @.agent-os/standards/code-style/css-style.md (if not in context)
    </context_fetcher_strategy>
ELSE:
  SKIP: HTML/CSS style guides not relevant to current DevOps task
</conditional-block>

<conditional-block task-condition="javascript" context-check="javascript-style">
IF current task involves writing or updating JavaScript (e.g., for DevOps automation, dashboards, or CLI tools):
  IF javascript-style.md already in context:
    SKIP: Re-reading this file
    NOTE: "Using JavaScript style guide already in context"
  ELSE:
    <context_fetcher_strategy>
      IF current agent is Claude Code AND context-fetcher agent exists:
        USE: @agent:context-fetcher
        REQUEST: "Get JavaScript style rules from code-style/javascript-style.md"
        PROCESS: Returned style rules
      ELSE:
        READ: @.agent-os/standards/code-style/javascript-style.md
    </context_fetcher_strategy>
ELSE:
  SKIP: JavaScript style guide not relevant to current DevOps task
</conditional-block>

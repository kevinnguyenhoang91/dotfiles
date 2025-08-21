# DevOps Engineering Best Practices

## Context

Global DevOps guidelines for Agent OS projects.

<conditional-block context-check="core-principles">
IF this Core Principles section already read in current context:
  SKIP: Re-reading this section
  NOTE: "Using Core Principles already in context"
ELSE:
  READ: The following principles

## Core Principles

### Automate Everything
- Automate repetitive tasks using scripts and CI/CD pipelines
- Use Infrastructure as Code (IaC) for provisioning and configuration
- Prefer declarative over imperative automation

### Optimize for Reliability
- Design systems for fault tolerance and high availability
- Implement monitoring, alerting, and logging for all critical components
- Test disaster recovery and rollback procedures regularly

### Keep It Simple and Maintainable
- Use clear, modular scripts and configuration files
- Avoid unnecessary complexity in automation and infrastructure
- Document operational procedures and automation logic

### DRY (Don't Repeat Yourself)
- Reuse automation modules and templates
- Centralize common configuration and secrets management
- Create shared libraries for frequent DevOps tasks

### File Structure
- Organize scripts, manifests, and configs by environment and responsibility
- Use consistent naming conventions for resources and files
- Separate infrastructure, application, and operational code

### Version Control
- Use Git for version control of all code and configuration
- Follow a branching strategy (e.g., GitFlow) for feature development and releases
- Include clear commit messages and pull request descriptions

### Documentation
- Maintain up-to-date documentation for all scripts and processes
- Use README files to explain the purpose and usage of each module
- Include examples and use cases in documentation
</conditional-block>

<conditional-block context-check="dependencies" task-condition="choosing-external-library">
IF current task involves choosing an external library or tool:
  IF Dependencies section already read in current context:
    SKIP: Re-reading this section
    NOTE: "Using Dependencies guidelines already in context"
  ELSE:
    READ: The following guidelines
ELSE:
  SKIP: Dependencies section not relevant to current task

## Dependencies

### Choose Tools and Libraries Wisely
When adding third-party DevOps tools or libraries:
- Select popular, actively maintained, and well-documented options
- Check the tool's repository for:
  - Recent updates and active community support
  - Issue resolution and security advisories
  - Number of stars/downloads and adoption in industry
  - Clear documentation and usage examples
</conditional-block>

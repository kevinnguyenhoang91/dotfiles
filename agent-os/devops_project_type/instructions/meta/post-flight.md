---
description: DevOps Engineer Post-Flight Steps for Agent OS Instructions
globs:
alwaysApply: false
version: 1.0
encoding: UTF-8
---

# Post-Flight Rules for DevOps Engineers

After completing all steps in a process_flow, always review your work and verify:

- Every numbered step has read, executed, and delivered according to its instructions.

- All steps that specified a subagent should be used, did in fact delegate those tasks to the specified subagent.  IF they did not, see why the subagent was not used and report your findings to the user.

- IF you notice a step wasn't executed according to it's instructions, report your findings and explain which part of the instructions were misread or skipped and why.

- Verify all services are running and healthy.

- Confirm successful deployment and rollback capability.

- Review logs for errors or warnings post-deployment.

- Ensure backup and recovery procedures are validated.

- Document any changes made during the deployment.

- Update runbooks and operational documentation as needed.

- Schedule a post-mortem or review if incidents occurred.

- Clean up temporary resources and validate environment stability.

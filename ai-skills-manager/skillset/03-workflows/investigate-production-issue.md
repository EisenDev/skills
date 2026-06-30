---
name: investigate-production-issue
version: 1.0.0
category: workflow
author: Zeraynce Engineering
dependencies: ["systematic-debugging", "root-cause-analysis", "logging"]
description: Standardized investigate production issue module.
metadata:
  short-description: "Standardized Investigate Production Issue module."
---

# Investigate Production Issue Workflow

## Purpose
To identify, trace, and triage live application outages or service degradation.

## When to Use
- When alerted to a production failure, elevated error rate, or user-reported incident.

## Required Prerequisite Skills
- `systematic-debugging` (to isolate variables in the issue)
- `root-cause-analysis` (to discover the core system failure)
- `logging` (to extract trace details and exceptions)

## Expected Inputs
- An alert, incident report, or user bug ticket.
- Access to production logs, metrics Dashboards, and tracing systems.

## Execution Workflow
1. **Determine Impact Scope**: Check error rates, system resource metrics, and count of affected users.
2. **Gather Evidence**: Apply `logging` standards to query structured logs. Filter by transaction IDs, customer IDs, or error codes.
3. **Mitigate (Stop the Bleeding)**: If the issue causes ongoing data corruption or downtime, execute immediate mitigation (rollback, disable feature flag, scale up resources).
4. **Isolate Locus**: Use `systematic-debugging` principles to trace the issue back to a specific service, config change, or infrastructure resource.
5. **Determine Root Cause**: Apply `root-cause-analysis` to map the timeline and execute the 5 Whys.
6. **Document Incident**: Write a Post-Mortem and compile the next steps.

## Expected Outputs
- Service mitigation (stable production system).
- A drafted Post-Mortem / RCA document.
- Action items to address the root cause.

## Completion Checklist
- [ ] Production systems are returned to a stable, healthy state.
- [ ] Issue logs and traces are captured and documented.
- [ ] Direct cause and contributing factors are isolated.
- [ ] A Post-Mortem report is drafted.
- [ ] Long-term preventive tickets are created in the backlog.

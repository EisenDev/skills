# Root Cause Analysis

## Overview
This skill governs the process of identifying the fundamental reason behind a system failure. It shifts focus from merely fixing symptoms to understanding systemic failures and preventing recurrence.

## Purpose
To find the exact underlying flaw (infrastructure, logic, process, or design) that caused a defect or incident.

## When to Use
- After a production incident or outage.
- When a recurring bug is observed.
- During post-mortem reviews.

## When NOT to Use
- Do NOT use this skill for isolating variables during active debugging (use `systematic-debugging`).
- Do NOT use this skill to design new APIs or database schemas (use `api-design` or `database-design`).

## Principles
1. **Blameless**: Focus on *how* and *why* the system failed, not *who* made the mistake.
2. **Deep Inquiry**: Use techniques like the "5 Whys" to dig below the surface of the issue.
3. **Actionable Remediation**: Every analysis must yield preventive actions that eliminate the root cause.
4. **Evidence-Based**: Base the analysis on log traces, metrics, configuration states, and code reviews, not speculation.

## Workflow
1. **Establish the Timeline**: Document the exact sequence of events leading up to, during, and after the incident.
2. **Identify the Direct Cause**: Point to the immediate trigger (e.g., a database connection pool depletion).
3. **Apply the 5 Whys**: Ask why the direct cause occurred, and repeat for each explanation until the root failure is found.
4. **Formulate Corrective Actions**: Define short-term fixes and long-term preventions.
5. **Document the Incident**: Create a Post-Mortem / RCA document detailing findings, impact, and action items.

## Rules
- You MUST document the root cause with evidence (log snippets, metrics graphs, or code diffs).
- Action items MUST have assigned owners and explicit completion dates.
- Do NOT declare an RCA complete until the preventive action is verified to block the specific failure mode.

## Best Practices
- Validate assumptions against metrics (e.g., CPU, RAM, IOPS, Network).
- Distinguish between contributing factors (which made the issue worse) and the root cause (without which the issue would not have occurred).
- Involve all team members who participated in the incident response.

## Common Mistakes
- Stopping at the first human error (e.g., "Developer forgot to set a flag") instead of checking why the system allowed that error to pass.
- Proposing generic remedies like "be more careful" or "write more documentation" instead of writing automated safeguards.

## Anti-patterns
- **The Scapegoat**: Blaming an external vendor or a single team member for a failure instead of hardening internal systems.
- **The Paper Shield**: Adding complex approvals or review checklists that slow down velocity without preventing the failure.

## Examples
*Example: Outage Analysis (5 Whys)*
1. *Why did the service crash?* Database connection pool exhausted.
2. *Why was it exhausted?* Long-running queries blocked connections.
3. *Why were they blocking?* A query on `users` table scanned millions of rows without an index.
4. *Why did it lack an index?* The feature was deployed without database-design review.
5. *Why was there no review?* Database migrations were not flagged for automated schema reviews in CI.
- **Root Cause**: Lack of automated linting/verification checks for database migrations.

## Completion Checklist
- [ ] Timeline of the incident is documented with exact timestamps.
- [ ] Root cause is identified and backed by empirical evidence.
- [ ] 5 Whys or equivalent analysis is fully written.
- [ ] Action items to prevent recurrence are defined and assigned.
- [ ] Post-Mortem report is reviewed and committed to the archive.

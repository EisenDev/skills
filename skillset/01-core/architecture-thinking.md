# Architecture Thinking

## Overview
This skill describes the methodology for analyzing requirements, evaluating system constraints, and designing software systems before writing code. It focuses on modularity, scalability, simplicity, and architectural trade-offs.

## Purpose
To construct a robust design specification that aligns with system design principles and organizational standards before development starts.

## When to Use
- When planning a new system, service, or major feature.
- When restructuring or refactoring a significant portion of an existing codebase.
- When making technical decisions regarding protocols, databases, or patterns.

## When NOT to Use
- Do NOT use this skill for minor hotfixes or simple bug fixes that do not alter system structure.
- Do NOT use this skill for writing user guides or technical instructions (use `documentation-first`).

## Principles
1. **Separation of Concerns**: Divide a system into distinct features with minimal overlapping duties.
2. **Single Responsibility**: Each module, class, or function should have one reason to change.
3. **Loose Coupling / High Cohesion**: Keep components independent yet highly focused.
4. **Trade-off Awareness**: Understand that every design pattern has costs (latency, complexity, maintenance).

## Workflow
1. **Gather Constraints**: Determine throughput, latency, security, reliability, and timelines.
2. **Identify Entities & Boundaries**: Define key domain models, services, and their interfaces.
3. **Formulate Architectural Options**: Outline at least two design options (e.g., synchronous REST vs asynchronous event-driven).
4. **Evaluate Trade-offs**: Document pros and cons of each option using a structured matrix.
5. **Select & Document**: Write an Architecture Decision Record (ADR) detailing the design, patterns, database schema, and protocols.

## Rules
- You MUST document the reasoning behind choosing a specific design pattern or technology.
- System interfaces and schemas MUST be designed and approved before implementation.
- Do NOT introduce complex architectures (microservices, CQRS) unless scale or organizational constraints explicitly require them.

## Best Practices
- Prefer composition over inheritance.
- Design systems to be stateless wherever possible.
- Define explicit failure domains; ensure a failure in one module does not cascade.

## Common Mistakes
- **Over-engineering**: Designing for hypothetical future scale (e.g., adding Kafka when a simple in-memory queue is sufficient).
- **Big Ball of Mud**: Letting boundaries blur, leading to direct circular dependencies between modules.

## Anti-patterns
- **Golden Hammer**: Applying a single familiar technology or pattern to every problem, regardless of fit.
- **Accidental Complexity**: Designing complex systems because the designer did not fully understand the problem.

## Examples
*Example: Designing a notification service.*
- Option A: Send notifications synchronously during the checkout process. Pros: Simple. Cons: Increases checkout latency, fails checkout if notification provider is down.
- Option B: Publish "order_created" event to a queue; notification worker consumes asynchronously. Pros: Decouples checkout, handles retries. Cons: Requires queue infrastructure.
- Choice: Option B is selected to ensure reliability and low checkout latency.

## Completion Checklist
- [ ] Requirements and constraints are documented.
- [ ] At least two design alternatives have been evaluated.
- [ ] System boundaries, interfaces, and schemas are defined.
- [ ] Architectural decisions (ADRs) are documented.
- [ ] Design adheres to SOLID principles and database standards.

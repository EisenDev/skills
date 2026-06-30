---
name: backend-standards
version: 1.0.0
category: engineering
author: Zeraynce Engineering
dependencies: []
description: Standardized backend standards module.
---

# Backend Standards

## Overview
This document outlines backend engineering conventions, state management, concurrency handling, resource management, and execution lifecycle guidelines.

## Purpose
To build reliable, scalable, and maintainable backend services that operate deterministically under load.

## When to Use
- When writing backend services, controllers, queues, or workers.
- When designing service layers, dependencies, or background jobs.

## When NOT to Use
- Do NOT use this document to define database migrations or table layouts (use `database-standards`).
- Do NOT use this document for frontend asset configurations (use `frontend-standards`).

## Principles
1. **Stateless Services**: Backend application instances should store zero local session state.
2. **Resource Cleanups**: Always release system resources (file handles, database connections, sockets) on shutdown or error.
3. **Graceful Degradation**: Fail safely; handle external outages without crashing the entire system.
4. **Strict Boundaries**: Separate transport layers (HTTP/gRPC) from business logic layers.

## Workflow
*Note: This is a standard.*

## Rules
- You MUST handle application signals (`SIGTERM`, `SIGINT`) to close connections and terminate active processes gracefully.
- External network requests made by the backend MUST have explicit timeout limits configured.
- Long-running operations MUST run asynchronously in background workers, not in the request-response thread.
- Thread/Process concurrency pools MUST be configured explicitly, avoiding default unbounded allocations.

## Best Practices
- Use dependency injection to decouple classes and make testing straightforward.
- Set appropriate health check endpoints (`/healthz`, `/readyz`).
- Implement circuit breakers for flaky downstream integrations.

## Common Mistakes
- Holding database connections open during long third-party API calls.
- Storing uploaded files on the local server's disk (prevents scaling horizontally; use cloud storage).
- Hardcoding environment-specific configurations (use environment variables instead).

## Anti-patterns
- **The Monolithic State**: Storing session details or cache in local memory, causing requests to fail when routed to other servers.
- **Silent Threads**: Launching background processes without error logging, leading to untraceable silent failures.

## Examples
*Example: Graceful shutdown handler.*
```javascript
process.on('SIGTERM', async () => {
  console.log('SIGTERM received. Starting graceful shutdown...');
  await httpServer.close();
  await dbConnection.destroy();
  console.log('Shutdown complete.');
  process.exit(0);
});
```

## Completion Checklist
- [ ] Business logic is separated from HTTP/transport controllers.
- [ ] Graceful shutdown and signal handling are implemented.
- [ ] Network request timeouts are configured.
- [ ] Concurrency/thread pool sizes are explicitly configured.
- [ ] Health check endpoints are active and verified.

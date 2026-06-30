---
name: deployment
version: 1.0.0
category: workflow
author: Zeraynce Engineering
dependencies: ["docker-standards", "verification-before-completion"]
description: Standardized deployment module.
metadata:
  short-description: "Standardized Deployment module."
---

# Deployment Workflow

## Purpose
To safely deliver compiled release artifacts or images into target environments (staging, production) while maintaining system availability.

## When to Use
- When moving a released codebase version to staging or production systems.

## Required Prerequisite Skills
- `docker-standards` (to check runtime images)
- `verification-before-completion` (to test the live deployment)

## Expected Inputs
- Tagged container image or release artifact.
- Target environment coordinates (K8s cluster, Server IP, CDN).

## Execution Workflow
1. **Validate Artifact**: Confirm that the target Docker image conforms to `docker-standards` (non-root execution, optimized layers).
2. **Apply Configurations**: Prepare environment-specific configurations (injected at runtime via environment variables).
3. **Execute Rolling Update**: Deploy changes using rolling updates, blue-green deployments, or canary strategies to prevent downtime.
4. **Run Database Migrations**: Apply migrations before code updates (ensuring migrations are backward-compatible per `database-standards`).
5. **Perform Health Checks**: Verify that container health check endpoints return 200 OK.
6. **Post-Deployment Verification**: Apply `verification-before-completion` principles on the live system. Check log outputs and metrics.

## Expected Outputs
- The release candidate operating successfully in the target environment.
- Deployment verification reports and logs.

## Completion Checklist
- [ ] Docker images used in deployment are validated and secure.
- [ ] Database migrations are executed successfully.
- [ ] Service has been updated without downtime using rolling deployment.
- [ ] Active containers report healthy states via `/healthz`.
- [ ] Live system verification passes and logs report zero startup anomalies.

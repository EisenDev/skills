---
name: docker-standards
version: 1.0.0
category: engineering
author: Zeraynce Engineering
dependencies: []
description: Standardized docker standards module.
---

# Docker Standards

## Overview
This document defines containerization rules, focusing on secure, optimized, small, and deterministic Docker images.

## Purpose
To build reproducible container images, optimize build cache speeds, and minimize runtime security risks.

## When to Use
- When writing `Dockerfile` configurations.
- When defining `docker-compose.yml` local structures.
- When configuring container build steps in CI/CD.

## When NOT to Use
- Do NOT use this document to manage git branching models (use `gitflow`).
- Do NOT use this document to write app styling standards (use `ui-standards`).

## Principles
1. **Minimal Footprint**: Keep images small by choosing slim base distros and removing build tools.
2. **Deterministic Builds**: Pin base images and library dependencies to exact versions.
3. **Security by Default**: Never execute containers as the root user.
4. **Cache Optimization**: Order instructions to maximize layer cache hit rates.

## Workflow
*Note: This is a standard.*

## Rules
- You MUST use multi-stage builds to compile resources and output a minimal production runtime image.
- Docker base images MUST be pinned using explicit versions (e.g., `node:20.11-alpine`, not `node:latest`).
- Container runtimes MUST NOT execute as the `root` user; specify a non-root system user using the `USER` directive.
- You MUST run a `clean` command or remove temp packages in the same `RUN` command where they are installed to keep layers light (e.g. `rm -rf /var/lib/apt/lists/*`).

## Best Practices
- Maintain a `.dockerignore` file to exclude `node_modules`, `.git`, tests, and build artifacts from the build context.
- Keep environment-specific settings out of the built image; supply them via environment variables at runtime.
- Run health checks inside the container utilizing `HEALTHCHECK` directives.

## Common Mistakes
- Leaving credentials, private keys, or API tokens inside image layers.
- Installing compilers (gcc, build-essential) in the final runtime stage.
- Using `ADD` when `COPY` is the appropriate tool (unless extraction is explicitly needed).

## Anti-patterns
- **The Megabyte Bloat**: Packing entire operational environments (e.g., full Ubuntu base) for simple runtime processes.
- **Unstable Layers**: Placing frequently changed directives (like `COPY . .`) *before* slow, static instructions (like `RUN apt-get update`).

## Examples
*Example: Multi-stage Dockerfile.*
```dockerfile
# Stage 1: Build
FROM node:20.11-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Stage 2: Runtime
FROM node:20.11-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/dist ./dist
USER appuser
EXPOSE 3000
CMD ["node", "dist/main.js"]
```

## Completion Checklist
- [ ] Multi-stage builds are utilized.
- [ ] Base images are pinned with explicit tags.
- [ ] Container runs under a non-root system user.
- [ ] `.dockerignore` is configured and excludes source/build noise.
- [ ] Layer order is optimized to support build caching.

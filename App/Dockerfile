# syntax=docker/dockerfile:1.7

# ---------- Stage 1: dependencies (production only) ----------
FROM node:20-alpine AS deps
WORKDIR /app
ENV NODE_ENV=production
COPY package.json package-lock.json* ./
# Deterministic, prod-only install. Fall back to npm install if no lockfile.
RUN if [ -f package-lock.json ]; then \
      npm ci --omit=dev --no-audit --no-fund; \
    else \
      npm install --omit=dev --no-audit --no-fund; \
    fi

# ---------- Stage 2: runtime ----------
FROM node:20-alpine AS runtime

# OCI image labels (filled at build time by CI)
ARG APP_VERSION=dev
ARG GIT_SHA=unknown
ARG BUILD_DATE
LABEL org.opencontainers.image.title="brasov-sunset-api" \
      org.opencontainers.image.description="API returning today's sunset time for Brasov, Romania" \
      org.opencontainers.image.source="https://github.com/vunvulear/DevOpsPro-Europe-2026" \
      org.opencontainers.image.version="${APP_VERSION}" \
      org.opencontainers.image.revision="${GIT_SHA}" \
      org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.licenses="MIT"

ENV NODE_ENV=production \
    PORT=3000 \
    APP_VERSION=${APP_VERSION} \
    NODE_OPTIONS="--enable-source-maps" \
    NPM_CONFIG_UPDATE_NOTIFIER=false

# Security: install tini for proper signal handling, drop to non-root user.
RUN apk add --no-cache tini=~0.19 && \
    addgroup -g 10001 -S nodeapp && \
    adduser  -u 10001 -S nodeapp -G nodeapp

WORKDIR /app
COPY --chown=nodeapp:nodeapp --from=deps /app/node_modules ./node_modules
COPY --chown=nodeapp:nodeapp package.json ./
COPY --chown=nodeapp:nodeapp server.js ./

USER nodeapp
EXPOSE 3000

# Container-level healthcheck (Container Apps also probes via HTTP).
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "fetch('http://127.0.0.1:'+ (process.env.PORT||3000) +'/healthz').then(r=>{if(r.status!==200)process.exit(1)}).catch(()=>process.exit(1))"

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["node", "server.js"]

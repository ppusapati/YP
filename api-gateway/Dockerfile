FROM caddy:2-alpine

COPY Caddyfile /etc/caddy/Caddyfile

EXPOSE 8080

HEALTHCHECK --interval=10s --timeout=3s --retries=5 \
    CMD wget -q --spider http://localhost:8080/health || exit 1

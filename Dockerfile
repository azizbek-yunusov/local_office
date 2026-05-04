ARG DS_VERSION=9.3.1
ARG HASH=1

# ============================================================
# Stage 1: OnlyOffice assets
# ============================================================
FROM onlyoffice/documentserver:${DS_VERSION} AS documentserver
RUN documentserver-generate-allfonts.sh false || true

# ============================================================
# Stage 2: Next.js build (static export)
# ============================================================
FROM node:22-alpine AS builder
ARG DS_VERSION
ARG HASH

ENV NEXT_PUBLIC_APP_ROOT=/v${DS_VERSION}-${HASH}
WORKDIR /srv/projects/office

COPY package.json package-lock.json ./
RUN npm ci

COPY . .
RUN npm run build

# ============================================================
# Stage 3: Caddy static server
# ============================================================
FROM caddy:2-alpine AS final
ARG DS_VERSION
ARG HASH

WORKDIR /srv/projects/office

COPY --from=builder /srv/projects/office/out ./

COPY --from=documentserver /var/www/onlyoffice/documentserver/fonts         ./v${DS_VERSION}-${HASH}/fonts
COPY --from=documentserver /var/www/onlyoffice/documentserver/sdkjs         ./v${DS_VERSION}-${HASH}/sdkjs
COPY --from=documentserver /var/www/onlyoffice/documentserver/web-apps      ./v${DS_VERSION}-${HASH}/web-apps
COPY --from=documentserver /var/www/onlyoffice/documentserver/sdkjs-plugins ./v${DS_VERSION}-${HASH}/sdkjs-plugins

RUN if [ ! -f "./v${DS_VERSION}-${HASH}/web-apps/apps/api/documents/api.js" ]; then \
  cp "./v${DS_VERSION}-${HASH}/web-apps/apps/api/documents/api.js.tpl" \
  "./v${DS_VERSION}-${HASH}/web-apps/apps/api/documents/api.js"; \
  fi

RUN find "./v${DS_VERSION}-${HASH}/web-apps/apps/api/documents/" -name "api.js" \
  -exec sed -i "s|const ver = '[^']*'|const ver = ''|g" {} \;

COPY Caddyfile /etc/caddy/Caddyfile
EXPOSE 4000
# ============================================================
# Stage 2: Next.js build + assets
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
# Stage 3: Next.js production server
# ============================================================
FROM node:22-alpine AS final
ARG DS_VERSION
ARG HASH

ENV NODE_ENV=production
ENV PORT=4000
ENV NEXT_TELEMETRY_DISABLED=1

WORKDIR /srv/projects/office

COPY --from=builder /srv/projects/office/package.json ./
COPY --from=builder /srv/projects/office/node_modules ./node_modules
COPY --from=builder /srv/projects/office/.next ./.next
COPY --from=builder /srv/projects/office/public ./public
COPY --from=builder /srv/projects/office/next.config.ts ./

# OnlyOffice assets -> public papkasiga
COPY --from=documentserver /var/www/onlyoffice/documentserver/fonts         ./public/v${DS_VERSION}-${HASH}/fonts
COPY --from=documentserver /var/www/onlyoffice/documentserver/sdkjs         ./public/v${DS_VERSION}-${HASH}/sdkjs
COPY --from=documentserver /var/www/onlyoffice/documentserver/web-apps      ./public/v${DS_VERSION}-${HASH}/web-apps
COPY --from=documentserver /var/www/onlyoffice/documentserver/sdkjs-plugins ./public/v${DS_VERSION}-${HASH}/sdkjs-plugins

# api.js
RUN if [ ! -f "./public/v${DS_VERSION}-${HASH}/web-apps/apps/api/documents/api.js" ]; then \
  cp "./public/v${DS_VERSION}-${HASH}/web-apps/apps/api/documents/api.js.tpl" \
  "./public/v${DS_VERSION}-${HASH}/web-apps/apps/api/documents/api.js"; \
  fi

RUN find "./public/v${DS_VERSION}-${HASH}/web-apps/apps/api/documents/" -name "api.js" \
  -exec sed -i "s|const ver = '[^']*'|const ver = ''|g" {} \;

EXPOSE 4000
CMD ["node_modules/.bin/next", "start", "-p", "4000"]

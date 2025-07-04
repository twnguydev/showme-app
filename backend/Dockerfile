# Dockerfile
FROM node:22-alpine AS base

# Installer les dépendances système
RUN apk add --no-cache libc6-compat
WORKDIR /app

# Copier les fichiers de dépendances
COPY package*.json ./
COPY tsconfig*.json ./

# Installer les dépendances
FROM base AS deps
RUN npm ci --only=production && npm cache clean --force

# Builder l'application
FROM base AS builder
COPY . .
RUN npm ci
RUN npm run build

# Image de production
FROM node:22-alpine AS runner
WORKDIR /app

ENV NODE_ENV production

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nestjs

COPY --from=deps /app/node_modules ./node_modules
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/package.json ./package.json

USER nestjs

EXPOSE 3000

ENV PORT 3000

CMD ["node", "dist/main"]
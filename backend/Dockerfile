FROM node:22-alpine AS base

RUN apk add --no-cache \
    libc6-compat \
    curl \
    bash \
    tzdata

WORKDIR /app

COPY package*.json ./
COPY tsconfig*.json ./
COPY nest-cli.json ./

# Stage développement
FROM base AS development

# Installer toutes les dépendances
RUN npm ci --include=dev

# Installer ts-node globalement pour TypeORM CLI
RUN npm install -g ts-node

# Copier le code source
COPY . .

# Créer les dossiers nécessaires
RUN mkdir -p uploads logs src/database/migrations src/database/seeds src/database/subscribers

EXPOSE 3000
CMD ["npm", "run", "start:dev"]

# Stage production
FROM base AS production
RUN npm ci --only=production
COPY . .
RUN npm run build
EXPOSE 3000
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:3000/health || exit 1
CMD ["node", "dist/main"]
FROM node:22-alpine AS base

RUN apk add --no-cache libc6-compat curl bash
WORKDIR /app

COPY package*.json ./
COPY tsconfig*.json ./

FROM base AS development
RUN npm ci --include=dev
COPY . .

RUN npm install -g ts-node

EXPOSE 3000
CMD ["npm", "run", "start:dev"]

FROM base AS production
RUN npm ci --only=production
COPY . .
RUN npm run build
EXPOSE 3000
USER node
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:3000/health || exit 1
CMD ["node", "dist/main"]
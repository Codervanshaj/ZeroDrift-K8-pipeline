# ── Stage 1: build ────────────────────────────────────────────────────────────
FROM node:20-alpine AS builder
WORKDIR /app
COPY package.json .
RUN npm install --production
COPY . .

# ── Stage 2: run ──────────────────────────────────────────────────────────────
FROM node:20-alpine
WORKDIR /app
COPY --from=builder /app .
EXPOSE 3000
USER node
CMD ["node", "server.js"]

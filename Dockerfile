FROM node:20-slim

RUN apt-get update && apt-get install -y \
    wget gnupg curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY package*.json ./
RUN npm install
RUN npm install --save-dev @types/node tsx

COPY . .

ENV PORT=3000
ENV NODE_ENV=production
EXPOSE 3000

# Comando mais explícito
CMD ["sh", "-c", "npx tsx src/index.ts"]

FROM node:20-slim AS builder

WORKDIR /app

# Copiar apenas os arquivos de dependência primeiro (cache)
COPY package*.json ./
COPY package-lock.json ./

# Instalar dependências
RUN npm install

# Copiar o resto do código
COPY . .

# Compilar TypeScript
RUN npm run build

# ============================================
# IMAGEM FINAL
# ============================================
FROM node:20-slim

# Instalar dependências do Playwright (Chrome)
RUN apt-get update && apt-get install -y \
    wget \
    gnupg \
    && wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list \
    && apt-get update && apt-get install -y google-chrome-stable \
    && rm -rf /var/lib/apt/lists/*

# Configurar Playwright
ENV PLAYWRIGHT_BROWSERS_PATH=/ms-playwright
ENV PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1

WORKDIR /app

# Copiar node_modules e código compilado
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/package*.json ./

# Instalar o Chromium do Playwright
RUN npx playwright install chromium

# Porta do servidor
EXPOSE 3000

# Comando para inicia
CMD ["node", "dist/index.js"]

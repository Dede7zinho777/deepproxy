FROM node:20-slim

# Instalar dependências do sistema (SEM pacotes t64)
RUN apt-get update && apt-get install -y \
    wget gnupg curl \
    libx11-xcb1 libxrandr2 libxcomposite1 libxcursor1 libxdamage1 \
    libxi6 libxfixes3 libgtk-3-0 libatk1.0-0 libatk-bridge2.0-0 \
    libcairo-gobject2 libgdk-pixbuf-2.0-0 libasound2 \
    libdrm2 libxkbcommon0 libgbm1 libnss3 libxshmfence1 \
    libgl1-mesa-glx libxss1 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copiar e instalar dependências
COPY package*.json ./
RUN npm install
RUN npm install --save-dev @types/node tsx

# Instalar Playwright
RUN npx playwright install chromium

# Copiar o código
COPY . .

# Compilar TypeScript
RUN npm run build

# Configurar variáveis de ambiente
ENV PORT=3000
ENV NODE_ENV=production

# Expor a porta
EXPOSE 3000

# Rodar o servidor
CMD ["node", "dist/index.js"]

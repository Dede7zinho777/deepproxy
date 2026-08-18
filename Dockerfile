FROM node:20-slim

# === TODAS AS BIBLIOTECAS DO SISTEMA (IGUAL AO CODESPACE) ===
RUN apt-get update && apt-get install -y \
    wget gnupg curl \
    libx11-xcb1 libxrandr2 libxcomposite1 libxcursor1 libxdamage1 \
    libxi6 libxfixes3 libgtk-3-0 libatk1.0-0 libatk-bridge2.0-0 \
    libcairo-gobject2 libgdk-pixbuf-2.0-0 libasound2 libasound2t64 \
    libdrm2 libxkbcommon0 libgbm1 libnss3 libxshmfence1 \
    libgl1-mesa-glx libxss1 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY package*.json ./
RUN npm install
RUN npm install --save-dev @types/node tsx

# === INSTALAR PLAYWRIGHT E CHROMIUM (IGUAL AO CODESPACE) ===
RUN npx playwright install chromium

COPY . .

ENV PORT=3000
ENV NODE_ENV=production
EXPOSE 3000

CMD ["sh", "-c", "npx tsx src/index.ts"]

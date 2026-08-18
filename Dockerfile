FROM node:20-slim

# Instalar dependências do sistema para Playwright
RUN apt-get update && apt-get install -y \
    wget \
    gnupg \
    && wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list \
    && apt-get update && apt-get install -y google-chrome-stable \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copiar package.json e instalar dependências
COPY package*.json ./
RUN npm install

# Instalar dependências de desenvolvimento
RUN npm install --save-dev @types/node tsx

# Copiar o código
COPY . .

# Remover arquivos de teste problemáticos (se existirem)
RUN rm -f src/*.test.ts

# Rodar com tsx (sem compilar)
EXPOSE 3000

CMD ["npx", "tsx", "src/index.ts"]

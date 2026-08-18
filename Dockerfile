FROM node:20-slim

# Instalar dependências do sistema
RUN apt-get update && apt-get install -y \
    wget \
    gnupg \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copiar package.json e instalar dependências
COPY package*.json ./
RUN npm install

# Instalar dependências de desenvolvimento
RUN npm install --save-dev @types/node tsx

# Copiar o resto do código
COPY . .

# Criar diretório dist (se não existir)
RUN mkdir -p dist

# Tentar compilar (se falhar, vai rodar com tsx mesmo assim)
RUN npm run build || true

# Configurar variáveis de ambiente
ENV PORT=3000
ENV NODE_ENV=production

# Expor a porta
EXPOSE 3000

# Rodar o servidor
CMD ["npx", "tsx", "src/index.ts"]

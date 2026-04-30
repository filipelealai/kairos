FROM node:22-bookworm-slim

ENV NODE_ENV=production \
    KAIROS_REPO_PATH=/app/kairos-repo \
    PORT=3333

# git + curl pro git pull e healthcheck; tini como init pra sinais limpos
RUN apt-get update && apt-get install -y --no-install-recommends \
        git \
        ca-certificates \
        curl \
        tini \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Camada de dependências do servidor MCP (do próprio repo Kairos, copiado aqui)
COPY package.json package-lock.json* ./
RUN npm ci --omit=dev=false || npm install

# Código do servidor (e do projeto inteiro) — copia mínima do necessário pra rodar o MCP
COPY tsconfig.json ./
COPY src ./src

# Diretório onde o repo Kairos será clonado em runtime
RUN mkdir -p ${KAIROS_REPO_PATH}

EXPOSE 3333

HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=3 \
    CMD curl -fsS http://localhost:3333/health || exit 1

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["node", "--import", "tsx/esm", "src/mcp-server/index.ts"]

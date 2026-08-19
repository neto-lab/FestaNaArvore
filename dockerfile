# Etapa 1: Usa a imagem oficial do Node para compilar o painel web
FROM node:18-slim AS builder
WORKDIR /app
RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*
RUN git clone https://github.com . && npm install && npm run build

# Etapa 2: Monta o servidor final rodando no Ubuntu estável
FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

# Instala o servidor Mumble, o Supervisor e o runtime básico do Node
RUN apt-get update && apt-get install -y \
    supervisor \
    mumble-server \
    nodejs \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copia os arquivos que foram compilados na Etapa 1
COPY --from=builder /app /app

# Configura as permissões para a cota gratuita do Render
RUN mkdir -p /var/run/mumble-server /var/lib/mumble-server && chown -R 1000:1000 /var/lib/mumble-server /var/run/mumble-server

# Copia as regras do supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 7860

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

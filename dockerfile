# Etapa 1: Baixa e descompacta a interface estável do Mumble-Web
FROM alpine:3.18 AS builder
WORKDIR /app
RUN apk add --no-cache wget tar
RUN wget https://github.com && \
    tar -xzf master.tar.gz --strip-components=1

# Etapa 2: Executa o servidor final estável no Ubuntu
FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

# Instala o servidor de voz Mumble e o gerenciador Supervisor
RUN apt-get update && apt-get install -y \
    supervisor \
    mumble-server \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copia os arquivos baixados na Etapa 1
COPY --from=builder /app /app

# Configura as permissões exigidas pela cota gratuita do Render
RUN mkdir -p /var/run/mumble-server /var/lib/mumble-server && chown -R 1000:1000 /var/lib/mumble-server /var/run/mumble-server

# Copia o arquivo de regras
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 7860

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

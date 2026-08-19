FROM ubuntu:22.04

# Evita perguntas interativas durante a instalação
ENV DEBIAN_FRONTEND=noninteractive

# Instala dependências do sistema, Node.js, Mumble (murmur) e Supervisor
RUN apt-get update && apt-get install -y \
    curl \
    git \
    supervisor \
    mumble-server \
    && curl -fsSL https://nodesource.com | bash - \
    && apt-get install -y佳 nodejs \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Baixa e compila a interface web do Mumble
RUN git clone https://github.com . && npm install && npm run build

# Configura as permissões corretas
RUN mkdir -p /var/run/mumble-server /var/lib/mumble-server && chown -R 1000:1000 /var/lib/mumble-server /var/run/mumble-server

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 7860

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

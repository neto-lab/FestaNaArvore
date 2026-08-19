FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

# Instala apenas o servidor de voz Mumble e o gerenciador Supervisor
RUN apt-get update && apt-get install -y supervisor mumble-server python3 && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copia a nossa interface criada no passo anterior para dentro do servidor
COPY index.html /app/index.html

# Configura as permissões para a cota gratuita do Render
RUN mkdir -p /var/run/mumble-server /var/lib/mumble-server && chown -R 1000:1000 /var/lib/mumble-server /var/run/mumble-server

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 7860

# Inicia um servidor web nativo super leve na porta exigida pelo Render
CMD /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf & python3 -m http.server 7860

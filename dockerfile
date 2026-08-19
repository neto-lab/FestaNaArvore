FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

# Instala pacotes do sistema, o servidor de voz Mumble e o utilitário wget
RUN apt-get update && apt-get install -y supervisor mumble-server wget tar && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Faz o download e extração em uma linha única e direta para não bugar no Render
RUN wget https://github.com -O master.tar.gz && tar -xzf master.tar.gz --strip-components=1 && rm master.tar.gz

# Configura as permissões para a cota gratuita do Render
RUN mkdir -p /var/run/mumble-server /var/lib/mumble-server && chown -R 1000:1000 /var/lib/mumble-server /var/run/mumble-server

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 7860

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

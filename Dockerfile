FROM node:18-slim
RUN apt-get update && apt-get install -y murmur-server supervisor git && rm -rf /var/lib/apt/lists/*
WORKDIR /app
RUN git clone https://github.com . && npm install && npm run build
RUN mkdir -p /var/run/mumble-server /var/lib/mumble-server && chown -R 1000:1000 /var/lib/mumble-server /var/run/mumble-server
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
EXPOSE 7860
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

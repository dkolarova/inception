FROM debian:bookworm

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    gettext-base \
    nginx \
    openssl \
 && rm -rf /var/lib/apt/lists/*

COPY conf/default.conf.template /etc/nginx/templates/default.conf.template
COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/entrypoint.sh && mkdir -p /etc/nginx/ssl

EXPOSE 443

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]

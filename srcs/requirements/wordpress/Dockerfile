FROM debian:bookworm

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    gettext-base \
    less \
    mariadb-client \
    php8.2-cli \
    php8.2-common \
    php8.2-curl \
    php8.2-fpm \
    php8.2-gd \
    php8.2-mbstring \
    php8.2-mysql \
    php8.2-opcache \
    php8.2-xml \
    php8.2-zip \
    tar \
    unzip \
    wget \
 && rm -rf /var/lib/apt/lists/*

RUN wget -qO /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x /usr/local/bin/wp

COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf
COPY conf/php.ini /etc/php/8.2/fpm/conf.d/99-inception.ini
COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/entrypoint.sh && mkdir -p /run/php

WORKDIR /var/www/html

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["php-fpm8.2", "-F"]

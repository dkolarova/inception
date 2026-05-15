#!/bin/sh
set -eu

mkdir -p /etc/nginx/ssl /var/www/html

if [ ! -f "/etc/nginx/ssl/${DOMAIN_NAME}.crt" ] || [ ! -f "/etc/nginx/ssl/${DOMAIN_NAME}.key" ]; then
	openssl req -x509 -nodes -days 365 -newkey rsa:4096 \
		-keyout "/etc/nginx/ssl/${DOMAIN_NAME}.key" \
		-out "/etc/nginx/ssl/${DOMAIN_NAME}.crt" \
		-subj "/C=FR/ST=IDF/L=Paris/O=42/OU=Inception/CN=${DOMAIN_NAME}"
fi

envsubst '${DOMAIN_NAME}' < /etc/nginx/templates/default.conf.template > /etc/nginx/conf.d/default.conf

exec "$@"

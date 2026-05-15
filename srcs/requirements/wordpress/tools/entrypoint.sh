#!/bin/sh
set -eu

WP_DIR=/var/www/html
DB_HOST=${WORDPRESS_DB_HOST:-mariadb:3307}
DB_NAME=${WORDPRESS_DB_NAME:?WORDPRESS_DB_NAME is required}
DB_USER=${WORDPRESS_DB_USER:?WORDPRESS_DB_USER is required}
DB_PASSWORD=$(cat /run/secrets/db_password)
ADMIN_PASSWORD=$(cat /run/secrets/credentials)
USER_PASSWORD=$(cat /run/secrets/wp_user_password)

mkdir -p "$WP_DIR"
chown -R www-data:www-data "$WP_DIR"

if [ ! -f "$WP_DIR/wp-settings.php" ]; then
	wp core download --path="$WP_DIR" --allow-root --quiet --force
fi

if [ ! -f "$WP_DIR/wp-config.php" ]; then
	wp config create \
		--path="$WP_DIR" \
		--allow-root \
		--dbname="$DB_NAME" \
		--dbuser="$DB_USER" \
		--dbpass="$DB_PASSWORD" \
		--dbhost="$DB_HOST" \
		--skip-check \
		--force
fi

# Keep DB host in sync with .env even when wp-config.php already exists.
wp config set DB_HOST "$DB_HOST" --path="$WP_DIR" --allow-root --type=constant

DB_HOST_NAME=${DB_HOST%%:*}
DB_HOST_PORT=${DB_HOST##*:}
if [ "$DB_HOST_NAME" = "$DB_HOST_PORT" ]; then
	DB_HOST_PORT=3307
fi

for _ in $(seq 1 30); do
	if mariadb-admin ping -h "$DB_HOST_NAME" -P "$DB_HOST_PORT" -u"${DB_USER}" -p"${DB_PASSWORD}" --silent >/dev/null 2>&1; then
		break
	fi
	sleep 1
done

if ! wp core is-installed --path="$WP_DIR" --allow-root >/dev/null 2>&1; then
	wp core install \
		--path="$WP_DIR" \
		--allow-root \
		--url="https://${DOMAIN_NAME}" \
		--title="${WP_TITLE:-Inception}" \
		--admin_user="${WP_ADMIN_USER:?WP_ADMIN_USER is required}" \
		--admin_password="$ADMIN_PASSWORD" \
		--admin_email="${WP_ADMIN_EMAIL:?WP_ADMIN_EMAIL is required}" \
		--skip-email
fi

if ! wp user get "${WP_USER:?WP_USER is required}" --path="$WP_DIR" --allow-root >/dev/null 2>&1; then
	wp user create \
		"${WP_USER}" \
		"${WP_USER_EMAIL:?WP_USER_EMAIL is required}" \
		--path="$WP_DIR" \
		--allow-root \
		--role=subscriber \
		--user_pass="$USER_PASSWORD"
fi

chown -R www-data:www-data "$WP_DIR"

exec "$@"

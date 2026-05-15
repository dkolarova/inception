#!/bin/sh
set -eu

DATA_DIR=/var/lib/mysql
SOCKET=/run/mysqld/mysqld.sock
INIT_MARKER="$DATA_DIR/.inception_db_initialized"
MYSQL_SYSTEM_DIR="$DATA_DIR/mysql"

mkdir -p "$DATA_DIR"
mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld "$DATA_DIR"

if [ ! -f "$INIT_MARKER" ] || [ ! -d "$MYSQL_SYSTEM_DIR" ]; then
	if [ -f "$INIT_MARKER" ] && [ ! -d "$MYSQL_SYSTEM_DIR" ]; then
		find "$DATA_DIR" -mindepth 1 -maxdepth 1 -exec rm -rf {} +
	fi

	if [ ! -d "$MYSQL_SYSTEM_DIR" ]; then
		mariadb-install-db --user=mysql --datadir="$DATA_DIR" >/dev/null
	fi

	mariadbd --user=mysql --datadir="$DATA_DIR" --socket="$SOCKET" --skip-networking --console &
	temp_pid=$!

	for _ in $(seq 1 30); do
		if mariadb-admin --socket="$SOCKET" ping >/dev/null 2>&1; then
			break
		fi
		sleep 1
	done

	DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)
	DB_NAME=${MYSQL_DATABASE:?MYSQL_DATABASE is required}
	DB_USER=${MYSQL_USER:?MYSQL_USER is required}
	DB_PASSWORD=$(cat /run/secrets/db_password)

	mariadb --socket="$SOCKET" -uroot <<-EOSQL
		ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
		CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;
		CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
		GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%';
		FLUSH PRIVILEGES;
	EOSQL

	touch "$INIT_MARKER"
	chown mysql:mysql "$INIT_MARKER"

	mariadb-admin --socket="$SOCKET" -uroot -p"${DB_ROOT_PASSWORD}" shutdown || true
	wait "$temp_pid" || true
fi

exec "$@"

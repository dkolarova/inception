#!/bin/bash

set -e

# Start MariaDB
mysqld_safe --datadir=/var/lib/mysql &
pid=$!

# Wait for DB (IMPORTANT: use root socket login, NOT mysqladmin ping)
until mysql -u root -e "SELECT 1" &>/dev/null; do
    sleep 1
done

echo "MariaDB ready"

# Setup database
mysql -u root <<EOF
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};

CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';

GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';

FLUSH PRIVILEGES;
EOF

# Set root password safely
mysql -u root <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOF

# Stop temp server
mysqladmin -u root shutdown

# Start normally in foreground
exec mysqld_safe --datadir=/var/lib/mysql
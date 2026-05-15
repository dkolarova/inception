# DEV_DOC

## Overview

This document explains how to set up, build, run, and maintain the project as a developer using Docker Compose and the Makefile.

---

## 1. Environment Setup (From Scratch)

### Prerequisites

Install the following tools:

- Docker
- Docker Compose
- GNU Make
- Git

Verify installation:

```bash
docker --version
docker compose version
make --version
git --version
```

---

### Clone the repository

```bash
git clone <repository_url>
cd <project_name>
```

---

### Configuration files

The `.env` file already exists at `srcs/.env`. It contains:

```env
DOMAIN_NAME=dkolarov.42.fr
HOST_DATA_DIR=/home/dkolarov/data

MYSQL_DATABASE=wordpress
MYSQL_USER=wp_user

WORDPRESS_DB_NAME=wordpress
WORDPRESS_DB_USER=wp_user
WORDPRESS_DB_HOST=mariadb:3306

WP_TITLE=Inception
WP_ADMIN_USER=dkolarov42
WP_ADMIN_EMAIL=dkolarov42@dkolarov.42.fr
WP_USER=dkolarov
WP_USER_EMAIL=dkolarov@dkolarov.42.fr
```

**Customize** these values if needed, especially:
- `DOMAIN_NAME` - must match `/etc/hosts` entry and correspond to your username
- `WP_ADMIN_USER` - admin username (cannot contain "admin" or "administrator")

---

### Secrets setup

Secrets are stored in individual files in the `secrets/` directory:

```bash
ls -la secrets/
```

Expected files:
- `secrets/db_password.txt` - MariaDB user password
- `secrets/db_root_password.txt` - MariaDB root password
- `secrets/credentials.txt` - WordPress admin password
- `secrets/wp_user_password.txt` - WordPress regular user password

**Never commit these files to Git** (already in `.gitignore`)

These files are read by containers at startup via Docker Compose secrets mechanism.

---

## 2. Build and Launch Project

### Using Makefile (recommended)

Build and start all services:

```bash
make up
```

Or use the shorthand (builds + starts):

```bash
make
```

Stop all services:

```bash
make down
```

Full rebuild (remove volumes + restart):

```bash
make re
```

Clean containers and orphans:

```bash
make clean
```

Deep clean (remove containers + volumes + host data):

```bash
make fclean
```

View logs:

```bash
make logs
```

---

### Using Docker Compose directly

Build and start:

```bash
docker compose up --build -d
```

Stop:

```bash
docker compose down
```

Restart:

```bash
docker compose restart
```

Rebuild without cache:

```bash
docker compose build --no-cache
docker compose up -d
```

---

## 3. Container and Volume Management

### List running containers

```bash
docker ps
```

### View all containers

```bash
docker compose ps
```

### View logs

```bash
docker compose logs
```

### View logs for a specific service

```bash
docker compose logs <service_name>
```

### Access a container shell

```bash
docker exec -it <container_name> sh
```

or

```bash
docker exec -it <container_name> bash
```

---

### Volumes management

List volumes:

```bash
docker volume ls
```

Inspect a volume:

```bash
docker volume inspect <volume_name>
```

Remove volumes:

```bash
docker volume rm <volume_name>
```

Remove everything (containers + volumes):

```bash
docker compose down -v
```

---

## 3.5 Service-Specific Commands

### WordPress commands (via WP-CLI)

Execute WordPress CLI inside the container:

```bash
docker exec wordpress wp plugin list
docker exec wordpress wp theme list
docker exec wordpress wp post list
docker exec wordpress wp user list
```

### MariaDB commands

Access database shell:

```bash
docker exec -it mariadb mariadb -u root -p
```

Dump database backup:

```bash
docker exec mariadb mariadb-dump -u root -p wordpress > backup.sql
```

### Nginx configuration

View current Nginx config:

```bash
docker exec nginx cat /etc/nginx/conf.d/default.conf
```

Test Nginx config:

```bash
docker exec nginx nginx -t
```

---

## 4. Data Storage & Persistence

### Where Inception data is stored

Project data is stored in two Docker named volumes:

1. **mariadb_data** - MariaDB database files
   - Container path: `/var/lib/mysql`
   - Host path: Managed by Docker (location varies)

2. **wordpress_data** - WordPress application files, themes, plugins, uploads
   - Container path: `/var/www/html`
   - Host path: Managed by Docker (location varies)

### Viewing volume information

List all volumes:

```bash
docker volume ls
```

Inspect a specific volume:

```bash
docker volume inspect mariadb_data
docker volume inspect wordpress_data
```

### How persistence works in Inception

- Data inside Docker volumes persists even after container restarts
- Data persists when containers are rebuilt (unless volumes are deleted)
- Volumes are only removed when explicitly deleted with `docker volume rm` or `make fclean`
- Each time you run `make re`, new volumes are created from scratch

### Important: Understanding `make fclean`

The `make fclean` command:

1. Stops all containers
2. Removes all containers and orphans
3. **Deletes mariadb_data and wordpress_data volumes**
4. This means:
   - WordPress database is reset
   - All uploaded files are deleted
   - WordPress is reinstalled from scratch on next `make up`

**⚠️ Use `make fclean` carefully** - it permanently erases all data in volumes.

### Reinitializing data after fclean

After running `make fclean`, simply restart the project:

```bash
make re
```

This will:
1. Create new empty volumes
2. Install fresh WordPress and MariaDB
3. Initialize both users as configured in `srcs/.env`

### Accessing database directly

Connect to MariaDB container:

```bash
docker exec -it mariadb mariadb -u root -p
```

Enter the root password from `secrets/db_root_password.txt`

Query WordPress database:

```sql
USE wordpress;
SHOW TABLES;
SELECT * FROM wp_users;
```

---

## 5. Troubleshooting

### WordPress not installing

**Symptom**: WordPress container keeps restarting or hangs.

**Check logs**:
```bash
make logs
```

or specific service:
```bash
docker compose logs wordpress
```

**Common causes**:
- MariaDB not fully initialized - wait 30 seconds and check again
- Incorrect database credentials in `srcs/.env`
- Volume permissions issue

**Solution**:
```bash
make re
```

---

### MariaDB won't start

**Check MariaDB logs**:
```bash
docker compose logs mariadb
```

**Verify credentials**:
- Check `secrets/db_password.txt` and `secrets/db_root_password.txt` exist
- Files should not be empty

**Reset**:
```bash
make fclean
make re
```

---

### Nginx SSL certificate warnings

**Expected behavior**: Browser shows SSL warning (self-signed certificate).

**To verify certificate**:
```bash
docker exec -it nginx ls -la /etc/nginx/ssl/
```

Certificate is auto-generated on first start with domain name from `DOMAIN_NAME` env var.

---

### Permission denied errors during `make fclean`

**Old issue** (now fixed by using named volumes instead of bind mounts).

If you get permission errors:
```bash
sudo make fclean
sudo make re
```

---

### Domain not resolving

**Check `/etc/hosts`**:
```bash
cat /etc/hosts | grep 42.fr
```

Should show:
```
127.0.0.1 dkolarov.42.fr
```

**Add it if missing**:
```bash
sudo bash -c 'echo "127.0.0.1 dkolarov.42.fr" >> /etc/hosts'
```

**Test resolution**:
```bash
ping dkolarov.42.fr
```

---

### Port 443 already in use

Find what's using port 443:
```bash
sudo lsof -i :443
```

Kill the process or stop Docker:
```bash
docker compose down
# Stop other services
docker compose up -d
```

---

### Full reset/troubleshooting

If nothing works, perform a complete reset:

```bash
# Stop everything
make fclean

# Prune Docker (optional - removes unused images/containers)
docker system prune -af

# Rebuild from scratch
make re

# Check status
make logs
```

---

### Debugging commands

**Check all containers**:
```bash
docker compose ps
```

**Check WordPress container**:
```bash
docker exec wordpress wp core is-installed
docker exec wordpress wp user list
```

**Check database**:
```bash
docker exec mariadb mariadb -u root -p -e "SHOW DATABASES;"
```

**Check Nginx**:
```bash
docker exec nginx nginx -t
docker exec nginx cat /etc/nginx/conf.d/default.conf
```

---

## 6. Project Architecture

### Service Communication

```
Internet (HTTPS on 443)
        ↓
    Nginx Container
        ↓ (localhost:9000)
    WordPress Container (PHP-FPM)
        ↓ (mariadb:3306)
    MariaDB Container
```

- **Nginx** receives HTTPS traffic on port 443
- **Nginx** proxies PHP requests to **WordPress** container
- **WordPress** queries **MariaDB** for data
- All communication through Docker bridge network

### File Structure

```
inception/
├── Makefile              # Build automation
├── README.md             # Project documentation
├── USER_DOC.md           # User guide
├── DEV_DOC.md            # Developer guide
├── secrets/              # Confidential credentials
│   ├── db_password.txt
│   ├── db_root_password.txt
│   ├── credentials.txt
│   └── wp_user_password.txt
└── srcs/
    ├── .env              # Configuration variables
    ├── docker-compose.yml # Service definitions
    └── requirements/     # Dockerfiles and configs
        ├── mariadb/
        ├── nginx/
        └── wordpress/
```

### Startup Sequence

1. **MariaDB starts first** - Initializes database and users
2. **WordPress waits for MariaDB** - Checks connectivity (30 sec timeout)
3. **WordPress installs** - Downloads WordPress files, creates wp-config.php, initializes database
4. **WordPress creates users** - Admin user and regular user
5. **Nginx starts** - Generates SSL certificate, proxies to WordPress
6. **All services running** - Stack is ready for access

---

## 7. Development Tips

### Modifying WordPress files

Edit files in the WordPress volume:

```bash
docker exec wordpress sh -c "echo 'test' > /var/www/html/test.php"
```

Or modify through WordPress admin interface.

### Checking service health

Watch logs in real-time:

```bash
make logs
# or press Ctrl+C to stop
```

### Making changes to Dockerfiles

If you modify any Dockerfile in `srcs/requirements/`:

```bash
make re
```

This rebuilds images and restarts containers.

### Testing database connectivity from host

From your host machine, test database:

```bash
# Install mariadb-client if needed
sudo apt install mariadb-client

# Connect through Docker
docker exec mariadb mariadb -u root -p wordpress -e "SELECT COUNT(*) FROM wp_users;"
```

### Checking environment variables inside containers

```bash
docker exec wordpress printenv | grep WORDPRESS
docker exec mariadb printenv | grep MYSQL
```

### Monitoring resource usage

Watch container resource consumption:

```bash
docker stats
```

---

## 8. Common Development Workflows

### Fresh start

```bash
make fclean
make re
```

### Quick restart (keeps data)

```bash
make down
make up
```

### Rebuild without data loss

```bash
make clean
make build
make up
```

### View live logs

```bash
make logs
```

### Full cleanup and start fresh

```bash
make fclean
docker system prune -af
make re
```

---
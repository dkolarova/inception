# USER_DOC

## Overview

The Inception stack provides a complete WordPress infrastructure with the following services:

- **Nginx** - Reverse proxy and HTTPS web server (port 443)
- **WordPress** - Content management system with PHP-FPM backend
- **MariaDB** - Relational database engine for WordPress data

This documentation explains how to:

- Understand what services are provided by the stack
- Start and stop the project
- Configure your domain
- Access the website and the WordPress administration panel
- Locate and manage credentials
- Check that the services are running correctly

---

## Domain Configuration

### Configure your hosts file

The Inception project uses a domain name to access WordPress. You must add this to your `/etc/hosts` file:

```bash
sudo nano /etc/hosts
```

Add the following line:

```text
127.0.0.1 dkolarov.42.fr
```

**Note**: Replace `dkolarov` with your actual username if the domain is different.

Alternatively, use:

```bash
sudo bash -c 'echo "127.0.0.1 dkolarov.42.fr" >> /etc/hosts'
```

### Verify domain resolution

```bash
ping dkolarov.42.fr
```

You should see responses from `127.0.0.1`.

---

## Starting the Project

### Start all services

```bash
make
```

### Stop all services

```bash
make down
```

---

## Accessing the Website

### Main website

Once the domain is configured and services are running, open your browser and navigate to:

```text
https://dkolarov.42.fr
```

**Note**: Replace `dkolarov` with your username.

You may see a browser warning about the SSL certificate (because it's self-signed). This is normal for development. Click "Advanced" and proceed to the site.

### WordPress Administration Panel

Access the WordPress admin dashboard at:

```text
https://dkolarov.42.fr/wp-admin/
```

**Credentials** are available in the `secrets/credentials.txt` file:
- Username: See `.env` file (`WP_ADMIN_USER` variable)
- Password: See `secrets/credentials.txt`

---

## Credentials Management

### Where credentials are stored

**Configuration variables** (`.env` file):
```text
srcs/.env
```

**Secret credentials** (individual files in `secrets/` directory):
```text
secrets/credentials.txt       # WordPress admin password
secrets/db_password.txt       # MariaDB user password
secrets/db_root_password.txt  # MariaDB root password
```

### WordPress Credentials

- **Admin Username**: Check `srcs/.env` variable `WP_ADMIN_USER`
- **Admin Password**: Check `secrets/credentials.txt`
- **Regular User**: Check `srcs/.env` variable `WP_USER`
- **Regular User Password**: Check `secrets/wp_user_password.txt`

### Database Credentials

- **Database Name**: Check `srcs/.env` variable `MYSQL_DATABASE`
- **DB User**: Check `srcs/.env` variable `MYSQL_USER`
- **DB Password**: Check `secrets/db_password.txt`
- **DB Root Password**: Check `secrets/db_root_password.txt`

### Security Warning

**⚠️ IMPORTANT**: Do not commit secret files or `.env` to Git. These are already in `.gitignore` and contain sensitive information.

---

## Checking Services

### Check running containers

```bash
docker ps
```

### Check container status

```bash
docker compose ps
```

All services should display:

```text
Up
```

or

```text
healthy
```

### Check logs

```bash
docker compose logs
```

### Check logs for one service

```bash
docker compose logs SERVICE_NAME
```

---

## Useful Commands

### Restart services

```bash
docker compose restart
```

### Rebuild containers

```bash
docker compose up --build
```

### Remove containers

```bash
docker compose down
```
*This project has been created as part of the 42 curriculum by **dkolarov**.*
# Inception Project


## Description

Inception is a Docker-based infrastructure project that sets up a complete WordPress application stack using containerization. The project demonstrates the practical use of Docker containers and networking to create a scalable, isolated, and reproducible development environment.

**Project Goal**: Build a multi-container application using Docker Compose that runs:
- **Nginx** - Reverse proxy and web server
- **WordPress** - Content management system
- **MariaDB** - Database server

This project teaches essential DevOps concepts including containerization, image management, container networking, persistent data storage, and secure credential handling.

## Instructions

### Prerequisites

- Docker or Podman installed
- Make utility
- A Linux-based system

### Setup

1. **Clone the repository** and navigate to the project directory:
   ```bash
   cd ~/inception
   ```

2. **Create environment variables file** at `srcs/.env`:
   ```bash
   # Domain configuration
   DOMAIN_NAME=your_domain.local
   
   # MariaDB configuration
   DB_NAME=wordpress_db
   DB_USER=wordpress_user
   DB_PASSWORD=<password_from_secrets/db_password.txt>
   DB_ROOT_PASSWORD=<password_from_secrets/db_root_password.txt>
   
   # WordPress configuration
   WP_TITLE=Your Site Title
   WP_ADMIN_USER=admin
   WP_ADMIN_PASSWORD=<password_from_secrets/wp_user_password.txt>
   WP_ADMIN_EMAIL=admin@your_domain.local
   WP_USER=user
   WP_USER_PASSWORD=<password_from_secrets/wp_user_password.txt>
   WP_USER_EMAIL=user@your_domain.local
   ```

3. **Configure your hosts file**:
   ```bash
   sudo nano /etc/hosts
   # Add: 127.0.0.1 your_domain.local
   ```

### Building and Running

- **Build all containers**:
  ```bash
  make build
  ```

- **Start the stack**:
  ```bash
  make up
  ```

- **Stop the stack**:
  ```bash
  make down
  ```

- **Clean up (remove volumes and containers)**:
  ```bash
  make fclean
  ```

- **Full rebuild**:
  ```bash
  make re
  ```

Access WordPress at `https://your_domain.local` once the stack is running.

## Project Description

### Docker Architecture

This project demonstrates enterprise-grade containerization by separating concerns into three independent services:

1. **MariaDB Container**: Provides persistent database storage for WordPress
2. **WordPress Container**: Runs PHP-FPM backend with WordPress application
3. **Nginx Container**: Acts as reverse proxy and serves static content

### Design Choices

- **Multi-container architecture** ensures modularity and scalability
- **Docker Compose** provides orchestration and service discovery
- **Custom Dockerfiles** allow fine-tuned configurations for each service
- **Environment variables** manage configuration across environments
- **Volumes and bind mounts** enable data persistence and local development

### Technical Comparisons

#### Virtual Machines vs Docker

| Aspect | Virtual Machines | Docker Containers |
|--------|-----------------|-------------------|
| **Resource Usage** | Heavy (full OS per VM) | Lightweight (shared kernel) |
| **Startup Time** | Minutes | Seconds |
| **Isolation** | Full isolation | Process-level isolation |
| **Use Case** | Complete OS isolation, legacy apps | Microservices, development, scaling |
| **Overhead** | Significant (OS for each instance) | Minimal (few MB per container) |

**Why Docker for Inception**: Containers provide sufficient isolation for development while consuming minimal resources, making them ideal for learning and testing multi-service architectures.

#### Secrets vs Environment Variables

| Approach | Secrets | Environment Variables |
|----------|---------|----------------------|
| **Storage** | External secret management systems, files | .env files, runtime variables |
| **Security** | Encrypted, audit-logged | Plain text (potential exposure) |
| **Scalability** | Enterprise-grade (vaults, K8s secrets) | Simple, local-only |
| **Flexibility** | Dynamic updates without restart | Static, requires rebuild |
| **Complexity** | Higher setup overhead | Simple to implement |

**Our Implementation**: Uses both approaches:
- **Secrets files** (`secrets/`) for production-like credentials
- **Environment variables** (.env) for service configuration
- Best practice: Never commit secrets to git; manage via secure infrastructure

#### Docker Network vs Host Network

| Mode | Docker Network | Host Network |
|------|----------------|--------------|
| **Isolation** | Isolated network namespace | Shared host network |
| **DNS** | Built-in service discovery | Host DNS resolution |
| **Port Binding** | Explicit port mapping required | Direct port access |
| **Security** | Container-to-host firewall | Direct access to host ports |
| **Performance** | Slight overhead | Minimal overhead |

**Our Implementation**: Uses bridge network (default Docker network):
- Services communicate via hostnames (nginx, wordpress, mariadb)
- Port 443 exposed for HTTPS access
- Services isolated from direct host port interference

#### Docker Volumes vs Bind Mounts

| Type | Volumes | Bind Mounts |
|------|---------|------------|
| **Management** | Docker-managed | Host filesystem path |
| **Portability** | High (managed by Docker) | Depends on host path |
| **Performance** | Optimized for containers | Native filesystem speed |
| **Use Case** | Production data, database stores | Development, source code |
| **Permissions** | Docker manages | Host filesystem controls |

**Our Implementation**: Uses volumes for data persistence:
- **Database volume**: Persistent MariaDB data across container restarts
- **WordPress volume**: Persistent uploads and configurations
- **Bind mounts**: Configuration files mounted from `srcs/requirements/*/conf/`

## Resources

### Documentation
- [Docker Official Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [MariaDB Docker Hub](https://hub.docker.com/_/mariadb)
- [WordPress Docker Hub](https://hub.docker.com/_/wordpress)
- [Nginx Documentation](https://nginx.org/en/docs/)

### Tutorials & Articles
- [Docker Networking Guide](https://docs.docker.com/network/)
- [Docker Storage Drivers](https://docs.docker.com/storage/)
- [WordPress with Docker Compose](https://docs.docker.com/compose/wordpress/)
- [Nginx as Reverse Proxy](https://docs.nginx.com/nginx/admin-guide/web-server/reverse-proxy/)

### Learning Resources
- Docker & Kubernetes Official Learning Path
- Linux Container Fundamentals

### AI Usage

AI was utilized for the following aspects of this project:


- **Docker Configuration**: Assisted in understanding multi-container orchestration patterns and best practices
- **Technical Explanations**: Provided detailed comparisons between Docker approaches (volumes vs bind mounts, networks, etc.)
- **Code Review**: Helped validate Dockerfile configurations and entrypoint scripts

AI was **NOT** used for core logic, build scripts, or direct container implementations—those were developed through hands-on learning and experimentation.

## Troubleshooting

### Container fails to start
- Check `.env` file exists in `srcs/` directory
- Verify all required passwords are set in `.env`
- Check Docker daemon is running: `docker info`

### Permission denied errors
- The Makefile may use `sudo docker` if socket permissions are denied
- Add your user to the docker group: `sudo usermod -aG docker $USER`

### Port already in use
- Check what's using port 443: `sudo lsof -i :443`
- Modify nginx configuration in `srcs/requirements/nginx/conf/default.conf.template`

### Database connection issues
- Ensure MariaDB container is running: `docker ps | grep mariadb`
- Check environment variables match between containers
- Verify network connectivity: `docker network inspect inception_default`

---


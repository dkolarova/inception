NAME := inception

COMPOSE_FILE := srcs/docker-compose.yml
DATA_DIR := $(HOME)/data

DOCKER_COMPOSE := docker compose -f $(COMPOSE_FILE)

.PHONY: all up down build clean fclean re init-data logs

all: up

# ---------------------------------------------------------
# Create required host directories for volumes
# ---------------------------------------------------------
init-data:
	mkdir -p $(DATA_DIR)/wordpress
	mkdir -p $(DATA_DIR)/mariadb

# ---------------------------------------------------------
# Build images
# ---------------------------------------------------------
build: init-data
	$(DOCKER_COMPOSE) build

# ---------------------------------------------------------
# Start containers
# ---------------------------------------------------------
up: init-data
	$(DOCKER_COMPOSE) up -d --build

# ---------------------------------------------------------
# Stop containers
# ---------------------------------------------------------
down:
	$(DOCKER_COMPOSE) down

# ---------------------------------------------------------
# Remove containers + orphans
# ---------------------------------------------------------
clean:
	$(DOCKER_COMPOSE) down --remove-orphans

# ---------------------------------------------------------
# Full clean: containers + volumes data on host
# ---------------------------------------------------------
fclean: clean
	-docker volume rm wordpress_data mariadb_data 2>/dev/null || true
	-rm -rf $(DATA_DIR)/wordpress $(DATA_DIR)/mariadb 2>/dev/null || true

# ---------------------------------------------------------
# Rebuild everything from scratch
# ---------------------------------------------------------
re: fclean up

# ---------------------------------------------------------
# View logs
# ---------------------------------------------------------
logs:
	$(DOCKER_COMPOSE) logs -f
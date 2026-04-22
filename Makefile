NAME = inception

COMPOSE = docker compose -f srcs/docker-compose.yml

all:
	@mkdir -p /home/dkolarov/data/mariadb
	@mkdir -p /home/dkolarov/data/wordpress
	$(COMPOSE) up --build

up:
	$(COMPOSE) up

build:
	$(COMPOSE) build

down:
	$(COMPOSE) down

clean:
	$(COMPOSE) down -v

fclean: clean
	docker system prune -af

re: fclean all
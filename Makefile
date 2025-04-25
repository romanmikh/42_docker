LOGIN = $(shell whoami)

# Project paths
DOCKER_DIR = srcs
COMPOSE = docker compose -f $(DOCKER_DIR)/docker-compose.yml
BUILD = $(COMPOSE) build
UP = $(COMPOSE) up
DOWN = $(COMPOSE) down
RMV = docker volume rm -f
VOLUMES = $(shell docker volume ls -qf name=srcs_)
IMAGES = $(shell docker images -q srcs-* 2>/dev/null)
SECRETS = $(shell docker secret ls -q 2>/dev/null)

create-folders: #-p for safety, @ makes output silent
	@mkdir -p /home/$(LOGIN)/data/mariadb
	@mkdir -p /home/$(LOGIN)/data/wordpress

# Build all images
build:
	$(BUILD)

# Run all containers
up: create-folders
	$(UP)

# Stop all containers
down:
	$(DOWN)

# Nuke all volumes
clean:
	$(DOWN)
	$(RMV) $(VOLUMES)

# Nuke all volumes and images
fclean: down
	$(RMV) $(VOLUMES)
	-docker rmi -f $(IMAGES)
	@rm -rf /home/$(LOGIN)/data

# Full reset
re: fclean build up

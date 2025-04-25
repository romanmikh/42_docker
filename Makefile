LOGIN = $(shell whoami)

# Project paths
DOCKER_DIR = srcs
COMPOSE = docker compose -f $(DOCKER_DIR)/docker-compose.yml
BUILD = $(COMPOSE) build
UP = $(COMPOSE) up
DOWN = $(COMPOSE) down
RMV = docker volume rm -f
VOLUMES = $(shell docker volume ls -qf name=srcs_)

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

# Full reset
re: clean build up

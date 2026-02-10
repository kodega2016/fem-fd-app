MIGRATION_DIR := migrations
AWS_ACCOUNT_ID :=021135267910
AWS_DEFAULT_REGION:=us-east-1
AWS_ECR_DOMAIN:=$(AWS_ACCOUNT_ID).dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com
GIT_SHA:=$(shell git rev-parse HEAD)
BUILD_IMAGE:=${AWS_ECR_DOMAIN}/fem-fd-app
BUILD_TAG:=$(if $(BUILD_TAG),$(BUILD_TAG),latest)
DOCKERIZE_HOST:=$(shell echo $(GOOSE_DBSTRING) | cut -d "@" -f 2 | cut -d ":" -f 1)
DOCKERIZE_URL:=tcp://$(if $(DOCKERIZE_HOST),$(DOCKERIZE_HOST):5432,localhost:5432)
.DEFAULT_GOAL:=build

build:
	go build -o ./goals main.go

build-image:
	docker buildx build \
		--platform "linux/amd64" \
		--tag "${BUILD_IMAGE}:${GIT_SHA}-build" \
		--target build \
		.

	docker buildx build \
		--cache-from "$(BUILD_IMAGE):$(GIT_SHA)-build" \
		--platform "linux/amd64" \
		--tag "${BUILD_IMAGE}:latest" \
		.
build-image-login:
	aws ecr get-login-password \
		--region us-east-1 | docker login \
		--username AWS \
		--password-stdin \
		$(AWS_ECR_DOMAIN)

build-image-push: build-image-login build-image
	docker image push  $(BUILD_IMAGE):$(GIT_SHA)

build-image-pull:
	docker image pull $(BUILD_IMAGE):$(GIT_SHA)

build-image-migrate:
	docker container run \
		--entrypoint "dockerize" \
		--network "host" \
		--rm \
		$(BUILD_IMAGE):$(GIT_SHA) \
		-timeout 30s \
		-wait \
		$(DOCKERIZE_URL)
	docker container run \
		--entrypoint "goose" \
		--env "GOOSE_DBSTRING" \
		--env "GOOSE_DRIVER" \
		--network "host" \
		--rm \
		$(BUILD_IMAGE):$(GIT_SHA) \
		-dir $(MIGRATION_DIR) status
	docker container run \
		--entrypoint "goose" \
		--env "GOOSE_DBSTRING" \
		--env "GOOSE_DRIVER" \
		--network "host" \
		--rm \
		$(BUILD_IMAGE):$(GIT_SHA) \
		-dir $(MIGRATION_DIR) validate
	docker container run \
		--entrypoint "goose" \
		--env "GOOSE_DBSTRING" \
		--env "GOOSE_DRIVER" \
		--network "host" \
		--rm \
		$(BUILD_IMAGE):$(GIT_SHA) \
		-dir $(MIGRATION_DIR) up

build-image-promote:
	docker image tag $(BUILD_IMAGE):$(GIT_SHA) $(BUILD_IMAGE):$(BUILD_TAG)
	docker image push $(BUILD_IMAGE):$(BUILD_TAG)

down:
	docker compose down --remove-orphans --volumes

up: down
	docker compose up --detach

migrate:
	goose -dir "$(MIGRATION_DIR)" up

migrate-status:
	goose -dir "$(MIGRATION_DIR)" status

migrate-validate:
	goose -dir "$(MIGRATION_DIR)" validate

start: build
	./goals


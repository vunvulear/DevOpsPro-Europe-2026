SHELL := /usr/bin/env bash

APP_DIR  := App
TEST_DIR := App_Test
IMAGE    := brasov-sunset-api:local

.PHONY: help install test test-ci lint docker-build docker-run \
        tf-fmt tf-validate-dev tf-validate-prod tf-plan-dev tf-apply-dev clean

help:
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | awk 'BEGIN{FS=":.*?## "}{printf "  %-22s %s\n", $$1, $$2}'

install:  ## Install app + test deps
	cd $(APP_DIR)  && npm install --no-audit --no-fund
	cd $(TEST_DIR) && npm install --no-audit --no-fund

test: install  ## Run jest
	cd $(TEST_DIR) && npm test

test-ci: install  ## Run jest with coverage and junit
	cd $(TEST_DIR) && npm run test:ci

docker-build:  ## Build container image
	docker build --build-arg APP_VERSION=local -t $(IMAGE) -f $(APP_DIR)/Dockerfile $(APP_DIR)

docker-run: docker-build  ## Run container locally on :3000
	docker rm -f brasov-sunset-api-local >/dev/null 2>&1 || true
	docker run -d --name brasov-sunset-api-local -p 3000:3000 $(IMAGE)
	@sleep 2 && curl -fsS http://localhost:3000/healthz | head

tf-fmt:  ## terraform fmt -recursive
	terraform -chdir=infra/terraform fmt -recursive

tf-validate-dev:  ## terraform validate (dev)
	terraform -chdir=infra/terraform/envs/dev init -backend=false -input=false
	terraform -chdir=infra/terraform/envs/dev validate

tf-validate-prod:  ## terraform validate (prod)
	terraform -chdir=infra/terraform/envs/prod init -backend=false -input=false
	terraform -chdir=infra/terraform/envs/prod validate

tf-plan-dev:  ## terraform plan against the live dev backend (requires az login)
	terraform -chdir=infra/terraform/envs/dev init -backend-config=backend.hcl -input=false
	terraform -chdir=infra/terraform/envs/dev plan -var-file=terraform.tfvars

tf-apply-dev:  ## terraform apply (dev)
	terraform -chdir=infra/terraform/envs/dev apply -var-file=terraform.tfvars

clean:
	docker rm -f brasov-sunset-api-local >/dev/null 2>&1 || true
	rm -rf $(TEST_DIR)/coverage $(TEST_DIR)/reports

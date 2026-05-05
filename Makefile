SHELL := /usr/bin/env bash

APP_DIR  := App
TEST_DIR := App_Test

.PHONY: help install run test test-ci package \
        tf-fmt tf-validate-dev tf-validate-prod tf-plan-dev tf-apply-dev clean

help:
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | awk 'BEGIN{FS=":.*?## "}{printf "  %-22s %s\n", $$1, $$2}'

install:  ## Install app + test deps
	cd $(APP_DIR)  && npm install --no-audit --no-fund
	cd $(TEST_DIR) && npm install --no-audit --no-fund

run: install  ## Run the API locally on :3000
	cd $(APP_DIR) && node server.js

test: install  ## Run jest
	cd $(TEST_DIR) && npm test

test-ci: install  ## Run jest with coverage and junit
	cd $(TEST_DIR) && npm run test:ci

package: install  ## Build the deployable zip identical to CI
	cd $(APP_DIR) && npm install --omit=dev --no-audit --no-fund
	cd $(APP_DIR) && zip -r ../brasov-sunset-api-local.zip server.js package.json package-lock.json node_modules

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
	rm -f brasov-sunset-api-local.zip
	rm -rf $(TEST_DIR)/coverage $(TEST_DIR)/reports

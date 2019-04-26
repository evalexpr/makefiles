# Executables
COMPOSER := composer
PHPCS := ./vendor/bin/phpcs
PHP := php
PLINT := ./vendor/bin/parallel-lint 
RM := /bin/rm
RMT := ./vendor/bin/RMT

# Naming and directories
NAME := $(shell echo $${PWD\#\#*/})
VERSION := $(shell cat VERSION.txt)
GITCOMMIT := $(shell git rev-parse --short HEAD)

# Files
PHP_SRC := config public src templates tests

.PHONY: all
all: lint test vendor ## Lints tests and vendors

vendor: composer.json composer.lock ## Validate and install dependencies
	$(COMPOSER) validate --no-check-publish
	$(COMPOSER) install

.PHONY: release
release: test vendor ## Runs tests and vendors dependncies, then creates a new release using RMT
	$(RMT) release

.PHONY: lint
lint: ## Lints files using parallel-lint, phpcs, phpmd, phpstan, and psalm
	$(PLINT) $(PHP_SRC)
	$(PHPCS) -p --colors
	$(PHPMD) src/ text phpmd.xml
	$(PHPSTAN) analyse --level=7 src/
	$(PSALM)

.PHONY: test
test: ## Runs unit tests using phpunit
	$(PHPUNIT) tests/

.PHONY: clean
clean: ## Removes the build and vendor directories
	$(RM) -rf build/ vendor/

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | sed 's/^[^:]*://g' | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'


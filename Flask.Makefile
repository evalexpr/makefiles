PYTHON := python
FLASK := flask
VENV_NAME?=venv
VENV_ACTIVATE=. $(VENV_NAME)/bin/activate

.PHONY: venv
venv: $(VENV_ACTIVATE) ## Set up virtualenv and install deps
$(VENV_ACTIVATE): setup.py
	test -d $(VENV_NAME) || virtualenv -p python3 $(VENV_NAME)
	$(PYTHON) -m pip install -U pip setuptools
	$(PYTHON) -m pip install -e .[devel]
	touch $(VENV_ACTIVATE)

.PHONY: lint
lint: venv ## Run linting over the app
	$(PYTHON) -m pylint --rcfile=pylintrc app
	$(PYTHON) -m mypy --ignore-missing-imports app

.PHONY: test
test: venv ## Run the tests
	$(PYTHON) -m pytest -vv tests

.PHONY: run
run: venv ## Start the flask server
	$(FLASK) run

.PHONY: shell
shell: venv ## Run the flask shell
	$(FLASK) shell

.PHONY: help
help:
	@awk -F ':|##' '/^[^\t].+?:.*?##/ { printf "\033[36m%-30s\033[0m %s\n", $$1, $$NF }' $(MAKEFILE_LIST)


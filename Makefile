MNG:=uv run python manage.py

.PHONY: server
server: .env
	@$(MNG) runserver

.PHONY: db
db:
	@$(MNG) migrate

.PHONY: test
test:
	@uv run pytest

.PHONY: test-cov
test-cov:
	@uv run pytest --cov-report=term --cov-report=html

.PHONY: test-cov-xml
test-cov-xml:
	@uv run pytest --cov-report=xml

requirements.txt: uv.lock
	@uv export --frozen --output-file=$@

.env: .env.example
	@test -r .env \
		&& echo "Your .env is older than .env.example" \
		|| cp .env.example .env

DOCKER?=docker
IMAGE_REPO:=histrio/idontneedit
IMAGE_TAG?=$(shell git rev-parse --short HEAD)
LATEST_TAG?=latest

.PHONY: image.build
image.build:
	@$(DOCKER) build -t $(IMAGE_REPO):$(IMAGE_TAG) -t $(IMAGE_REPO):$(LATEST_TAG) .

.PHONY: image.push
image.push:
	@$(DOCKER) push $(IMAGE_REPO):$(IMAGE_TAG)
	@$(DOCKER) push $(IMAGE_REPO):$(LATEST_TAG)

DEV_APP_COMMAND = docker-compose -f docker-compose.development.yml run --rm app
TEST_APP_COMMAND = docker-compose -f docker-compose.test.yml run --rm test_app
DOCKER_LOGIN_COMMAND = docker login -u $(DOCKER_USER) -p $(DOCKER_PASS)
LAST_COMMIT_TAG = $$(git log -1 --pretty=%H)

dev_run:
	@docker-compose -f docker-compose.development.yml up

dev_stop:
	@docker-compose -f docker-compose.development.yml down

dev_setup:
	@$(DEV_APP_COMMAND) bundle
	@$(DEV_APP_COMMAND) yarn
	@$(DEV_APP_COMMAND) rails db:setup

dev_run_lint:
	@$(DEV_APP_COMMAND) rails lint:all

dev_run_test:
	@$(DEV_APP_COMMAND) rails test

dev_shell:
	@$(DEV_APP_COMMAND) bash

test_run:
	@$(TEST_APP_COMMAND) rails lint:all
	@$(TEST_APP_COMMAND) rails test

test_setup:
	@$(TEST_APP_COMMAND) bundle install --without development
	@$(TEST_APP_COMMAND) yarn
	@$(TEST_APP_COMMAND) rails db:setup

build_base:
	@docker build - < base.Dockerfile -t blackcandy/base
	@docker tag blackcandy/base blackcandy/base:$(LAST_COMMIT_TAG)
	@$(DOCKER_LOGIN_COMMAND)
	@docker push blackcandy/base

build_web:
	@docker build -f web.Dockerfile -t blackcandy/web .
	@docker tag blackcandy/web blackcandy/web:$(LAST_COMMIT_TAG)
	@$(DOCKER_LOGIN_COMMAND)
	@docker push blackcandy/web

build:
	@docker build -t blackcandy/blackcandy .
	@docker tag blackcandy/blackcandy blackcandy/blackcandy:$$(cat VERSION)
	@$(DOCKER_LOGIN_COMMAND)
	@docker push blackcandy/blackcandy:$$(cat VERSION)

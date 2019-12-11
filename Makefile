DEV_APP_COMMAND = docker-compose -f docker-compose.development.yml run --rm app
TEST_APP_COMMAND = docker-compose -f docker-compose.test.yml run --rm test_app
PRODUCTION_APP_COMMAND = docker-compose run --rm app
DOCKER_LOGIN_COMMAND = docker login -u $(DOCKER_USER) -p $(DOCKER_PASS)

dev_run:
	@docker-compose -f docker-compose.development.yml up

dev_stop:
	@docker-compose -f docker-compose.development.yml down

dev_setup:
	@$(DEV_APP_COMMAND) bundle
	@$(DEV_APP_COMMAND) yarn
	@$(DEV_APP_COMMAND) rails db:setup

dev_shell:
	@$(DEV_APP_COMMAND) bash

test_run:
	@$(TEST_APP_COMMAND) rails test

test_run_lint:
	@$(TEST_APP_COMMAND) rails lint:all

test_run_brakeman:
	@$(TEST_APP_COMMAND) brakeman

test_shell:
	@$(TEST_APP_COMMAND) bash

test_setup:
	@$(TEST_APP_COMMAND) bundle install --without development
	@$(TEST_APP_COMMAND) yarn
	@$(TEST_APP_COMMAND) rails db:setup

production_setup:
	@$(PRODUCTION_APP_COMMAND) rails db:setup
	@$(PRODUCTION_APP_COMMAND) rails db:seed

production_run:
	docker/build_nginx_conf.sh
	@docker-compose up -d

production_stop:
	@docker-compose down

production_restart:
	@make production_stop
	@make production_run

production_set_ssl:
	docker/set_ssl.sh

production_update:
	@docker pull blackcandy/blackcandy
	@make production_restart

build_base:
	@docker build - < base.Dockerfile -t blackcandy/base
	@docker tag blackcandy/base blackcandy/base:$$(cat BASE_VERSION)
	@$(DOCKER_LOGIN_COMMAND)
	@docker push blackcandy/base:$$(cat BASE_VERSION)
	@docker push blackcandy/base:latest

build:
	@docker build -t blackcandy/blackcandy .
	@docker tag blackcandy/blackcandy blackcandy/blackcandy:$$(cat VERSION)
	@$(DOCKER_LOGIN_COMMAND)
	@docker push blackcandy/blackcandy:$$(cat VERSION)
	@docker push blackcandy/blackcandy:latest

DEV_APP_COMMAND = docker-compose -f docker-compose.dev.yml run --rm app
PRODUCTION_APP_COMMAND = docker-compose run --rm app
DOCKER_LOGIN_COMMAND = docker login -u $(DOCKER_USER) -p $(DOCKER_PASS)

dev_run:
	@docker-compose -f docker-compose.dev.yml up --build

dev_stop:
	@docker-compose -f docker-compose.dev.yml down

dev_setup:
	@$(DEV_APP_COMMAND) bundle
	@$(DEV_APP_COMMAND) yarn
	@$(DEV_APP_COMMAND) rails db:setup

dev_shell:
	@$(DEV_APP_COMMAND) sh

test_run:
	@$(DEV_APP_COMMAND) rails test RAILS_ENV=test

lint_run:
	@$(DEV_APP_COMMAND) rails lint:all

brakeman_run:
	@$(DEV_APP_COMMAND) brakeman

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
	@docker pull blackcandy/blackcandy:$$(cat VERSION)
	@$(PRODUCTION_APP_COMMAND) rails db:migrate
	@make production_restart

build:
	@DOCKER_BUILDKIT=1 docker build --target production -t blackcandy/blackcandy .
	@docker tag blackcandy/blackcandy blackcandy/blackcandy:$$(cat VERSION)
	@$(DOCKER_LOGIN_COMMAND)
	@docker push blackcandy/blackcandy:$$(cat VERSION)
	@docker push blackcandy/blackcandy:latest

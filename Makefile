APP_COMMAND = docker-compose -f docker-compose.dev.yml run --rm app

dev_run:
	@docker-compose -f docker-compose.dev.yml up --build

dev_stop:
	@docker-compose -f docker-compose.dev.yml down

dev_setup:
	@$(APP_COMMAND) bundle
	@$(APP_COMMAND) yarn
	@$(APP_COMMAND) rails db:setup

dev_shell:
	@$(APP_COMMAND) sh

test_run:
	@$(APP_COMMAND) rails test RAILS_ENV=test

lint_run:
	@$(APP_COMMAND) rails lint:all

brakeman_run:
	@$(APP_COMMAND) brakeman

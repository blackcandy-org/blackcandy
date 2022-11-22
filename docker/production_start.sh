#!/bin/sh

# Prepare database. Beacuse when the database adapter is sqlite, the task 'db:prepare' won't run 'db:seed'.
# So add 'db:seed' task explicitly to avoit it. See https://github.com/rails/rails/issues/36383
rails db:prepare && rails db:seed

bundle exec puma -C config/puma.rb

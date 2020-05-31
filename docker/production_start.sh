#!/bin/sh

# Prepare Database
rails db:prepare

bundle exec puma -C config/puma.rb

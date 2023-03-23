#!/bin/sh

rails docker:db_prepare

bundle exec puma -C config/puma.rb

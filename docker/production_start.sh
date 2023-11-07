#!/bin/sh

rails db:prepare
bundle exec puma -C config/puma.rb
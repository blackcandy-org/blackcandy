#!/bin/sh

docker-compose run --rm \
  -e BLACK_CANDY_DOMAIN_NAME=${BLACK_CANDY_DOMAIN_NAME} \
  -e BLACK_CANDY_USE_SSL=${BLACK_CANDY_USE_SSL} \
  -v "$PWD"/config/nginx:/usr/src/app \
  -w /usr/src/app \
  app erb nginx.conf.erb > config/nginx/nginx.conf

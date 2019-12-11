#!/bin/sh

docker-compose run --rm certbot renew --webroot -w /var/www/certbot --quiet

docker-compose kill -s HUP web

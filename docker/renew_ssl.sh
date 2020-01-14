#!/bin/sh

/usr/local/bin/docker-compose run --rm certbot renew --webroot -w /var/www/certbot --quiet

/usr/local/bin/docker-compose kill -s HUP web

#!/bin/sh

docker-compose run --rm certbot certonly --webroot \
--email ${BLACK_CANDY_DOMAIN_EMAIL} --agree-tos --no-eff-email \
--webroot-path=/var/www/certbot \
-d ${BLACK_CANDY_DOMAIN_NAME}

docker-compose run --rm  --entrypoint "openssl dhparam -out /etc/letsencrypt/ssl-dhparams.pem 2048" certbot

(crontab -l ; echo "0 0 * * 0 cd '$PWD' && docker/renew_ssl.sh")| crontab -

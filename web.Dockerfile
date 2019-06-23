FROM blackcandy/blackcandy:latest as app
FROM nginx:1.16-alpine

WORKDIR /var/www/black_candy

COPY ./config/nginx/ /etc/nginx
COPY --from=app /app/public /var/www/black_candy/public

EXPOSE 80

CMD [ "nginx", "-g", "daemon off;" ]

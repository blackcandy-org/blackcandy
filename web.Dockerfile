FROM blackcandy/blackcandy:latest as app
FROM nginx:1.16-alpine

WORKDIR /var/www/black_candy

COPY ./config/nginx/nginx.conf /etc/nginx/nginx.conf
COPY --from=app /app/public /var/www/black_candy/public

EXPOSE 80 443

CMD [ "nginx", "-g", "daemon off;" ]

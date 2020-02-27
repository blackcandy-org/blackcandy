FROM blackcandy/blackcandy:1.0.4 as app
FROM nginx:1.16-alpine

WORKDIR /var/www/black_candy

COPY --from=app /app/public /var/www/black_candy/public

EXPOSE 80 443

CMD [ "nginx", "-g", "daemon off;" ]

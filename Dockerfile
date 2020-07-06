FROM ruby:2.6.6-alpine AS base

ENV LANG C.UTF-8

LABEL maintainer="Aidewoode@github.com/aidewoode"

RUN apk add --no-cache \
  tzdata \
  postgresql-dev \
  git \
  nodejs \
  yarn \
  imagemagick \
  ffmpeg

WORKDIR /app

FROM base AS dev

RUN apk add --no-cache build-base

FROM base AS production

ENV RAILS_ENV production
ENV NODE_ENV production

ADD . /app

RUN apk add --no-cache --virtual .build-deps build-base \
  && bundle install --without development test \
  && rm -rf /usr/local/bundle/cache/*.gem \
  && apk del --no-network .build-deps


RUN bundle exec rails assets:precompile SECRET_KEY_BASE=fake_secure_for_compile \
  && yarn cache clean \
  && rm -rf node_modules tmp/cache/* /tmp/*

RUN apk add --no-cache nginx \
  && cp config/nginx/nginx.conf /etc/nginx/nginx.conf

EXPOSE 3000

CMD ["docker/production_start.sh"]

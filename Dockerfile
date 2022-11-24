FROM ruby:3.1.2-alpine

ENV LANG C.UTF-8
ENV RAILS_ENV production
ENV NODE_ENV production
ENV RAILS_SERVE_STATIC_FILES true

LABEL maintainer="Aidewoode@github.com/aidewoode"

RUN apk add --no-cache \
  tzdata \
  postgresql-dev \
  git \
  nodejs \
  yarn \
  imagemagick \
  ffmpeg \
  gcompat

WORKDIR /app

ADD . /app

RUN apk add --no-cache --virtual .build-deps build-base \
  && bundle config --local without 'development test' \
  && bundle install \
  && rm -rf /usr/local/bundle/cache/*.gem \
  && apk del --no-network .build-deps


RUN bundle exec rails assets:precompile SECRET_KEY_BASE=fake_secure_for_compile \
  && yarn cache clean \
  && rm -rf node_modules tmp/cache/* /tmp/*

ENTRYPOINT ["docker/entrypoint.sh"]

EXPOSE 3000

CMD ["docker/production_start.sh"]

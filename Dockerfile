FROM ruby:2.6.6-alpine AS base

ENV APP_USER user
ENV LANG C.UTF-8

LABEL maintainer="Aidewoode@github.com/aidewoode"

RUN apk add --no-cache \
  tzdata \
  postgresql-dev \
  git \
  nodejs \
  yarn \
  imagemagick \
  taglib-dev \
  ffmpeg \
  curl

# Tool to propagate singals from the container to the app
# Repo: https://github.com/fpco/pid1
# Explanation: https://www.fpcomplete.com/blog/2016/10/docker-demons-pid1-orphans-zombies-signals
ENV PID1_VERSION=0.1.2.0
RUN curl -sSL "https://github.com/fpco/pid1/releases/download/v${PID1_VERSION}/pid1-${PID1_VERSION}-linux-x86_64.tar.gz" | tar xzf - -C /usr/local \
    && chown root:root /usr/local/sbin \
    && chown root:root /usr/local/sbin/pid1

# Disable documentation for Ruby gems
RUN echo 'gem: --no-rdoc --no-ri' > /etc/gemrc

# Set the entrypoint
COPY ./docker/entrypoint.sh /usr/local/bin/entrypoint
RUN chmod +x /usr/local/bin/entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint"]

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

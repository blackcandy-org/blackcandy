FROM ruby:3.1.2-alpine

LABEL maintainer="Aidewoode@github.com/aidewoode"

ENV LANG C.UTF-8
ENV RAILS_ENV production
ENV NODE_ENV production
ENV RAILS_SERVE_STATIC_FILES true
ENV NODE_VERSION 18.12.1

# build for musl-libc, not glibc (see https://github.com/sparklemotion/nokogiri/issues/2075, https://github.com/rubygems/rubygems/issues/3174)
ENV BUNDLE_FORCE_RUBY_PLATFORM 1

RUN apk add --no-cache \
  tzdata \
  curl \
  postgresql-dev \
  imagemagick \
  ffmpeg

# Install Node.js
RUN get_architecture() { \
    case $(uname -m) in \
      x86_64) echo "x64" ;; \
      aarch64) echo "arm64" ;; \
      armv7l) echo "armv7l" ;; \
      *) echo "unknown" ;; \
    esac \
  };\
  curl -s https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-$(get_architecture).tar.gz | tar xzf - -C /usr/local --strip-components=1; \
  npm install --global yarn; \
  npm cache clean


WORKDIR /app

ADD . /app

RUN apk add --no-cache --virtual .build-deps build-base \
  && bundle config --local without 'development test' \
  && bundle install \
  && rm -rf /usr/local/bundle/cache/*.gem \
  && apk del --no-network .build-deps


RUN bundle exec rails assets:precompile SECRET_KEY_BASE=fake_secure_for_compile \
  && yarn cache clean \
  && rm -rf node_modules tmp/cache/* /tmp/* yarn.lock log/production.log

ENTRYPOINT ["docker/entrypoint.sh"]

EXPOSE 3000

CMD ["docker/production_start.sh"]

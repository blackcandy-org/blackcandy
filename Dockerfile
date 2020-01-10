FROM node:10.15.0-slim as node
FROM ruby:2.6.0-slim as base

MAINTAINER Aidewoode https://github.com/aidewoode

COPY --from=node /usr/local/bin/node /usr/local/bin/node
COPY --from=node /usr/local/lib/node_modules /usr/local/lib/node_modules
COPY --from=node /usr/local/bin/npm /usr/local/bin/npm
COPY --from=node /opt/yarn-* /opt/yarn

RUN apt-get update \
  && apt-get install -y --no-install-recommends build-essential git vim libpq-dev imagemagick libtag1-dev ffmpeg \
  && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
  && ln -s /usr/local/bin/node /usr/local/bin/nodejs \
  && ln -s /opt/yarn/bin/yarn /usr/local/bin/yarn \
  && ln -s /opt/yarn/bin/yarnpkg /usr/local/bin/yarnpkg

WORKDIR /app

FROM base AS production

ENV RAILS_ENV production
ENV NODE_ENV production

ADD . /app

RUN bundle install --without development test && yarn

RUN bundle exec rails assets:precompile SECRET_KEY_BASE=fake_secure_for_compile

EXPOSE 3000

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]

FROM node:10.15.0 as node
FROM ruby:2.6.0

COPY --from=node /usr/local/bin/node /usr/local/bin/node
COPY --from=node /usr/local/lib/node_modules /usr/local/lib/node_modules
COPY --from=node /usr/local/bin/npm /usr/local/bin/npm
COPY --from=node /opt/yarn-* /opt/yarn

RUN apt-get update \
  && apt-get install -y build-essential libpq-dev imagemagick libtag1-dev ffmpeg \
  && ln -s /usr/local/bin/node /usr/local/bin/nodejs \
  && ln -s /opt/yarn/bin/yarn /usr/local/bin/yarn \
  && ln -s /opt/yarn/bin/yarnpkg /usr/local/bin/yarnpkg

WORKDIR /app

CMD ["bin/rails", "s", "-b", "0.0.0.0"]

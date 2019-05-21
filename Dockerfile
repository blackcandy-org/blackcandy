FROM blackcandy/base

ENV RAILS_ENV production

ADD . /app

RUN bundle install --without development test && yarn

RUN bundle exec rails assets:precompile

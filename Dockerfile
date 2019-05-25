FROM blackcandy/base

ENV RAILS_ENV production
ENV NODE_ENV production

ADD . /app

RUN bundle install --without development test && yarn

RUN bundle exec rails assets:precompile

EXPOSE 3000

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]

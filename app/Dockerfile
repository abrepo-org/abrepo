FROM ruby:2.7.2

#stripe CLI
RUN curl -sL https://github.com/stripe/stripe-cli/releases/download/v1.7.8/stripe_1.7.8_linux_x86_64.tar.gz | tar -xz -C /usr/bin

RUN apt-get update -qq && apt-get install -y nodejs postgresql-client sqlite3 libsqlite3-dev nano
RUN curl -sL https://deb.nodesource.com/setup_lts.x | bash -
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update && apt-get install yarn


WORKDIR /app
COPY Gemfile Gemfile.lock ./

# bundler gems
ENV BUNDLE_PATH=/app/bundler
RUN bundle install

# Webpacker & Yarn
RUN bundle exec rails webpacker:install
RUN bundle exec rails webpacker:install:react
RUN yarn install
COPY yarn.lock ./

COPY . /app

# Could put precompile in entrypoint
# not sure what happens when draining nodes and if requests might
# hit non-existent (replaced by new container) asset files
# RUN bundle exec rails webpacker:clobber
ENV RAILS_ENV=production
ENV SECRET_KEY_BASE=dummyprodprecompileonlykey
RUN bundle exec rake assets:precompile


# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 8081

# Start the main process.
CMD ["rails", "server", "-b", "0.0.0.0", "-p", "8081"]

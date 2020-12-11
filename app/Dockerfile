FROM ruby:2.7.2
RUN apt-get update -qq && apt-get install -y nodejs postgresql-client sqlite3 libsqlite3-dev
RUN curl -sL https://deb.nodesource.com/setup_lts.x | bash -
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update && apt-get install yarn

#do this first to take advantage of caching?
WORKDIR /app
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Webpacker & Yarn
RUN bundle exec rails webpacker:install
RUN yarn install
COPY yarn.lock ./

COPY . /app

# Could put precompile in entrypoint
RUN bundle exec rake assets:precompile

# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 8081

# Start the main process.
CMD ["rails", "server", "-b", "0.0.0.0", "-p", "8081"]

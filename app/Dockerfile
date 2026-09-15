ARG RUBY_VERSION=3.4.10
FROM ruby:${RUBY_VERSION}-slim-bookworm

ARG NODE_MAJOR=20
ARG STRIPE_CLI_VERSION=1.10.3

ENV BUNDLE_PATH=/usr/local/bundle \
    NODE_OPTIONS=--openssl-legacy-provider \
    PYTHON=/usr/bin/python3

# Webpacker 5 requires the OpenSSL legacy provider, so stay on Node 20 until
# the JavaScript pipeline is migrated. The project uses Yarn 1, which Corepack
# supplies without adding the deprecated Yarn APT repository.
RUN apt-get update -qq \
    && apt-get install --no-install-recommends -y \
        build-essential \
        ca-certificates \
        curl \
        gpg \
        libffi-dev \
        libpq-dev \
        pkg-config \
        postgresql-client \
        python3 \
        sqlite3 \
        libsqlite3-dev \
    && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key \
        | gpg --dearmor -o /usr/share/keyrings/nodesource.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/nodesource.gpg] https://deb.nodesource.com/node_${NODE_MAJOR}.x nodistro main" \
        > /etc/apt/sources.list.d/nodesource.list \
    && apt-get update -qq \
    && apt-get install --no-install-recommends -y nodejs \
    && corepack enable \
    && corepack prepare yarn@1.22.22 --activate \
    && curl -fsSL https://github.com/stripe/stripe-cli/releases/download/v${STRIPE_CLI_VERSION}/stripe_${STRIPE_CLI_VERSION}_linux_x86_64.tar.gz \
        | tar -xz -C /usr/local/bin \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install dependencies before application code so Docker can cache these layers.
COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile

COPY . ./

# The Webpacker configuration and React support are already checked in. Running
# the installer during an image build mutates source files and defeats caching.
# NODE_OPTIONS also remains available for Webpacker's on-demand development build.
ENV RAILS_ENV=production
RUN SECRET_KEY_BASE=dummyprodprecompileonlykey \
    bundle exec rails assets:precompile

COPY entrypoint.sh /usr/local/bin/entrypoint
RUN chmod +x /usr/local/bin/entrypoint
ENTRYPOINT ["entrypoint"]

EXPOSE 8081
CMD ["rails", "server", "-b", "0.0.0.0", "-p", "8081"]

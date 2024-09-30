# base image
FROM ruby:3.3.5-slim

ENV BUNDLE_WITHOUT="development:test"
ENV DEBIAN_FRONTEND="noninteractive"
ENV EDITOR="vim"
ENV PORT="3000"
ENV RAILS_ENV="staging"
ENV RAILS_LOG_TO_STDOUT="true"
ENV USER="deploy"
ENV USER_ID="1000"
ENV WEB_CONCURRENCY="2"
ENV HOME="/home/${USER}"
ENV APP_DIR="${HOME}/${USER}"
ENV BUN_INSTALL="${HOME}/.bun"
ENV PATH="${BUN_INSTALL}/bin:${PATH}"

RUN \
  # install debian packages
  apt-get update -qq && \
  apt-get upgrade -y && \
  apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    cron \
    curl \
    gpg \
    gpg-agent \
    libpq-dev \
    orphan-sysvinit-scripts \
    pkg-config \
    postgresql-client \
    rsyslog \
    unzip \
    vim \
    wget \
    zip && \
  # (linux) after packages install
  update-ca-certificates && \
  # application user
  groupadd $USER \
    --system \
    --gid $USER_ID && \
  useradd $USER \
    --uid $USER_ID \
    --gid $USER_ID \
    --create-home \
    --shell /bin/bash && \
  # bun for javascript and css building
  curl -fsSL https://bun.sh/install | bash && \
  # rubygems configurations
  echo 'gem: --no-document' > ~/.gemrc && \
  bundle config --global ignore_messages true && \
  gem update --system --silent --no-post-install-message

RUN \
  # preinstall bulky gems
  gem install \
    bigdecimal:3.1.8 \
    bootsnap:1.18.4 \
    date:3.3.4 \
    io-console:0.7.2 \
    irb:1.14.1 \
    nio4r:2.7.3 \
    pg:1.5.8 \
    psych:5.1.2 \
    puma:6.4.3 \
    racc:1.8.1 \
    rails:7.1.4 \
    rdoc:6.7.0 \
    sprockets-rails:3.5.2 \
    stringio:3.1.1

WORKDIR $APP_DIR

# install dependencies
COPY Gemfile Gemfile.lock ./
RUN bundle install

# install app
COPY . .

RUN \
  # install node dependencies
  bun install --frozen-lockfile && \
  # precompile app
  bundle exec bootsnap precompile --gemfile && \
  bundle exec bootsnap precompile app/ lib/ && \
  # precompile assets
  SECRET_KEY_BASE=DUMMY rake assets:precompile && \
  # home directory settings
  chown -R $USER_ID:$USER_ID $HOME && \
  mv .deploy/$RAILS_ENV/entrypoint bin/entrypoint && \
  chmod +x bin/* && \
  # clean build
  apt-get -y autoremove && \
  apt-get clean && \
  bundle clean --force && \
  rm -rf \
    .deploy \
    *.deb \
    /var/lib/apt/lists \
    /var/cache/apt/archives

# entrypoint
EXPOSE $PORT
ENTRYPOINT ["bin/entrypoint"]

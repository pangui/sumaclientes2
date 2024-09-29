# base image
FROM ruby:3.3.5-slim

# build arguments and environment variables
ENV DEBIAN_FRONTEND="noninteractive"
ENV EDITOR="code --wait"
ENV USER="app"
ENV USER_ID="1000"
ENV HOME="/home/${USER}"
ENV APP_DIR="${HOME}/sumaclientes"
ENV BUN_INSTALL="${HOME}/.bun"
ENV GEM_HOME="${APP_DIR}/tmp/.gems/3.3.5"
ENV PATH="${BUN_INSTALL}/bin:${PATH}"
ENV PATH="${GEM_HOME}/bin:${PATH}"

RUN \
  # install debian packages
  apt-get update -qq && \
  apt-get upgrade -y && \
  apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    curl \
    file \
    git \
    gpg \
    gpg-agent \
    iproute2 \
    libpq-dev \
    locales \
    locales-all \
    openssh-client \
    pkg-config \
    postgresql-client \
    procps \
    unzip \
    wget \
    zip \
    zsh && \
  # (linux) after packages install
  update-ca-certificates

# app linux user
RUN \
  groupadd --system --gid $USER_ID $USER && \
  useradd $USER \
    --uid $USER_ID \
    --gid $USER_ID \
    --create-home \
    --shell /usr/bin/zsh

# docker for kamal deployment
COPY ssh_config "${HOME}/.ssh/config"
COPY docker_config.json "${HOME}/.docker/config.json"
RUN \
  groupadd --gid 144 docker && \
  usermod -aG docker $USER && \
  install -m 0755 -d /etc/apt/keyrings && \
  curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc && \
  chmod a+r /etc/apt/keyrings/docker.asc && \
  echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian bookworm stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    dbus-x11 \
    docker-buildx-plugin \
    docker-ce-cli \
    golang-docker-credential-helpers

# ruby
RUN echo 'gem: --no-document' >> "${HOME}/.gemrc"

COPY .irbrc "${HOME}/.irbrc"

# bun
RUN curl -fsSL https://bun.sh/install | bash

# zsh
COPY ohmyzsh.sh "${HOME}/ohmyzsh.sh"
RUN \
  cd $HOME && \
  sh ohmyzsh.sh -- \
    -t agnoster \
    -p git \
    -p colored-man-pages && \
  rm ohmyzsh.sh
COPY custom.zsh "${HOME}/.oh-my-zsh/custom/custom.zsh"

# cleanup
RUN \
  apt-get clean && \
  rm -fr \
    *.deb \
    /var/lib/apt/lists \
    /var/cache/apt/archives

# entrypoint
RUN chown -R $USER_ID:$USER_ID $HOME
USER $USER
ARG GIT_CONFIG_NAME
ARG GIT_CONFIG_EMAIL
RUN \
  git config --global  pull.rebase true && \
  git config --global user.name "${GIT_CONFIG_NAME}" && \
  git config --global user.email "${GIT_CONFIG_EMAIL}"
WORKDIR $APP_DIR

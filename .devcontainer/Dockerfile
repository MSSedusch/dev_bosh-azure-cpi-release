FROM ruby:2.6.7

RUN useradd -ms /bin/bash vscode \
    && apt-get update \
    && apt-get install -y sudo \
    && echo vscode ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/vscode \
    && chmod 0440 /etc/sudoers.d/vscode

RUN apt-get update && apt-get install -y git gcc make libssl-dev libreadline-dev zlib1g-dev gettext-base jq

RUN mkdir ~/workspace && cd ~/workspace && \
    wget -O go.tar.gx https://golang.org/dl/go1.16.5.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go.tar.gx && \
    rm go.tar.gx && \
    mkdir ~/go

ENV PATH="${PATH}:/usr/local/go/bin"
ENV GOPATH="${HOME}/go"

RUN mkdir -p $GOPATH/src/github.com/direnv && \
    git clone https://github.com/direnv/direnv.git $GOPATH/src/github.com/direnv/direnv && \
    cd $GOPATH/src/github.com/direnv/direnv && \
    make && \
    make install && \
    echo 'eval "$(direnv hook bash)"' >> ~/.profile

RUN cd ~/workspace && \
    wget -O chruby-0.3.9.tar.gz https://github.com/postmodern/chruby/archive/v0.3.9.tar.gz && \
    tar -xzvf chruby-0.3.9.tar.gz && \
    cd chruby-0.3.9/ && \
    make install && \
    echo 'source /usr/local/share/chruby/chruby.sh' >> ~/.profile

RUN gem install bundler && \
    gem install ruby-debug-ide && \
    gem install debase && \
    gem install httpclient && \
    gem install concurrent-ruby && \
    gem install jwt && \
    gem install deep_merge && \
    gem install azure-storage-common && \
    gem install azure-storage-blob && \
    gem install azure-storage-table &&  \
    gem install bosh_cpi


RUN cd ~/workspace && \
    wget -O bosh https://github.com/cloudfoundry/bosh-cli/releases/download/v6.4.4/bosh-cli-6.4.4-linux-amd64 && \
    chmod +x ./bosh && \
    mv ./bosh /usr/local/bin/bosh

# DEBUG CPI starts here

RUN apt-get install -y postgresql postgresql-contrib libpq-dev g++ default-libmysqlclient-dev libsqlite3-dev

RUN gem install bundle --no-document && \
    gem install bosh-registry --version 1.3262.24.0 --no-document && \
    gem install pg --version 0.20.0 --no-document
RUN sed -i -e '23s/^/#/' /usr/local/bundle/gems/bosh-registry-1.3262.24.0/lib/bosh/registry.rb

USER postgres
RUN echo "CREATE USER test WITH PASSWORD 'test'; CREATE DATABASE testdb;GRANT ALL PRIVILEGES ON DATABASE testdb to test;" >> ~/create_db.sql
RUN /etc/init.d/postgresql start && psql -f ~/create_db.sql

USER vscode

# WORKDIR /home/vscode
ENV BUNDLE_PATH=~/.gems

RUN curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# COPY registry.cfg /home/vscode/
# COPY cpi.local.cfg /home/vscode/cpi.cfg

# RUN sudo /etc/init.d/postgresql start && bosh-registry-migrate -c ./registry.cfg
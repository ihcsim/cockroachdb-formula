# This Dockerfile is used to run salt-kitchen on Codeship, targeting the DigitalOcean cloud.
FROM ruby:2.4.0
MAINTAINER Ivan Sim, ihcsim@gmail.com

RUN bundle config --global frozen 1 && \
    mkdir -p /usr/src/app
COPY . /usr/src/app
WORKDIR /usr/src/app
RUN bundle install

CMD ["kitchen", "help"]

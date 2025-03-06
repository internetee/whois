FROM ruby:3.0.3-slim-buster

RUN apt-get update && apt-get install -y \
       build-essential \
       libssl-dev \
       libpq-dev \
       whois
RUN mkdir -p /opt/webapps/app/tmp/pids
WORKDIR /opt/webapps/app
COPY Gemfile Gemfile.lock ./
RUN gem install bundler && bundle install --jobs 20 --retry 5

EXPOSE 43

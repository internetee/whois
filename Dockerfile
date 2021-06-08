FROM internetee/ruby:3.0
MAINTAINER maciej.szlosarczyk@internet.ee

RUN apt-get update -y > /dev/null
RUN apt-get install whois -y > /dev/null
RUN mkdir -p /opt/webapps/app/tmp/pids
WORKDIR /opt/webapps/app
COPY Gemfile Gemfile.lock ./
RUN gem install bundler && bundle install --jobs 20 --retry 5

EXPOSE 43

FROM internetee/ruby:2.6
MAINTAINER maciej.szlosarczyk@internet.ee

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install whois -y > /dev/null
RUN mkdir -p /opt/webapps/app/tmp/pids
WORKDIR /opt/webapps/app
COPY . ./
RUN gem install bundler && bundle install --jobs 20 --retry 5

EXPOSE 43

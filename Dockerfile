FROM internetee/ruby:2.5
LABEL maintainer="georg.kahest@internet.ee"

RUN apt-get update -y > /dev/null
RUN apt-get install whois -y > /dev/null
RUN mkdir -p /opt/webapps/app/tmp/pids
WORKDIR /opt/webapps/app
COPY Gemfile Gemfile.lock ./
RUN gem install bundler && bundle install --full-index --jobs 20 --retry 5

EXPOSE 43

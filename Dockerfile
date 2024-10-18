FROM internetee/ruby:3.0.2

# RUN apt-get update -y > /dev/null
# RUN apt-get install whois -y > /dev/null
WORKDIR /opt/webapps/app

RUN mkdir -p /opt/webapps/app/tmp/pids
RUN touch /opt/webapps/app/tmp/pids/.keep

COPY Gemfile Gemfile.lock ./
RUN gem install bundler && bundle install --jobs 20 --retry 5

EXPOSE 43

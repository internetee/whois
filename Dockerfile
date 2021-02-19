FROM internetee/ruby:2.6
ARG TEST_REPORTER_VER='0.9.0'

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install whois locales -y > /dev/null

# Setting locale 
RUN locale-gen et_EE.UTF-8
ENV LANG et_EE.UTF-8   
ENV LC_ALL et_EE.UTF-8

RUN mkdir -p /opt/webapps/app/tmp/pids
WORKDIR /opt/webapps/app

COPY . ./
RUN wget -O cc-test-reporter https://codeclimate.com/downloads/test-reporter/test-reporter-"$TEST_REPORTER_VER"-linux-amd64 \
    && chmod +x cc-test-reporter \
    && ./cc-test-reporter before-build

RUN gem install bundler && bundle install --jobs 20 --retry 5


EXPOSE 43

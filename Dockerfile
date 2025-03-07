FROM ruby:3.4.2-bullseye

LABEL org.opencontainers.image.source=https://github.com/internetee/whois
LABEL org.opencontainers.image.description="WHOIS server for .ee domains"
LABEL org.opencontainers.image.licenses=MIT

# Install system dependencies and locales
RUN apt-get update && apt-get install -y \
    build-essential \
    libssl-dev \
    libpq-dev \
    libsystemd-dev \
    whois \
    locales \
    netcat \
    && echo "et_EE.UTF-8 UTF-8" > /etc/locale.gen \
    && locale-gen \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Set environment variables
ENV LANG=et_EE.UTF-8 \
    LANGUAGE=et_EE:et \
    LC_ALL=et_EE.UTF-8 \
    DEBIAN_FRONTEND=noninteractive \
    RAILS_ENV=production \
    MALLOC_ARENA_MAX=2 \
    BUNDLE_DEPLOYMENT=true \
    BUNDLE_WITHOUT=development:test \
    BUNDLE_PATH=/usr/local/bundle

# Create non-root user
RUN groupadd -r whois && useradd -r -g whois -d /opt/webapps/app -s /sbin/nologin -c "WhoisServer user" whois

# Create app directory and set permissions
RUN mkdir -p /opt/webapps/app/tmp/pids /opt/webapps/app/log \
    && chown -R whois:whois /opt/webapps/app \
    && chmod -R 777 /opt/webapps/app/tmp \
    && mkdir -p "$BUNDLE_PATH" \
    && chown -R whois:whois "$BUNDLE_PATH"

# Set working directory
WORKDIR /opt/webapps/app

# Copy Gemfile for dependency installation
COPY --chown=whois:whois Gemfile ./

# Install dependencies and create Gemfile.lock
RUN gem update --system && \
    gem install bundler && \
    bundle config set --local specific_platform true && \
    bundle config set --local without 'development test' && \
    bundle install --jobs 20 --retry 5 && \
    bundle lock --add-platform x86_64-linux && \
    rm -rf /usr/local/bundle/cache/*.gem && \
    find /usr/local/bundle/gems/ -name "*.c" -delete && \
    find /usr/local/bundle/gems/ -name "*.o" -delete && \
    rm -rf /usr/local/bundle/cache /usr/local/bundle/doc

# Copy the rest of the application code
COPY --chown=whois:whois . .

# Ensure tmp directory permissions after code copy
RUN chmod -R 777 /opt/webapps/app/tmp

# Switch to non-root user
USER whois

# Expose WHOIS port
EXPOSE 43

# Health check
HEALTHCHECK --interval=30s --timeout=3s \
  CMD nc -zv localhost 43 || exit 1

# Start the WHOIS server
CMD ["bundle", "exec", "ruby", "whois.rb"]

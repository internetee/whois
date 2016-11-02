source 'https://rubygems.org'

# core
gem 'eventmachine', '~> 1.0.9'
gem 'simpleidn', '~> 0.0.6' # For punycode
gem 'SyslogLogger', '2.0', require: 'syslog/logger'

# database
gem 'activerecord', '~> 4.2.5.2'
gem 'pg',           '~> 0.18.0'
gem 'active_record_migrations', '~> 4.2.5.2.1'

gem 'daemons', '~> 1.2.3'

group :development do
  gem 'rubocop',               '~> 0.26.1'

  # debug
  gem 'pry', '~> 0.10.1'

  # deploy
  gem 'mina', '~> 0.3.1' # for fast deployment
end

group :development, :test do
  gem 'rspec'
end

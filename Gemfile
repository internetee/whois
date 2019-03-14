source 'https://rubygems.org'

# core
gem 'eventmachine', '~> 1.2.0'
gem 'simpleidn', '~> 0.0.6' # For punycode
gem 'SyslogLogger', '2.0', require: 'syslog/logger'

# database
gem 'activerecord', '~> 4.2'
gem 'pg',           '~> 0.19.0'
gem 'daemons', '~> 1.2.3'
gem 'dotenv'

group :development do
  gem 'rubocop'

  # debug
  gem 'pry', '~> 0.10.1'

  # deploy
  gem 'mina', '~> 0.3.1' # for fast deployment
end

group :development, :test do
  gem 'minitest'
end

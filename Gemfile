source 'https://rubygems.org'

# core
gem 'eventmachine', '~> 1.2.7'
gem 'simpleidn', '~> 0.2.1' # For punycode

# database
gem 'activerecord', '~> 6.1'
gem 'pg',           '~> 1.2.3'
gem 'daemons', '~> 1.4.0'
gem 'dotenv'

group :development do
  gem 'rubocop'

  # debug
  gem 'pry', '~> 0.14.1'

  # deploy
  gem 'mina', '~> 1.2.3' # for fast deployment
end

group :development, :test do
  gem 'minitest'
  gem 'simplecov', '0.21.2', require: false
end

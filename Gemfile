source 'https://rubygems.org'

# core
gem 'eventmachine', '~> 1.2.7'
gem 'simpleidn', '~> 0.2.1' # For punycode

# database
gem 'activerecord', '~> 7.0'
gem 'pg',           '~> 1.4.0'
gem 'daemons', '~> 1.4.1'
gem 'dotenv'

group :development do
  gem 'rubocop'

  # debug
  gem 'pry', '~> 0.14.1'

  # deploy
  gem 'mina', '~> 1.2.4' # for fast deployment
end

group :development, :test do
  gem 'minitest'
  gem 'simplecov', '0.22.0', require: false # CC last supported v0.17
end

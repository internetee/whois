source 'https://rubygems.org'

ruby '3.4.2'

# core
gem 'eventmachine', '~> 1.2.7'
gem 'simpleidn', '~> 0.2.1' # For punycode

# database
gem 'activerecord', '~> 7.0'
gem 'daemons', '~> 1.4.1'
gem 'dotenv'
gem 'pg', '~> 1.5.0'

group :development do
  gem 'rubocop'

  # debug
  gem 'pry', '~> 0.15.0'

  # deploy
  gem 'mina', '~> 1.2.4' # for fast deployment
end

group :development, :test do
  gem 'minitest'
  gem 'mocha'
  gem 'ostruct'
  gem 'simplecov', '0.17.1', require: false # CC last supported v0.17
end

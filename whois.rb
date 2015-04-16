require 'bundler/setup'
require 'daemons'
require 'active_record'

pwd  = File.expand_path('.')
whois_server = pwd + '/lib/whois_server.rb'

if ENV['WHOIS_ENV'].nil? 
  WHOIS_ENV = 'development'
else
  WHOIS_ENV = 'production'
end

Daemons.run_proc(
  'whois',
    log_output: true,
    monitor: true,
    multiple: false
  #   dir_mode: :system,
  ) do

  puts "Whois env: #{WHOIS_ENV}"
  exec "WHOIS_ENV=#{WHOIS_ENV} ruby #{whois_server}"
end

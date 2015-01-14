require 'bundler/setup'
require 'daemons'

pwd  = File.expand_path('.')
whois_server = pwd + '/lib/whois_server.rb'

Daemons.run_proc(
  'whois',
    log_output: true,
    monitor: true,
    multiple: false
  #   dir_mode: :system,
  ) do

  if ENV['WHOIS_ENV'].nil? 
    WHOIS_ENV = 'development'
  else
    WHOIS_ENV = 'production'
  end

  puts "Whois env: #{WHOIS_ENV}"
  exec "WHOIS_ENV=#{WHOIS_ENV} ruby #{whois_server}"
end

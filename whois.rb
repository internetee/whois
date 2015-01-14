require 'bundler/setup'
require 'daemons'

pwd  = File.expand_path('.')
whois_server = pwd + '/lib/whois_server.rb'

Daemons.run_proc(
  'whois',
  #   log_output: true,
  #   dir_mode: :system,
  #   monitor: true,
  #   multiple: false
  ) do

  if ARGV.include?('production') 
    WHOIS_ENV = 'production'
  else
    WHOIS_ENV = 'development'
  end

  puts "Whois env: #{WHOIS_ENV}"

  exec "ruby #{whois_server}"
end

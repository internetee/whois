require 'bundler/setup'
require 'daemons'
require 'active_record'
require 'syslog/logger'

def logger
  @logger ||= Syslog::Logger.new 'whois'
end

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
    output_logfilename: 'whois.error.log',
    logfilename: 'whois.log',
    log_dir: Dir.pwd + '/log',
    monitor: true,
    multiple: false, # multiple needs proxy and command stop not working correctly
    dir: 'tmp/pid'
  ) do

  message = "Whois started in: #{WHOIS_ENV}"
  puts message
  logger.info message
  exec "WHOIS_ENV=#{WHOIS_ENV} ruby #{whois_server}"
end

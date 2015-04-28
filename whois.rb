require 'bundler/setup'
require 'daemons'
require 'active_record'
require 'syslog/logger'

def logger
  @logger ||= Syslog::Logger.new 'whois'
end

root_path  = File.expand_path('.')
whois_server = root_path + '/lib/whois_server.rb'

if ENV['WHOIS_ENV'].nil? 
  WHOIS_ENV = 'development'
else
  WHOIS_ENV = 'production'
end

Daemons.run(whois_server,
  log_output: true,
  output_logfilename: 'whois.log',
  logfilename: 'whois.log',
  log_dir: root_path + '/log',
  monitor: true,
  multiple: false, # multiple needs proxy server
  dir: '../tmp/pids'
) 

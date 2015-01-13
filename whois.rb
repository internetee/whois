require 'bundler/setup'
require 'daemons'

pwd  = File.dirname(File.expand_path(__FILE__))
file = pwd + '/lib/whois_server.rb'

Daemons.run_proc(
   'whois', # name of daemon
   :log_output => true
 ) do
   exec "ruby #{file}"
end

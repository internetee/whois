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
   exec "ruby #{whois_server}"
end

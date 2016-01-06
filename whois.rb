require 'bundler/setup'
require 'daemons'
require 'simpleidn'

root_path  = File.expand_path('.')
whois_server = root_path + '/lib/whois_server.rb'

Daemons.run(whois_server,
            app_name: 'whois_server',
            log_output: true,
            output_logfilename: 'whois.log',
            logfilename: 'whois.log',
            log_dir: root_path + '/log',
            monitor: true,
            multiple: false, # multiple needs proxy server
            dir: '../tmp/pids'
) 

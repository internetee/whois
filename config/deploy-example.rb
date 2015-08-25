require 'mina/bundler'
require 'mina/rails'
require 'mina/git'
require 'mina/rbenv'  # for rbenv support. (http://rbenv.org)

# Basic settings:
#   domain       - The hostname to SSH to.
#   deploy_to    - Path to deploy into.
#   repository   - Git repo to clone from. (needed by mina/git)
#   branch       - Branch name to deploy. (needed by mina/git)

set :domain, 'registry'
set :deploy_to, '$HOME/whois'
set :repository, 'https://github.com/domify/whois' # dev
set :branch, 'master'
set :rails_env, 'production'

# staging
task :st do
  set :domain, 'whois-st'
  set :deploy_to, '$HOME/whois'
  set :repository, 'https://github.com/internetee/whois' # production
  set :branch, 'staging'
end

# production
task :pr do
  set :domain, 'whois'
  set :deploy_to, '$HOME/whois'
  set :repository, 'https://github.com/internetee/whois' # production
  set :branch, 'master'
end

# Manually create these paths in shared/ (eg: shared/config/database.yml) in your server.
# They will be linked in the 'deploy:link_shared_paths' step.
set :shared_paths, [
  'config/database.yml',
  'log',
  'tmp/pids'
]

# Optional settings:
#   set :user, 'foobar'    # Username in the server to SSH to.
#   set :port, '30000'     # SSH port number.

# This task is the environment that is loaded for most commands, such as
# `mina deploy` or `mina rake`.
task :environment do
  invoke :'rbenv:load'
end

# Put any custom mkdir's in here for when `mina setup` is ran.
# For Rails apps, we'll make some of the shared paths that are shared between
# all releases.
task setup: :environment do
  queue! %(mkdir -p "#{deploy_to}/shared/log")
  queue! %(chmod g+rx,u+rwx "#{deploy_to}/shared/log")

  queue! %(mkdir -p "#{deploy_to}/shared/config")
  queue! %(chmod g+rx,u+rwx "#{deploy_to}/shared/config")

  queue! %(mkdir -p "#{deploy_to}/shared/tmp")
  queue! %(chmod g+rx,u+rwx "#{deploy_to}/shared/tmp")

  queue! %(mkdir -p "#{deploy_to}/shared/tmp/pids")
  queue! %(chmod g+rx,u+rwx "#{deploy_to}/shared/tmp/pids")

  deploy do
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    to :launch do
      invoke :'bundle:install'
      queue! %(cp -n config/database-example.yml #{deploy_to}/shared/config/database.yml)
      queue %(echo '\n  NB! Please edit 'shared/config/database.yml'\n')
    end
  end
end

desc 'Deploys the current version to the server.'
task deploy: :environment do
  deploy do
    # Put things that will set up an empty directory into a fully set-up
    # instance of your project.
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    to :launch do
      invoke :restart
    end
  end
end

desc 'Rolls back the latest release'
task rollback: :environment do
  queue! %(echo "-----> Rolling back to previous release for instance: #{domain}")
  queue %(ls "#{deploy_to}/releases" -Art | sort | tail -n 2 | head -n 1)
  queue! %(
    ls -Art "#{deploy_to}/releases" | sort | tail -n 2 | head -n 1 |
    xargs -I active ln -nfs "#{deploy_to}/releases/active" "#{deploy_to}/current"
  )
  to :launch do
    invoke :restart
  end
end

desc 'Restart whois server'
task restart: :environment do
  # Whois start, stop or restart needs ROOT user.
  # One way is to add your user to not request password, example sudoers entry:
  # whois ALL=(ALL:ALL) ALL, NOPASSWD:/etc/init.d/whois
  queue "sudo /etc/init.d/whois stop && sudo /etc/init.d/whois start"
end

Whois server
------------

Whois server build on top of ruby EventMachine.


Demo Installation
-----------------

Before demo install, please ensure you have rbenv and postgres installed. 

    git clone https://github.com/internetee/whois.git
    cd whois
    bundle
    cp config/database-example.yml config/database.yml # and edit it
    cp env-example .env # and edit it according to your needs

    # create postgres database, example:
    # create database whois owner whois encoding 'UTF-8' LC_COLLATE 'et_EE.utf8' LC_CTYPE 'et_EE.utf8' template template0;

    rake db:setup
    ruby whois.rb run # or start for daemon, other commands: status start stop run --help
    sudo apt-get install whois
    whois hello.ee -h localhost -p 1043 # by default whois run on port 43

You should receive 

    Hello from whois server!

If you have any issues you can try run whois server on front:

    ruby whois.rb stop   # stops running whois
    ruby whois.rb run    # runs whois server in terminal for debug
    ruby whois.rb --help # for other commands


Production installation
-----------------------

Before production installation, please ensure you have rbenv and postgres installed.

At your local machine:

    git clone https://github.com/internetee/whois.git
    cd whois
    bundle
    gem install mina # or any other deploy tool
    cp config/deploy-example.rb config/deploy.rb # and edit it
    mina pr setup 
    rake db:schema:load db=production # load schema to production db

Add init script and edit it:

    sudo cp config/whois-init-example /etc/init.d/whois
    sudo chmod +x /etc/init.d/whois

Start server

    sudo /etc/init.d/whois start


Additional notes
----------------

Request logs are going to syslog, however all daemon related errors are going to log directory because 
daemon lib currently not supporting syslog, probably in future it will happen.

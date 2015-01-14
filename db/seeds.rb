load 'app/models/domain.rb'
Domain.create(name: 'hello.ee', whois_body: 'Hello from whois server!')
Domain.create(name: 'test.ee', whois_body: 'Hello from test.ee domain!')

load 'app/models/whois_record.rb'
WhoisRecord.create(name: 'hello.ee', body: 'Hello from whois server!')
WhoisRecord.create(name: 'test.ee', body: 'Hello from test.ee domain!')

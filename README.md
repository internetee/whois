Whois server
------------

```
    iptables -t nat -A PREROUTING -p tcp --dport 43 -j REDIRECT --to-port 1043
```

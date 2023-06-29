# Route53 DNS Failover Demo

This is a simple application to demonstrate Route53 DNS Failover in LocalStack.

Based on: https://github.com/mineiros-io/terraform-aws-route53/blob/master/examples/failover-routing/main.tf

## Prerequisites

* LocalStack Pro running in Docker
* Python

## Running

Deploy the sample app:
```
$ tflocal init
$ tflocal apply
```

Start a simple HTTP server on port 8000 on the host (will serve as the health check endpoint):
```
$ python3 -m http.server
```

Resolve the host name `example.com`, which should result in the primary target, `target1.execute-api.localhost.localstack.cloud`:
```
$ dig @127.0.0.1 example.com CNAME
...
target1.execute-api.localhost.localstack.cloud.
```

Stop the Web server that was started above, and wait for around ~30 seconds (for the health check to get updated). If resolve the host name `example.com` again, it should now result in the secondary target, `target2.execute-api.localhost.localstack.cloud`:
```
$ dig @127.0.0.1 example.com CNAME
...
target2.execute-api.localhost.localstack.cloud.
```

# LocalStack Reproducer

Based on the Pro Sample [apigw-custom-domain](https://github.com/localstack/localstack-pro-samples/tree/master/apigw-custom-domain)

## Apigateway V2 Authorizer exception

1. `export LOCALSTACK_API_KEY=yourkey`
2. `docker-compose up`
3. `make deploy`
4. `make invoke`

* Parity issue in api gateway base URL: Compare `cat url.txt` against `make deploy_aws`
  * AWS: `https://0v6o5m2she.execute-api.us-east-1.amazonaws.com`
  * LocalStack: `https://68d03092.execute-api.localhost.localstack.cloud:4566/`
  * The same trailing slash issue was fixed for apigateway v1: https://github.com/localstack/localstack/issues/6533#issuecomment-1443820368
* Authorizer exception in `find_matching_http_route` despite having no authorizer configured:
  * Double-slashes work against AWS
  * When fixing the double-slashes, the invoke from the host works against LocalStack
  * The same issue happens when fixing the double `//` due to the parity issue

```
2023-04-19T12:10:14.677  INFO --- [   asgi_gw_0] localstack.request.aws     : AWS cloudformation.ListStackResources => 200
2023-04-19T12:11:05.599 DEBUG --- [   asgi_gw_0] l.s.a.apigateway_utils     : No matching stage (None) for invocation path (falling back to $default stage): //hello
2023-04-19T12:11:05.601 ERROR --- [   asgi_gw_0] l.s.a.apigateway_utils     : Unable to find a matching route for GET //hello
2023-04-19T12:11:05.602 DEBUG --- [   asgi_gw_0] l.s.apigateway.authorizers : No authorizer configured for resource: GET //hello
2023-04-19T12:11:05.603 DEBUG --- [   asgi_gw_0] l.s.apigateway.authorizers : Authorization failed: Not Found - Traceback (most recent call last):
  File "/opt/code/localstack/.venv/lib/python3.10/site-packages/localstack_ext/services/apigateway/authorizers.py.enc", line 340, in is_request_authorized
  File "/opt/code/localstack/.venv/lib/python3.10/site-packages/localstack_ext/services/apigateway/authorizers.py.enc", line 317, in check_request_authorization
  File "/opt/code/localstack/.venv/lib/python3.10/site-packages/localstack_ext/services/apigateway/apigateway_utils.py.enc", line 227, in get_target_resource_method_or_route
  File "/opt/code/localstack/.venv/lib/python3.10/site-packages/localstack_ext/services/apigateway/apigateway_utils.py.enc", line 201, in find_matching_route
  File "/opt/code/localstack/.venv/lib/python3.10/site-packages/localstack_ext/services/apigateway/apigateway_utils.py.enc", line 193, in find_matching_http_route
localstack_ext.aws.api.apigatewayv2.NotFoundException: Not Found

2023-04-19T12:11:05.604  INFO --- [   asgi_gw_0] localstack.request.http    : GET /hello => 404
```

## Networking with Container Client

1. `export LOCALSTACK_API_KEY=yourkey`
2. `docker-compose up`
3. `make deploy`
4. `make container_invoke`

Use `make container_shell` to start bash in the container.

## CloudFormation Update

Updating the CF stack fails against LocalStack.

1. `export LOCALSTACK_API_KEY=yourkey`
2. `docker-compose up`
3. `make deploy`
4. `make deploy` fails with an `UPDATE_FAILED` error.

```
Serverless: Updating Stack...
Serverless: [AWS cloudformation 200 0.029s 0 retries] updateStack({
  StackName: 'sls-apigw-subdomain-local',
  Capabilities: [ 'CAPABILITY_IAM', 'CAPABILITY_NAMED_IAM', [length]: 2 ],
  Parameters: [ [length]: 0 ],
  TemplateURL: 'http://127.0.0.1:4566/sls-apigw-subdomain-local-serverlessdeploymentbuck-5bfa3046/serverless/sls-apigw-subdomain/local/1681899179070-2023-04-19T10:12:59.070Z/compiled-cloudformation-template.json',
  Tags: [ { Key: 'STAGE', Value: 'local' }, [length]: 1 ]
})
Serverless: Checking Stack update progress...
Serverless: [AWS cloudformation 200 0.052s 0 retries] describeStackEvents({
  StackName: 'arn:aws:cloudformation:us-east-1:000000000000:stack/sls-apigw-subdomain-local/229118e7'
})
..........................
Serverless: Operation failed!
Serverless: View the full error output: https://us-east-1.console.aws.amazon.com/cloudformation/home?region=us-east-1#/stack/detail?stackId=arn%3Aaws%3Acloudformation%3Aus-east-1%3A000000000000%3Astack%2Fsls-apigw-subdomain-local%2F229118e7
 
 Serverless Error ----------------------------------------
 
  ServerlessError: An error occurred: sls-apigw-subdomain-local - UPDATE_FAILED.
      at /Users/joe/Projects/LocalStack/issues/subdomain-container-networking/apigw-subdomain/node_modules/serverless/lib/plugins/aws/lib/monitorStack.js:143:23
      at process.processTicksAndRejections (node:internal/process/task_queues:95:5)
      at async AwsDeploy.update (/Users/joe/Projects/LocalStack/issues/subdomain-container-networking/apigw-subdomain/node_modules/serverless/lib/plugins/aws/lib/updateStack.js:156:5)
```

Workaround: always re-create the stack from scratch.

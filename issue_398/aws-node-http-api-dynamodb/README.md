### Serverless localstack demonstration of issues

1. Lambda integration set up appears to fail with an error log in the deployment: 
   ```
   2022-02-16T11:16:43.850:WARNING:localstack.services.apigateway.apigateway_listener: Unable to convert API Gateway payload to str: line 15, column 3: expected block element in template body, got: #end
   {
     "body": $body,
     "me ... ...
   ```
2. custom-domain-manager plugin is unable to create a domain - appears that when it queries the domain it gets a 404 an exits with error `Error: Unable to fetch information about 'api.example.com':`.
    Creating the domain manually on the api gateway via the cli doesn't seem to help

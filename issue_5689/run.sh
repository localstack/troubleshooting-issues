#!/usr/bin/env sh

awslocal lambda create-function --function-name Test --runtime java11 --handler SavePostHandler::handleRequest --zip-file fileb://build/distributions/issue_5689-1.0-SNAPSHOT.zip --role arn:aws:iam::000000000:role/dummy --timeout 60

REST_API_ID=$(awslocal apigateway create-rest-api --region eu-central-1 --name "test" | jq '.id' | tr -d '"')

PARENT_RESOURCE_ID=$(awslocal apigateway get-resources --region eu-central-1 --rest-api-id "${REST_API_ID}" | jq '.items[] | select(.path == "/") | .id' | tr -d '"')

RESOURCE_ID=$(awslocal apigateway create-resource --region eu-central-1 --rest-api-id "${REST_API_ID}" --parent-id "${PARENT_RESOURCE_ID}" --path-part "post"| jq '.id' | tr -d '"')

awslocal apigateway put-method --region eu-central-1 --rest-api-id "${REST_API_ID}" --resource-id "${RESOURCE_ID}" --http-method "POST" --authorization-type "NONE" 1>/dev/null

awslocal apigateway put-integration --region eu-central-1 --rest-api-id "${REST_API_ID}" --resource-id "${RESOURCE_ID}" --http-method "POST" --type AWS_PROXY --integration-http-method "POST" --uri arn:aws:apigateway:eu-central-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:000000000000:function:Test/invocations --passthrough-behavior WHEN_NO_MATCH

awslocal apigateway create-deployment --region eu-central-1 --rest-api-id "${REST_API_ID}" --stage-name "test"

curl -X POST -F 'image=@./nyan-cat.jpg' http://localhost:4566/restapis/${REST_API_ID}/test/_user_request_/post

#echo "   - URL: http://localhost:4566/restapis/${REST_API_ID}/test/_user_request_/post"

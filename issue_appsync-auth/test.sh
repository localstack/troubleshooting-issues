#!/bin/bash

export AWS_DEFAULT_REGION=us-east-1

poolId=$(awslocal cognito-idp create-user-pool --pool-name p1 | jq -r .UserPool.Id)
clientId=$(awslocal cognito-idp create-user-pool-client --user-pool-id $poolId --client-name c1 | jq -r .UserPoolClient.ClientId)
awslocal cognito-idp sign-up --client-id $clientId --username test --password 'Test123!'
awslocal cognito-idp admin-confirm-sign-up --user-pool-id $poolId --username test
token=$(awslocal cognito-idp initiate-auth --auth-flow USER_PASSWORD_AUTH --client-id $clientId \
  --auth-parameters USERNAME=test,PASSWORD='Test123!' | jq -r .AuthenticationResult.IdToken)

apiId=$(awslocal appsync create-graphql-api --name testApi \
  --authentication-type AMAZON_COGNITO_USER_POOLS \
  --user-pool-config "userPoolId=$poolId,awsRegion=$AWS_DEFAULT_REGION,defaultAction=ALLOW" | jq -r .graphqlApi.apiId)

awslocal appsync start-schema-creation --api-id $apiId --definition 'schema { query: Query } type Query { test: String @aws_auth }'
awslocal appsync create-resolver --api-id $apiId --type-name Query --field-name test

curl -H 'content-type: application/json' -H "Authorization: Bearer $token" \
  -d '{"query":"query { test }"}' http://localhost:4566/graphql/$apiId

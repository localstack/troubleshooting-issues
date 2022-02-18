#!/usr/bin/env sh


aws --endpoint-url=http://localhost:4566 s3api create-bucket --bucket timeseries-ingest-lambda-artifacts
sleep 5
aws --endpoint-url=http://localhost:4566 s3 cp lambda.zip s3://timeseries-ingest-lambda-artifacts/KinesisAPILambdaAuthorizer/lambda.zip
sleep 5
aws --endpoint-url=http://localhost:4566 kinesis create-stream --stream-name test-timeseries-ingest-stream --shard-count 1
sleep 5
aws --endpoint-url=http://localhost:4566 cloudformation create-stack --stack-name test-kinesis-api --template-body file://cloudformation-kinesis-api-resources-PER-ENVIRONMENT.yaml --parameters ParameterKey=AppName,ParameterValue=timeseries-ingest ParameterKey=Environment,ParameterValue=test
sleep 5

restapi=$(aws --endpoint-url=http://localhost:4566 apigateway get-rest-apis | jq -r .items[0].id)
echo "Rest API Id: ${restapi}"

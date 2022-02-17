import { Duration, Stack, StackProps } from 'aws-cdk-lib';
import * as sns from 'aws-cdk-lib/aws-sns';
import * as subs from 'aws-cdk-lib/aws-sns-subscriptions';
import * as sqs from 'aws-cdk-lib/aws-sqs';
import { Construct } from 'constructs';
import { aws_apigateway as apigateway, aws_iam as iam, Aws} from 'aws-cdk-lib';

export class Issue5498Stack extends Stack {
		constructor(scope: Construct, id: string, props?: StackProps) {
				super(scope, id, props);

				const api = new apigateway.RestApi(this, `cdk--dev--source-api`, {
            deploy: true,
            deployOptions: {
                stageName: "dev",
                loggingLevel: apigateway.MethodLoggingLevel.INFO,
                tracingEnabled: true
            }
        });

        const topic = new sns.Topic(this, `cdk--dev--event-topic`, {
            displayName: `Event Topic (dev)`,
            topicName: `cdk--dev--event-topic`
        });

        const eventResource = api.root.addResource('event');
        const snsTopicIntegration = this.buildSnsTopicIntegration(topic);
        eventResource.addMethod('POST', snsTopicIntegration, {
            methodResponses: [{statusCode: "200"}, {statusCode: "400"}]
        });
		}


		private buildSnsTopicIntegration(topic: sns.Topic) {
        const gatewayExecutionRole = new iam.Role(this, "GatewayExecutionRole", {
            assumedBy: new iam.ServicePrincipal("apigateway.amazonaws.com"),
            inlinePolicies: {
                "PublishMessagePolicy": new iam.PolicyDocument({
                    statements: [new iam.PolicyStatement({
                        actions: ["sns:Publish"],
                        resources: [topic.topicArn]
                    })]
                })
            }
        });

        return new apigateway.AwsIntegration({
            service: 'sns',
            integrationHttpMethod: 'POST',
            path: `${Aws.ACCOUNT_ID}/${topic.topicName}`,
            options: {
                credentialsRole: gatewayExecutionRole,
                passthroughBehavior: apigateway.PassthroughBehavior.NEVER,
                requestParameters: {
                    "integration.request.header.Content-Type": `'application/x-www-form-urlencoded'`,
                },
                requestTemplates: {
                    "application/json": `Action=Publish&TopicArn=$util.urlEncode('${topic.topicArn}')&Message=$util.urlEncode($input.body)`,
                },
                integrationResponses: [
                    {
                        statusCode: "200",
                        responseTemplates: {
                            "application/json": `{"status": "message published"}`,
                        },
                    },
                    {
                        statusCode: "400",
                        selectionPattern: "^\[Error\].*",
                        responseTemplates: {
                            "application/json": `{\"state\":\"error\",\"message\":\"$util.escapeJavaScript($input.path('$.errorMessage'))\"}`,
                        },
                    }
                ],
            }
        });
    }
}

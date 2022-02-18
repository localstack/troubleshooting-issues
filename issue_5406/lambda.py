def generatePolicy(principalId, effect, methodArn):
    authResponse = {}
    authResponse['principalId'] = principalId

    if effect and methodArn:
        policyDocument = {
            'Version': '2012-10-17',
            'Statement': [
                {
                    'Sid': 'FirstStatement',
                    'Action': 'execute-api:Invoke',
                    'Effect': effect,
                    'Resource': methodArn
                }
            ]
        }

        authResponse['policyDocument'] = policyDocument

    return authResponse

def lambda_handler(event, context):
    token = event["authorizationToken"].replace("Bearer ", "");
    print(f'JWT Token {token}')


    if token.startswith('ey'):
        principalId = "1122334455"
        return generatePolicy(principalId, 'Allow', event['methodArn'])
    else:
        return generatePolicy(None, 'Deny', event['methodArn'])

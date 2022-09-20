provider "archive" {}


resource "aws_lambda_function" "authorizer" {
  filename         = "authorizer.zip"
  function_name    = "api_gateway_authorizer"
  role             = aws_iam_role.role.arn
  handler          = "authorizer.lambda_handler"
  source_code_hash = filebase64sha256("authorizer.zip")

  runtime = "python3.8"
}

resource "aws_iam_role" "role" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.policy.json
}


data "aws_iam_policy_document" "policy" {
  statement {
    sid    = ""
    effect = "Allow"

    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }

    actions = ["sts:AssumeRole"]
  }
}

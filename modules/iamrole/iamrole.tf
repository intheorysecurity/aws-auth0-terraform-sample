resource "aws_iam_policy" "iam_policy_1" {
  name = "AWSLambdaBasicExecutionRole-lambda-crud-function"
  path = "/service-role/"
  policy = jsonencode(
    {
      Statement = [
        {
          Action   = "logs:CreateLogGroup"
          Effect   = "Allow"
          Resource = "arn:aws:logs:${var.aws_region}:${var.aws_account_number}:*"
        },
        {
          Action = [
            "logs:CreateLogStream",
            "logs:PutLogEvents",
          ]
          Effect   = "Allow"
          Resource = ["${var.cloudwatch_arn}:*"]
        },
      ]
      Version = "2012-10-17"
    }
  )
}

resource "aws_iam_policy" "iam_policy_2" {
  name = "AWSLambdaMicroserviceExecutionRole-lambda-crud-function"
  path = "/service-role/"
  policy = jsonencode(
    {
      Statement = [
        {
          Action = [
            "dynamodb:DeleteItem",
            "dynamodb:GetItem",
            "dynamodb:PutItem",
            "dynamodb:Scan",
            "dynamodb:UpdateItem",
          ]
          Effect   = "Allow"
          Resource = var.dynamodb_arn
        },
      ]
      Version = "2012-10-17"
    }
  )
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "http-crud-role"
  path = "/service-role/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "lambda.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
  EOF

  managed_policy_arns = [aws_iam_policy.iam_policy_1.arn, aws_iam_policy.iam_policy_2.arn]
}

output "iam_role_arn" {
  value = aws_iam_role.iam_for_lambda.arn
}
//cloudwatch log group

resource "aws_cloudwatch_log_group" "lambda_poc_logs" {
  name              = "/aws/lambda/lambda-crud-function"
  retention_in_days = 1
}

output "cloudwatch_lambda_poc_arn" {
  value = aws_cloudwatch_log_group.lambda_poc_logs.arn
}
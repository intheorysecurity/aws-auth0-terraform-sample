//lambda section
resource "aws_lambda_function" "lambda_function" {
  filename         = "${path.module}/index.zip"
  function_name    = "lambda-crud-function"
  source_code_hash = filebase64sha256("${path.module}/index.zip")
  runtime          = "nodejs14.x"
  role             = var.iam_role_arn
  handler          = "index.handler"
}

output "invoke_arn" {
  value = aws_lambda_function.lambda_function.invoke_arn
}
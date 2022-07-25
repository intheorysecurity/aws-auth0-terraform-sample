resource "aws_apigatewayv2_api" "poc_apigateway" {
  name          = "http-crud-api-gateway"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.poc_apigateway.id
  name        = "$default"
  auto_deploy = true
}

//API Gateway Integration
resource "aws_apigatewayv2_integration" "lambda" {
  api_id                 = aws_apigatewayv2_api.poc_apigateway.id
  connection_type        = "INTERNET"
  integration_type       = "AWS_PROXY"
  integration_method     = "POST"
  payload_format_version = "2.0"
  integration_uri        = var.lambda_invoked_arn
}

//API Gateway Authorizer
resource "aws_apigatewayv2_authorizer" "auth0JWT" {
  api_id           = aws_apigatewayv2_api.poc_apigateway.id
  authorizer_type  = "JWT"
  identity_sources = ["$request.header.Authorization"]
  name             = "Auth0_JWT"

  jwt_configuration {
    audience = ["https://auth0-jwt-authorizer"]
    issuer   = "https://${var.auth0_domain}/"
  }
}

//ADDED
resource "aws_lambda_permission" "execution_lambda_from_gateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "lambda-crud-function"
  principal     = "apigateway.amazonaws.com"
}

/**
* API Gateway Routes
**/

resource "aws_apigatewayv2_route" "get_users" {
  api_id               = aws_apigatewayv2_api.poc_apigateway.id
  route_key            = "GET /users"
  authorizer_id        = aws_apigatewayv2_authorizer.auth0JWT.id
  authorization_type   = "JWT"
  authorization_scopes = ["read:users"]
  target               = "integrations/${aws_apigatewayv2_integration.lambda.id}"
  depends_on = [
    aws_lambda_permission.execution_lambda_from_gateway
  ]
}

resource "aws_apigatewayv2_route" "put_users" {
  api_id               = aws_apigatewayv2_api.poc_apigateway.id
  route_key            = "PUT /users"
  authorizer_id        = aws_apigatewayv2_authorizer.auth0JWT.id
  authorization_type   = "JWT"
  authorization_scopes = ["create:users"]
  target               = "integrations/${aws_apigatewayv2_integration.lambda.id}"
  depends_on = [
    aws_apigatewayv2_route.get_users
  ]
}

resource "aws_apigatewayv2_route" "get_users_id" {
  api_id               = aws_apigatewayv2_api.poc_apigateway.id
  route_key            = "GET /users/{id}"
  authorizer_id        = aws_apigatewayv2_authorizer.auth0JWT.id
  authorization_type   = "JWT"
  authorization_scopes = ["read:users"]
  target               = "integrations/${aws_apigatewayv2_integration.lambda.id}"
  depends_on = [
    aws_apigatewayv2_route.put_users
  ]
}

resource "aws_apigatewayv2_route" "delete_users_id" {
  api_id               = aws_apigatewayv2_api.poc_apigateway.id
  route_key            = "DELETE /users/{id}"
  authorizer_id        = aws_apigatewayv2_authorizer.auth0JWT.id
  authorization_type   = "JWT"
  authorization_scopes = ["delete:users"]
  target               = "integrations/${aws_apigatewayv2_integration.lambda.id}"
  depends_on = [
    aws_apigatewayv2_route.get_users_id
  ]
}

resource "aws_apigatewayv2_route" "post_verify" {
  api_id               = aws_apigatewayv2_api.poc_apigateway.id
  route_key            = "POST /verify"
  authorizer_id        = aws_apigatewayv2_authorizer.auth0JWT.id
  authorization_type   = "JWT"
  authorization_scopes = ["validate:users"]
  target               = "integrations/${aws_apigatewayv2_integration.lambda.id}"
  depends_on = [
    aws_apigatewayv2_route.delete_users_id
  ]
}

resource "aws_apigatewayv2_route" "change_password" {
  api_id               = aws_apigatewayv2_api.poc_apigateway.id
  route_key            = "POST /changepassword/{id}"
  authorizer_id        = aws_apigatewayv2_authorizer.auth0JWT.id
  authorization_type   = "JWT"
  authorization_scopes = ["validate:users"]
  target               = "integrations/${aws_apigatewayv2_integration.lambda.id}"
  depends_on = [
    aws_apigatewayv2_route.post_verify
  ]
}

output "api_gateway_default_url" {
  value = aws_apigatewayv2_stage.default.invoke_url
}
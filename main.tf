//builds dynamodb table
module "dynamodb" {
  source = "./modules/dynamodb"
}

//create cloudfront logs
module "cloudfront" {
  source = "./modules/cloudwatch"
}

//creates IAM roles required for Lambda function
module "iamrole" {
  source             = "./modules/iamrole"
  dynamodb_arn       = module.dynamodb.dynamodb_users_table_arn
  cloudwatch_arn     = module.cloudfront.cloudwatch_lambda_poc_arn
  aws_region         = var.aws_region
  aws_account_number = var.aws_account_number
  depends_on = [
    module.dynamodb, module.cloudfront
  ]
}

//creates Lambda function with and add permissions from iamrole module
module "lambda" {
  source       = "./modules/lambda"
  iam_role_arn = module.iamrole.iam_role_arn
  depends_on = [
    module.iamrole
  ]
}

//creates API Gateway and links lambda function to the Gateway
module "apigateway" {
  source             = "./modules/apigateway"
  lambda_invoked_arn = module.lambda.invoke_arn
  auth0_domain       = var.auth0_domain
  depends_on = [
    module.lambda
  ]
}

//create Auth0 application and custom database
module "auth0connections" {
  source           = "./modules/auth0connections"
  auth0_domain     = var.auth0_domain
  awsAPIGatewayURL = module.apigateway.api_gateway_default_url
}

//Outputs API Gateway URL
output "api_gateway_default_url" {
  value = module.apigateway.api_gateway_default_url
}

output "auth0_application_client_id" {
  value = module.auth0connections.auth0_application_client_id
}

output "auth0_application_client_secret" {
  value     = module.auth0connections.auth0_application_client_secret
  sensitive = true
}
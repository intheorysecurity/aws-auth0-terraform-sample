variable "auth0_domain" {
  description = "Auth0 Domain"
  type        = string
  default     = "poc.us.auth0.com"
}

variable "awsAPIGatewayURL" {
  description = "AWS API Gateway URL"
  type        = string
  default     = "https://apigateway.aws.com"
}
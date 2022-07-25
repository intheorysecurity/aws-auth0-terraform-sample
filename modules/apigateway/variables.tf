variable "lambda_invoked_arn" {
  description = "Lambda Funcation Invoked ARN"
  type        = string
  default     = "example_arn"
}

variable "auth0_domain" {
  description = "Auth0 Domain"
  type        = string
  default     = "poc.us.auth0.com"
}
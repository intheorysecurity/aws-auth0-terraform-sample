variable "dynamodb_arn" {
  description = "Dynamodb Table ARN"
  type        = string
  default     = "arn:aws:dynamodb:us-east-1:107157047023:table/*"
}

variable "cloudwatch_arn" {
  description = "Cloud Watch log group ARN"
  type        = string
  default     = "arn:aws:logs:us-east-1:107157047023:log-group:/aws/lambda/*"
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "aws_account_number" {
  description = "AWS Account Number"
  type        = string
  default     = "1234567890"
}
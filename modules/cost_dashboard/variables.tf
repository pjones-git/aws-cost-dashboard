variable "project_name" {
  description = "Base project name for resource naming"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "cost_alert_threshold" {
  description = "Monthly cost threshold in USD"
  type        = number
}

variable "sns_topic_arn" {
  description = "SNS topic ARN for cost alerts"
  type        = string
}

variable "lambda_runtime" {
  description = "Lambda Python runtime"
  type        = string
}

variable "lambda_timeout" {
  description = "Lambda timeout in seconds"
  type        = number
}

variable "lambda_role_arn" {
  description = "IAM role ARN for the Lambda function"
  type        = string
}

variable "cw_namespace" {
  description = "CloudWatch custom namespace for cost metrics"
  type        = string
}

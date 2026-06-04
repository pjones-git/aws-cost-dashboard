variable "aws_region" {
  description = "AWS region where resources will be deployed"
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "AWS CLI profile to use for authentication"
  type        = string
  default     = "lab6"
}

variable "environment" {
  description = "Environment name used for tagging and naming resources"
  type        = string
  default     = "dev"
}

variable "owner_tag" {
  description = "Owner tag applied to all resources for accountability"
  type        = string
  default     = "pjones"
}

variable "project_name" {
  description = "Base name used across all resource names"
  type        = string
  default     = "cost-dashboard-lab6"
}

variable "cost_alert_threshold" {
  description = "Monthly cost threshold in USD that triggers an SNS alert"
  type        = number
  default     = 100
}

variable "alert_email" {
  description = "Email address that receives cost alert notifications"
  type        = string
  # No default - this is provided in terraform.tfvars which is gitignored
}

variable "cost_report_bucket_suffix" {
  description = "Unique suffix appended to the S3 bucket name to ensure global uniqueness"
  type        = string
  default     = "reports"
}

variable "lambda_runtime" {
  description = "Python runtime version for Lambda cost processor function"
  type        = string
  default     = "python3.11"
}

variable "lambda_timeout" {
  description = "Maximum execution time in seconds for the Lambda function"
  type        = number
  default     = 300
}

variable "dashboard_retention_days" {
  description = "Number of days to retain CloudWatch Dashboard data"
  type        = number
  default     = 90
}

variable "aws_account_id" {
  description = "AWS account ID used for resource naming"
  type        = string
}
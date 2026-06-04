output "lambda_function_name" {
  description = "Lambda function name"
  value       = module.cost_dashboard.lambda_function_name
}

output "cost_reports_bucket" {
  description = "S3 bucket for cost reports"
  value       = module.cost_dashboard.cost_reports_bucket
}

output "cloudwatch_dashboard_url" {
  description = "URL to view the CloudWatch cost dashboard"
  value       = module.cost_dashboard.dashboard_url
}

output "sns_topic_arn" {
  description = "SNS topic ARN for alerts"
  value       = module.notifications.sns_topic_arn
}

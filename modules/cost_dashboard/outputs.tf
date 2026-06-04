output "lambda_function_name" {
  description = "Name of the cost processor Lambda function"
  value       = aws_lambda_function.cost_processor.function_name
}

output "lambda_function_arn" {
  description = "ARN of the cost processor Lambda function"
  value       = aws_lambda_function.cost_processor.arn
}

output "cost_reports_bucket" {
  description = "Name of the S3 bucket storing cost reports"
  value       = aws_s3_bucket.cost_reports.bucket
}

output "dashboard_url" {
  description = "Direct URL to the CloudWatch dashboard"
  value       = "https://${var.aws_region}.console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#dashboards:name=${aws_cloudwatch_dashboard.cost_dashboard.dashboard_name}"
}

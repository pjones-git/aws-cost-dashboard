output "sns_topic_arn" {
  description = "ARN of the SNS cost alert topic"
  value       = aws_sns_topic.cost_alerts.arn
}

output "sns_topic_name" {
  description = "Name of the SNS cost alert topic"
  value       = aws_sns_topic.cost_alerts.name
}

# SNS Topic for cost alerts
resource "aws_sns_topic" "cost_alerts" {
  name              = "${var.project_name}-${var.environment}-cost-alerts"
  kms_master_key_id = "alias/aws/sns"
}

# Email subscription to the SNS topic
resource "aws_sns_topic_subscription" "email_alert" {
  topic_arn = aws_sns_topic.cost_alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

# -----------------------------------------------------------------
# IAM Role for Lambda - Defines what AWS services Lambda can call
# -----------------------------------------------------------------
resource "aws_iam_role" "lambda_role" {
  name = "${var.project_name}-${var.environment}-lambda-role"

  # Trust policy: allows the Lambda service to assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

# Attach AWS managed policy for Lambda basic execution (CloudWatch Logs)
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Custom policy granting Lambda access to Cost Explorer, CloudWatch, SNS, S3
resource "aws_iam_role_policy" "lambda_cost_policy" {
  name = "${var.project_name}-lambda-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCostExplorer"
        Effect = "Allow"
        Action = [
          "ce:GetCostAndUsage",
          "ce:GetCostForecast",
          "ce:GetDimensionValues"
        ]
        Resource = "*"
      },
      {
        Sid    = "AllowCloudWatchMetricData"
        Effect = "Allow"
        Action = [
          "cloudwatch:PutMetricData",
          "cloudwatch:GetMetricStatistics",
          "cloudwatch:ListMetrics"
        ]
        Resource = "*"
      },
      {
        Sid    = "AllowSNSPublish"
        Effect = "Allow"
        Action = ["sns:Publish"]
        Resource = module.notifications.sns_topic_arn
      },
      {
        Sid    = "AllowS3Reports"
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject"
        ]
        Resource = "arn:aws:s3:::${var.project_name}-${var.environment}-cost-reports/*"
      }
    ]
  })
}

# -----------------------------------------------------------------
# Notifications Module
# -----------------------------------------------------------------
module "notifications" {
  source       = "./modules/notifications"
  project_name = var.project_name
  environment  = var.environment
  alert_email  = var.alert_email
}

# -----------------------------------------------------------------
# Cost Lambda Module
# ------

# -----------------------------------------------------------------
# Cost Dashboard Module
# -----------------------------------------------------------------
module "cost_dashboard" {
  source               = "./modules/cost_dashboard"
  project_name         = var.project_name
  environment          = var.environment
  aws_region           = var.aws_region
  cost_alert_threshold = var.cost_alert_threshold
  sns_topic_arn        = module.notifications.sns_topic_arn
  lambda_runtime       = var.lambda_runtime
  lambda_timeout       = var.lambda_timeout
  lambda_role_arn      = aws_iam_role.lambda_role.arn
  cw_namespace         = "CostDashboard/${var.project_name}"
}


# -----------------------------------------------------------------
# S3 Bucket - Stores cost reports
# -----------------------------------------------------------------
resource "aws_s3_bucket" "cost_reports" {
  bucket        = "${var.project_name}-${var.environment}-cost-reports"
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "cost_reports" {
  bucket = aws_s3_bucket.cost_reports.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cost_reports" {
  bucket = aws_s3_bucket.cost_reports.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "cost_reports" {
  bucket                  = aws_s3_bucket.cost_reports.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# -----------------------------------------------------------------
# Lambda Package - Zip the Python file for deployment
# -----------------------------------------------------------------
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.root}/lambda/cost_processor.py"
  output_path = "${path.module}/cost_processor.zip"
}

# -----------------------------------------------------------------
# Lambda Function
# -----------------------------------------------------------------
resource "aws_lambda_function" "cost_processor" {
  function_name    = "${var.project_name}-${var.environment}-processor"
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  role             = var.lambda_role_arn
  handler          = "cost_processor.lambda_handler"
  runtime          = var.lambda_runtime
  timeout          = var.lambda_timeout

  environment {
    variables = {
      COST_THRESHOLD = tostring(var.cost_alert_threshold)
      SNS_TOPIC_ARN  = var.sns_topic_arn
      CW_NAMESPACE   = var.cw_namespace
      REPORT_BUCKET  = aws_s3_bucket.cost_reports.bucket
    }
  }
}

# -----------------------------------------------------------------
# EventBridge Rule - Runs Lambda daily at 8am UTC
# -----------------------------------------------------------------
resource "aws_cloudwatch_event_rule" "daily_cost_check" {
  name                = "${var.project_name}-${var.environment}-daily-cost"
  description         = "Triggers Lambda cost processor daily"
  schedule_expression = "cron(0 8 * * ? *)"
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.daily_cost_check.name
  target_id = "CostProcessorLambda"
  arn       = aws_lambda_function.cost_processor.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowEventBridgeInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cost_processor.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.daily_cost_check.arn
}

# -----------------------------------------------------------------
# CloudWatch Dashboard
# -----------------------------------------------------------------
resource "aws_cloudwatch_dashboard" "cost_dashboard" {
  dashboard_name = "${var.project_name}-${var.environment}"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          title   = "Total Monthly AWS Cost USD"
          metrics = [[var.cw_namespace, "TotalMonthlyCost"]]
          period  = 86400
          stat    = "Maximum"
          region  = var.aws_region
          view    = "timeSeries"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          title   = "Cost by Service"
          metrics = [[var.cw_namespace, "ServiceCost"]]
          period  = 86400
          stat    = "Maximum"
          region  = var.aws_region
          view    = "bar"
        }
      }
    ]
  })
}
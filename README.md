# AWS Cost Dashboard - Lab 6

## Overview
This project deploys an automated AWS cost monitoring dashboard using:
- AWS Lambda (cost data processor)
- AWS Cost Explorer (cost data source)
- Amazon CloudWatch (dashboard and metrics)
- Amazon SNS (email alerts)
- Amazon S3 (cost report storage)

## Prerequisites
- Terraform >= 1.5.0
- AWS CLI configured with profile `lab6`
- Python 3.11

## Deployment
See deployment instructions. Never commit terraform.tfvars to version control.

## Architecture
EventBridge (daily schedule) triggers Lambda, which queries Cost Explorer,
publishes metrics to CloudWatch, stores reports in S3, and sends SNS alerts
when costs exceed the configured threshold.

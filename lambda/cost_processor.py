

import json
import boto3
import os
from datetime import datetime

def lambda_handler(event, context):

    ce_client  = boto3.client('ce')
    cw_client  = boto3.client('cloudwatch')
    sns_client = boto3.client('sns')

    today      = datetime.now()
    start_date = today.replace(day=1).strftime('%Y-%m-%d')
    end_date   = today.strftime('%Y-%m-%d')

    threshold  = float(os.environ.get('COST_THRESHOLD', '100'))
    sns_topic  = os.environ.get('SNS_TOPIC_ARN', '')
    namespace  = os.environ.get('CW_NAMESPACE', 'CostDashboard/Lab6')

    try:
        response = ce_client.get_cost_and_usage(
            TimePeriod={
                'Start': start_date,
                'End': end_date
            },
            Granularity='MONTHLY',
            Metrics=['UnblendedCost'],
            GroupBy=[
                {
                    'Type': 'DIMENSION',
                    'Key': 'SERVICE'
                }
            ]
        )

        total_cost = 0.0
        metric_data = []

        for result in response['ResultsByTime']:
            for group in result['Groups']:
                service = group['Keys'][0]
                amount  = float(group['Metrics']['UnblendedCost']['Amount'])
                total_cost += amount

                safe_service = service.replace(' ', '_').replace('/', '_')[:256]
                metric_data.append({
                    'MetricName': 'ServiceCost',
                    'Dimensions': [
                        {
                            'Name':  'Service',
                            'Value': safe_service
                        }
                    ],
                    'Value':     amount,
                    'Unit':      'None',
                    'Timestamp': today
                })

        metric_data.append({
            'MetricName': 'TotalMonthlyCost',
            'Value':      total_cost,
            'Unit':       'None',
            'Timestamp':  today
        })

        for i in range(0, len(metric_data), 20):
            cw_client.put_metric_data(
                Namespace=namespace,
                MetricData=metric_data[i:i+20]
            )

        if total_cost > threshold and sns_topic:
            sns_client.publish(
                TopicArn=sns_topic,
                Subject='AWS Cost Alert: ${:.2f} exceeds ${:.2f} threshold'.format(
                    total_cost, threshold
                ),
                Message=(
                    'Monthly AWS cost alert\n\n'
                    'Current Month-to-Date Cost: ${:.2f}\n'
                    'Alert Threshold:            ${:.2f}\n'
                    'Reporting Period:           {} to {}\n\n'
                    'Log into the AWS Console to review your Cost Explorer dashboard.'
                ).format(total_cost, threshold, start_date, end_date)
            )

        return {
            'statusCode': 200,
            'body': json.dumps({
                'message':    'Cost metrics published successfully',
                'total_cost': round(total_cost, 2),
                'period':     '{} to {}'.format(start_date, end_date)
            })
        }

    except Exception as e:
        print('ERROR: {}'.format(str(e)))
        raise e
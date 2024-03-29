# SQS Module with Monitoring

Usage of SQS module

```hcl
module "test_sqs" {
  source                   = "./modules/sqs"
  name                     = "test-sqs"
  environment              = "test"
  enable_cloudwatch_alarms = true
  owner                    = "qa"
  sqs_options = {
    enable_dlq = false
  }
  common_tags = local.common_tags

  cloudwatch_sns_topic = aws_sns_topic.monitoring.arn

  cloudwatch_alarm_options = [
    {
      metric              = "ApproximateNumberOfMessagesVisible"
      threshold           = "100"
      comparison_operator = "GreaterThanOrEqualToThreshold"
      severity            = "critical"
  }]
}
```

* This module creates SQS along with all requirements and predefined cloudwatch alerts.
* We can also modify/add cloudwatch alarms as per the requirements.
* Cloudwatch alarms will send the alert to SNS which is subscribed by Lambda.
* Lambda will process the event and send slack/email as per the owner of the resource which will be predefined.
* Lambda can be subscribed to cross region monitoring sns.
* We can also enable cross-account-cross-region monitoring on cloudwatch for creating alerts on single account.
* Lambda is writter on go and is available on scripts folder.

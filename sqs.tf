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
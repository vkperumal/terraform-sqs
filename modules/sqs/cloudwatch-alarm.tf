locals {
  list_alarms = concat([{
    metric              = "ApproximateNumberOfMessagesVisible"
    threshold           = "1"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    severity            = "warning"
    }, {
    metric              = "ApproximateNumberOfMessagesVisible"
    threshold           = "2"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    severity            = "critical"
  }], var.cloudwatch_alarm_options)
  distinct_alarms       = values(zipmap([for m in local.list_alarms : join(":", [m.metric, m.severity])], local.list_alarms))
  sqs_cloudwatch_alarms = var.enable_cloudwatch_alarms ? local.distinct_alarms : []
  dlq_cloudwatch_alarms = var.enable_cloudwatch_alarms && lookup(var.sqs_options, "enable_dlq", false) ? local.distinct_alarms : []
}

resource "aws_cloudwatch_metric_alarm" "sqs_alarm" {
  for_each            = { for index, alarm in local.sqs_cloudwatch_alarms : index => alarm }
  alarm_name          = "${var.name}-${each.value.metric}-${each.value.severity}-alarm"
  statistic           = "Sum"
  metric_name         = each.value.metric
  comparison_operator = coalesce(each.value.comparison_operator, "GreaterThanOrEqualToThreshold")
  threshold           = coalesce(each.value.threshold, "1")
  period              = 10
  evaluation_periods  = 2
  namespace           = "AWS/SQS"
  dimensions = {
    QueueName = aws_sqs_queue.sqs.name
  }
  alarm_actions = [var.cloudwatch_sns_topic]
  ok_actions    = [var.cloudwatch_sns_topic]

  tags = merge(var.common_tags,
    {
      Name        = "${var.name}-${each.value.metric}-alarm",
      Environment = var.environment,
      Owner       = var.owner,
  })
}

resource "aws_cloudwatch_metric_alarm" "dlq_alarm" {
  for_each            = { for index, alarm in local.dlq_cloudwatch_alarms : index => alarm }
  alarm_name          = "${var.name}-${each.value.metric}-${each.value.severity}-dlq-alarm"
  statistic           = "Sum"
  metric_name         = each.value.metric
  comparison_operator = coalesce(each.value.comparison_operator, "GreaterThanOrEqualToThreshold")
  threshold           = coalesce(each.value.threshold, "1")
  period              = 10
  evaluation_periods  = 2
  namespace           = "AWS/SQS"
  dimensions = {
    QueueName = aws_sqs_queue.dlq.0.name
  }
  alarm_actions = [var.cloudwatch_sns_topic]
  ok_actions    = [var.cloudwatch_sns_topic]

  tags = merge(var.common_tags,
    {
      Name        = "${var.name}-${each.value.metric}-alarm",
      Environment = var.environment,
      Owner       = var.owner,
  })
}
resource "aws_sns_topic" "monitoring" {
  name = "sqs-monitoring-topic"

  tags = merge(local.common_tags,
    {
      Name = "sqs-monitoring-topic"
  })
}
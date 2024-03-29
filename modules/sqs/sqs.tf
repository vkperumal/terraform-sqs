resource "aws_sqs_queue" "sqs" {
  name                              = lookup(var.sqs_options, "fifo_queue", false) ? "${var.name}.fifo" : var.name
  visibility_timeout_seconds        = lookup(var.sqs_options, "visibility_timeout_seconds", 30)
  delay_seconds                     = lookup(var.sqs_options, "delay_seconds", 0)
  max_message_size                  = lookup(var.sqs_options, "max_message_size", 262144)
  message_retention_seconds         = lookup(var.sqs_options, "max_message_retention_seconds", 345600)
  receive_wait_time_seconds         = lookup(var.sqs_options, "receive_wait_time_seconds", 0)
  fifo_queue                        = lookup(var.sqs_options, "fifo_queue", false)
  content_based_deduplication       = lookup(var.sqs_options, "fifo_queue", false) ? lookup(var.sqs_options, "content_based_duplication", false) : null
  fifo_throughput_limit             = lookup(var.sqs_options, "fifo_queue", false) ? lookup(var.sqs_options, "fifo_throughput_limit ", "perQueue") : null
  deduplication_scope               = lookup(var.sqs_options, "fifo_queue", false) ? lookup(var.sqs_options, "deduplication_scope", "queue") : null
  sqs_managed_sse_enabled           = lookup(var.sqs_options, "sqs_managed_sse_enabled", false)
  kms_master_key_id                 = lookup(var.sqs_options, "kms_master_key_id", null)
  kms_data_key_reuse_period_seconds = lookup(var.sqs_options, "kms_data_key_reuse_period_seconds", null)

  tags = merge(var.common_tags,
    {
      Name        = var.name,
      Environment = var.environment,
      Owner       = var.owner,
  })
}

resource "aws_sqs_queue_policy" "sqs_policy" {
  count     = lookup(var.sqs_options, "enable_sqs_policy", false) ? 1 : 0
  queue_url = aws_sqs_queue.sqs.url
  policy    = var.sqs_policy
}

resource "aws_sqs_queue_redrive_policy" "sqs_redrive_policy" {
  count     = lookup(var.sqs_options, "enable_dlq", false) ? 1 : 0
  queue_url = aws_sqs_queue.sqs.url
  redrive_policy = jsonencode({
    deadLetterTargetArn = element(aws_sqs_queue.dlq.*.arn, count.index)
    maxReceiveCount     = 4
  })
}

resource "aws_sqs_queue_redrive_allow_policy" "example" {
  count     = lookup(var.sqs_options, "enable_dlq", false) ? 1 : 0
  queue_url = element(aws_sqs_queue.dlq.*.url, count.index)

  redrive_allow_policy = jsonencode({
    redrivePermission = "byQueue",
    sourceQueueArns   = [aws_sqs_queue.sqs.arn]
  })
}

resource "aws_sqs_queue" "dlq" {
  count                             = lookup(var.sqs_options, "enable_dlq", false) ? 1 : 0
  name                              = lookup(var.sqs_options, "fifo_queue", false) ? "${var.name}-dlq.fifo" : "${var.name}-dlq"
  visibility_timeout_seconds        = lookup(var.sqs_options, "visibility_timeout_seconds", 30)
  delay_seconds                     = lookup(var.sqs_options, "delay_seconds", 0)
  max_message_size                  = lookup(var.sqs_options, "max_message_size", 262144)
  message_retention_seconds         = lookup(var.sqs_options, "max_message_retention_seconds", 345600)
  receive_wait_time_seconds         = lookup(var.sqs_options, "receive_wait_time_seconds", 0)
  fifo_queue                        = lookup(var.sqs_options, "fifo_queue", false)
  content_based_deduplication       = lookup(var.sqs_options, "fifo_queue", false) ? lookup(var.sqs_options, "content_based_duplication", false) : null
  fifo_throughput_limit             = lookup(var.sqs_options, "fifo_queue", false) ? lookup(var.sqs_options, "fifo_throughput_limit ", "perQueue") : null
  deduplication_scope               = lookup(var.sqs_options, "fifo_queue", false) ? lookup(var.sqs_options, "deduplication_scope", "queue") : null
  sqs_managed_sse_enabled           = lookup(var.sqs_options, "sqs_managed_sse_enabled", false)
  kms_master_key_id                 = lookup(var.sqs_options, "kms_master_key_id", null)
  kms_data_key_reuse_period_seconds = lookup(var.sqs_options, "kms_data_key_reuse_period_seconds", null)

  tags = merge(var.common_tags,
    {
      Name        = "${var.name}-dlq",
      Environment = var.environment,
      Owner       = var.owner,
  })
}

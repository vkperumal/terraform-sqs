output "sqs" {
  value = aws_sqs_queue.sqs
}

output "dlq" {
  value = aws_sqs_queue.dlq
}

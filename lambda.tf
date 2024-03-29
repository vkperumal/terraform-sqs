resource "null_resource" "monitoring_binary" {
  provisioner "local-exec" {
    command = "cd ./scripts/sqs-monitoring && GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o bootstrap -tags lambda.norpc sqs-monitoring.go"
  }
  triggers = {
    always_run = filemd5("./scripts/sqs-monitoring/sqs-monitoring.go")
  }
}

data "archive_file" "monitoring_lambda_function" {
  depends_on       = [null_resource.monitoring_binary]
  type             = "zip"
  source_file      = "./scripts/sqs-monitoring/bootstrap"
  output_file_mode = "0666"
  output_path      = "./files/monitoring_lambda.zip"
}

resource "aws_lambda_function" "monitoring" {
  function_name    = "monitoring"
  description      = "Lambda to send alerts"
  role             = aws_iam_role.monitoring_role.arn
  runtime          = "provided.al2"
  timeout          = "60"
  handler          = "bootstrap"
  memory_size      = 128
  filename         = data.archive_file.monitoring_lambda_function.output_path
  source_code_hash = data.archive_file.monitoring_lambda_function.output_base64sha256

  tags = merge(local.common_tags,
    {
      Name = "monitoring"
    }
  )
}

resource "aws_lambda_permission" "monitoring_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.monitoring.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.monitoring.arn
}

resource "aws_lambda_function_event_invoke_config" "monitoring" {
  function_name          = aws_lambda_function.monitoring.function_name
  maximum_retry_attempts = 0
}

resource "aws_sns_topic_subscription" "monitoring" {
  topic_arn = aws_sns_topic.monitoring.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.monitoring.arn
}

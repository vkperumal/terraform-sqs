resource "aws_iam_policy" "lambda_log_policy" {
  name   = "monitoring-cloudwatch-logs-lambda-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.lambda_log_group.json
}

resource "aws_iam_role" "monitoring_role" {
  name        = "monitoring-lambda-role"
  description = "Monitoring Lambda Role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
  tags = merge(local.common_tags,
    {
      Name = "monitoring_lambda_role"
    }
  )

}

resource "aws_iam_role_policy_attachment" "monitoring_lambda_policy_attachment" {
  role       = aws_iam_role.monitoring_role.name
  policy_arn = aws_iam_policy.lambda_log_policy.arn
}

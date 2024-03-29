data "aws_iam_policy_document" "lambda_log_group" {
  statement {
    sid = "LogAccess"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:*:*:*"
    ]
  }

  statement {
    sid = "SQSAccess"

    actions = [
      "sqs:GetQueueUrl",
      "sqs:ListQueueTags",
    ]
    resources = [
      "*"
    ]
  }
}

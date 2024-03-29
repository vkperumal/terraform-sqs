## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_metric_alarm.dlq_alarm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.sqs_alarm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_sqs_queue.dlq](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue) | resource |
| [aws_sqs_queue.sqs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue) | resource |
| [aws_sqs_queue_policy.sqs_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue_policy) | resource |
| [aws_sqs_queue_redrive_allow_policy.example](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue_redrive_allow_policy) | resource |
| [aws_sqs_queue_redrive_policy.sqs_redrive_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue_redrive_policy) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloudwatch_alarm_options"></a> [cloudwatch\_alarm\_options](#input\_cloudwatch\_alarm\_options) | Cloudwatch alarm options | <pre>list(object({<br>    metric              = string,<br>    threshold           = string,<br>    comparison_operator = string,<br>    severity            = string,<br>  }))</pre> | `[]` | no |
| <a name="input_cloudwatch_sns_topic"></a> [cloudwatch\_sns\_topic](#input\_cloudwatch\_sns\_topic) | n/a | `string` | `""` | no |
| <a name="input_common_tags"></a> [common\_tags](#input\_common\_tags) | Common Tags | `map(string)` | `{}` | no |
| <a name="input_enable_cloudwatch_alarms"></a> [enable\_cloudwatch\_alarms](#input\_enable\_cloudwatch\_alarms) | n/a | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | name of the instance | `string` | n/a | yes |
| <a name="input_owner"></a> [owner](#input\_owner) | owner of resource | `string` | n/a | yes |
| <a name="input_sqs_options"></a> [sqs\_options](#input\_sqs\_options) | SQS Options | `map(string)` | `{}` | no |
| <a name="input_sqs_policy"></a> [sqs\_policy](#input\_sqs\_policy) | SQS Policy | `any` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_dlq"></a> [dlq](#output\_dlq) | n/a |
| <a name="output_sqs"></a> [sqs](#output\_sqs) | n/a |

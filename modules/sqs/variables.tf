variable "name" {
  description = "name of the instance"
  type        = string
}

variable "environment" {
  type        = string
  description = "Environment"
}

variable "common_tags" {
  description = "Common Tags"
  type        = map(string)
  default     = {}
}

variable "sqs_options" {
  description = "SQS Options"
  type        = map(string)
  default     = {}
}

variable "enable_cloudwatch_alarms" {
  type    = bool
  default = true
}

variable "cloudwatch_sns_topic" {
  type    = string
  default = ""
}

variable "cloudwatch_alarm_options" {
  description = "Cloudwatch alarm options"
  type = list(object({
    metric              = string,
    threshold           = string,
    comparison_operator = string,
    severity            = string,
  }))
  default = []
}

variable "sqs_policy" {
  description = "SQS Policy"
  type        = any
  default     = ""
}

variable "owner" {
  type        = string
  description = "owner of resource"

  validation {
    condition     = contains(["qa", "data", "ops"], var.owner)
    error_message = "Valid values for var: owner are (qa, data, ops)."
  }
}
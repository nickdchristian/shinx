variable "application_name" {
  default     = "dryterraformapp"
  description = "Name of the application"
  type        = string
}
variable "environment" {
  description = "The environment where the application is running in"
  type        = string
}

variable "api_resource_name" {
  description = "Name of the resource for the API. Must be one word and lowercase"
  type        = string
}

variable "api_gateway_id" {
  description = "The API identifier"
  type        = string
}

variable "lambda_iam_policy" {
  description = "Lambda IAM policy in JSON"
  type        = string
}
variable "sns_alert_topic_arn" {
  type = string
}
variable "sns_okay_topic_arn" {
  type = string
}

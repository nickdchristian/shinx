variable "application_name" {
  description = "Name of the application"
  type        = string
}

variable "environment" {
  description = "The environment where the application is running in"
  type        = string
}
variable "sns_alert_topic_arn" {
  type = string
}
variable "sns_okay_topic_arn" {
  type = string
}
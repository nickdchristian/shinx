variable "application_name" {
  default = "dryterraformapp"
  description = "Name of the application"
  type    = string
}

variable "environment" {
  description = "The environment where the application is running in"
  type    = string
}
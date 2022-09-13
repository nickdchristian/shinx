module "api" {
  source = "./api"

  application_name    = var.application_name
  environment         = var.environment
  sns_alert_topic_arn = module.notifications.sns_alert_topic_arn
  sns_okay_topic_arn  = module.notifications.sns_okay_topic_arn
}

module "notifications" {
  source = "./notifications"

  application_name   = var.application_name
  environment        = var.environment
}
module "api_gateway" {
  source = "./api_gateway"

  application_name = var.application_name
  environment      = var.environment
}

module "app_function_api_resource" {
  source = "./api_resource"

  api_gateway_id          = module.api_gateway.api_gateway_id
  api_resource_name       = "rust_function"
  environment             = var.environment
  lambda_iam_policy   = data.aws_iam_policy_document.app_function_policy.json
  sns_alert_topic_arn = var.sns_alert_topic_arn
  sns_okay_topic_arn = var.sns_okay_topic_arn
}


data "aws_iam_policy_document" "app_function_policy" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = [
      "arn:aws:logs:*:*:*"
    ]
  }
}

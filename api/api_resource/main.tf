resource "aws_apigatewayv2_integration" "this" {
  api_id = var.api_gateway_id

  integration_uri    = aws_lambda_function.this.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "this" {
  api_id = var.api_gateway_id

  route_key = "GET /${var.api_resource_name}"
  target    = "integrations/${aws_apigatewayv2_integration.this.id}"
}

data "aws_apigatewayv2_api" "this" {
  api_id = var.api_gateway_id
}

resource "aws_lambda_permission" "this" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${data.aws_apigatewayv2_api.this.execution_arn}/*/*"
}


resource "random_id" "this" {
  byte_length = 8
}
resource "aws_lambda_function" "this" {
  filename         = data.archive_file.this.output_path
  function_name    = "${var.application_name}-${var.api_resource_name}-${var.environment}-${random_id.this.hex}"
  role             = aws_iam_role.this.arn
  handler          = "bootstrap"
  source_code_hash = data.archive_file.this.output_base64sha256
  publish          = true

  runtime = "provided"
}

resource "aws_lambda_alias" "this" {
  depends_on       = [null_resource.deployment]
  name             = "live"
  description      = "Live version of ${var.api_resource_name}"
  function_name    = aws_lambda_function.this.arn
  function_version = aws_lambda_function.this.version
}

resource "aws_cloudwatch_metric_alarm" "lambda_duration" {
  alarm_name          = "${aws_lambda_function.this.function_name}-lambda-duration-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "Duration"
  namespace           = "AWS/Lambda"
  period              = "60"
  statistic           = "Maximum"
  threshold           = aws_lambda_function.this.timeout
  alarm_description   = "Alarm to check if ${aws_lambda_function.this.function_name} duration is too high"
  treat_missing_data  = "ignore"
  alarm_actions       = [var.sns_alert_topic_arn]
  ok_actions          = [var.sns_okay_topic_arn]

  dimensions = {
    Resource = aws_lambda_function.this.qualified_arn
  }
}

resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  alarm_name          = "${aws_lambda_function.this.function_name}-lambda-errors-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = "60"
  statistic           = "Maximum"
  threshold           = "1"
  alarm_description   = "Alarm to check if ${aws_lambda_function.this.function_name} has errored"
  treat_missing_data  = "ignore"
  alarm_actions       = [var.sns_alert_topic_arn]
  ok_actions          = [var.sns_okay_topic_arn]

  dimensions = {
    Resource = aws_lambda_function.this.qualified_arn
  }
}

resource "aws_cloudwatch_metric_alarm" "throttle_count" {
  alarm_name          = "${aws_lambda_function.this.function_name}-lambda-errors-alarm"
  alarm_description   = "Alarm to check if ${aws_lambda_function.this.function_name} is throttled"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "5"
  metric_name         = "Throttles"
  namespace           = "AWS/Lambda"
  period              = "60"
  statistic           = "Sum"
  threshold           = "1"
  treat_missing_data  = "ignore"
  alarm_actions       = [var.sns_alert_topic_arn]
  ok_actions          = [var.sns_okay_topic_arn]

  dimensions = {
    Resource = aws_lambda_function.this.qualified_arn
  }
}

resource "null_resource" "build" {

 provisioner "local-exec" {

    command = "/bin/bash ${path.module}/build.sh"

   environment = {
      function_path = "${path.module}/../functions/${var.api_resource_name}/"
    }
  }
}

data "archive_file" "this" {
  depends_on = [null_resource.build]
  type        = "zip"
  source_dir  = "${path.module}/../functions/${var.api_resource_name}/target/x86_64-unknown-linux-musl/release/bootstrap"
  output_path = "${path.module}/files/${var.api_resource_name}.zip"
}

resource "aws_iam_role" "this" {
  name               = "${var.application_name}-${var.api_resource_name}-${var.environment}-role"
  assume_role_policy = data.aws_iam_policy_document.this_role.json
}

data "aws_iam_policy_document" "this_role" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}

resource "aws_iam_policy" "this" {
  name   = "${var.application_name}-${var.api_resource_name}-${var.environment}-policy"
  path   = "/"
  policy = var.lambda_iam_policy
}

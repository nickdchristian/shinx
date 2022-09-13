resource "local_file" "deployment" {
  content = templatefile("${path.module}/deployment.py", {
    function_name          = aws_lambda_function.this.function_name
    alias_name             = "live"
    target_lambda_version  = aws_lambda_function.this.version
    app_name               = aws_codedeploy_app.this.name
    deployment_group_name  = aws_codedeploy_deployment_group.this.deployment_group_name
    deployment_config_name = aws_codedeploy_deployment_group.this.deployment_config_name
  })
  filename = "${path.module}/files/deployment.py"
}

resource "null_resource" "deployment" {
  depends_on = [
    local_file.deployment
  ]
  provisioner "local-exec" {
    command = "python3 ${path.module}/files/deployment.py"
  }
  triggers = {
    deployment_file = base64sha256(local_file.deployment.content)
  }
}

resource "aws_codedeploy_app" "this" {
  compute_platform = "Lambda"
  name             = "${aws_lambda_function.this.function_name}-app"
}

resource "aws_codedeploy_deployment_group" "this" {
  app_name               = aws_codedeploy_app.this.name
  deployment_config_name = "CodeDeployDefault.LambdaCanary10Percent15Minutes"
  deployment_group_name  = "${aws_lambda_function.this.function_name}-deployment-group"
  service_role_arn       = aws_iam_role.codedeploy.arn

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  auto_rollback_configuration {
    enabled = true
    events  = [
      "DEPLOYMENT_FAILURE",
      "DEPLOYMENT_STOP_ON_ALARM",
      "DEPLOYMENT_STOP_ON_REQUEST"
    ]
  }

  alarm_configuration {
    alarms  = [aws_cloudwatch_metric_alarm.lambda_errors.alarm_name]
    enabled = true
  }

}

resource "aws_iam_role" "codedeploy" {
  name               = "${var.application_name}-${var.api_resource_name}-deploy-${var.environment}-role"
  assume_role_policy = data.aws_iam_policy_document.codedeploy.json
}

data "aws_iam_policy_document" "codedeploy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codedeploy.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "codedeploy" {
  role       = aws_iam_role.codedeploy.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRoleForLambda"
}
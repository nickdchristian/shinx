resource "aws_sns_topic" "alert" {
  name = "${var.application_name}-${var.environment}-alert-topic"
}

resource "aws_sns_topic" "okay" {
  name = "${var.application_name}-${var.environment}-okay-topic"
}


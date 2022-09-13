output "sns_alert_topic_arn" {
  value = aws_sns_topic.alert.arn
}
output "sns_okay_topic_arn" {
  value = aws_sns_topic.okay.arn
}
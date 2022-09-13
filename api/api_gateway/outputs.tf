output "api_arn" {
  value = aws_apigatewayv2_api.this.arn
}
output "api_endpoint" {
  value = aws_apigatewayv2_api.this.api_endpoint
}
output "api_gateway_id" {
  description = "The API identifier"
  value       = aws_apigatewayv2_api.this.id
}
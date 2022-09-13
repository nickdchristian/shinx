data "aws_cloudformation_stack" "state" {
  name = "shinx-terraform-state"
}
data "aws_region" "current" {}
terraform {
  backend "s3" {
    bucket         = data.aws_cloudformation_stack.state.outputs.Bucket
    key            = "terraform.tfstate"
    region         = data.aws_region.current.name
    dynamodb_table = data.aws_cloudformation_stack.state.outputs.Table
    encrypt        = true
  }
}
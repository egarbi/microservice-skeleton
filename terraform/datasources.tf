variable "tf_s3_bucket" {
  description = "This is where the terraform state file lives for the ECS VPC"

  default = {
    prod    = "lebara-infra-states"
    testing = "arabel-infra-states"
  }
}

data "terraform_remote_state" "vpc" {
  backend = "s3"

  config {
    bucket = "${lookup(var.tf_s3_bucket, terraform.env)}"
    region = "${var.region}"
    key    = "terraform"
  }
}

data "aws_sns_topic" "main" {
  name = "${lookup(var.sns_topic_name, terraform.env)}"
}

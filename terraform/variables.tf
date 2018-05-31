# AWS credentials and region
provider "aws" {
  region = "eu-west-1"
}

variable "name" {}
variable "image_version" {}
variable "tag" {}

variable "region" {
  default = "eu-west-1"
}

variable "env_prefix" {
  default = {
    testing = "arabel"
    prod    = "lebara"
  }
}

variable "desired_count" {
  default = {
    testing = 1
    prod    = 2
  }
}

variable "memory" {
  default = {
    testing = 384
    prod    = 512
  }
}

variable "cpu" {
  default = {
    testing = 128
    prod    = 256
  }
}

variable "priority" {}

variable "sns_topic_name" {
  default = {
    testing = "black-hole", // Noone will be paged
    prod     = "cloudwatch-events" // Victorops
  }
}

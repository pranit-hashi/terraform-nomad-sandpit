terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.21.0"
    }
  }
}

provider "aws" {
  alias = "syd"

  region = var.aws_region_1
}

provider "aws" {
  alias = "sgp"

  region = var.aws_region_2
}
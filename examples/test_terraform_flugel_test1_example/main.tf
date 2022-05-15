terraform {
  # This module is now only being tested with Terraform 0.13.x. However, to make upgrading easier, we are setting
  # 0.12.26 as the minimum version, as that version added support for required_providers with source URLs, making it
  # forwards compatible with 0.13.x code.
  required_version = ">= 0.12.26"
}

provider "aws" {
  region = "us-east-2"
}

resource "aws_instance" "nano" {
  ami           = "ami-0d5d9d301c853a04a"
  instance_type = "t3a.nano"

  tags = {
    Name  = var.tag_name,
    Owner = var.tag_owner
  }
}

resource "aws_s3_bucket" "b" {
  bucket = lower("${local.aws_account_id}-${var.tag_name}")

  tags = {
    Name  = var.tag_name,
    Owner = var.tag_owner
  }
}

resource "aws_s3_bucket_acl" "example" {
  bucket = aws_s3_bucket.b.id
  acl    = "private"
}

# ---------------------------------------------------------------------------------------------------------------------
# LOCALS
# Used to represent any data that requires complex expressions/interpolations
# ---------------------------------------------------------------------------------------------------------------------

data "aws_caller_identity" "current" {
}

locals {
  aws_account_id = data.aws_caller_identity.current.account_id
}

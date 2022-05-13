terraform {
  # This module is now only being tested with Terraform 0.13.x. However, to make upgrading easier, we are setting
  # 0.12.26 as the minimum version, as that version added support for required_providers with source URLs, making it
  # forwards compatible with 0.13.x code.
  required_version = ">= 0.12.26"
}

provider "aws" {
  region = "us-east-2"
}

resource "aws_key_pair" "my_key_pair" {
  key_name   = var.key_name
  public_key = file("${abspath(path.cwd)}/id.pub")
}

resource "aws_instance" "nano" {
  ami           = "ami-0fe23c115c3ba9bac"
  instance_type = "t3a.nano"
  key_name = aws_key_pair.my_key_pair.key_name

  tags = {
    Name  = var.tag_name,
    Owner = var.tag_owner
  }

  provisioner "file" {
    content     = <<EOT
    #!/usr/bin/python
    lines = ["Tags of the instance:\n", "Name: ${self.tags.Name}\n", "Owner: ${self.tags.Owner}"]
    file1 = open("index.html", "w")
    file1.writelines(lines)
    file1.close
    EOT
    destination = "/home/ec2-user/startup_helper.py"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("${abspath(path.cwd)}/id")
      host        = self.public_ip

    }
  }

  provisioner "remote-exec" {

    inline = [
      "sudo amazon-linux-extras enable python3.8",
      "sudo yum clean metadata && sudo yum -y install python38",
      "chmod +x /home/ec2-user/startup_helper.py",
      "/home/ec2-user/startup_helper.py"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("${abspath(path.cwd)}/id")
      host        = self.public_ip

    }
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

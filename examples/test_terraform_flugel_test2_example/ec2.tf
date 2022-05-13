resource "aws_key_pair" "my_key_pair" {
  key_name   = var.key_name
  public_key = file("${abspath(path.cwd)}/id.pub")
}

#resource "aws_instance" "control" {
##  count = 1
#
#  ami                    = "ami-0fe23c115c3ba9bac"
#  instance_type          = "t3a.nano"
#  key_name               = aws_key_pair.my_key_pair.key_name
#  vpc_security_group_ids = [aws_security_group.lb_sg.id]
#  subnet_id              = aws_subnet.sbnt_pub.id
#
#  tags = {
#    Name  = var.tag_name,
#    Owner = var.tag_owner
#  }
#}

resource "aws_instance" "nano" {
  count = 1

  ami           = "ami-0fe23c115c3ba9bac"
  instance_type = "t3a.nano"
  key_name = aws_key_pair.my_key_pair.key_name
  vpc_security_group_ids = [aws_security_group.lb_sg.id]
  subnet_id = aws_subnet.sbnt1.id

  tags = {
    Name  = "${var.tag_name}-${count.index}",
    Owner = var.tag_owner
  }

#  provisioner "file" {
#    content     = <<EOT
##!/usr/bin/python
#lines = ["Tags of the instance:\n", "Name: ${self.tags.Name}\n", "Owner: ${self.tags.Owner}"]
#file1 = open("index.html", "w")
#file1.writelines(lines)
#file1.close
#EOT
#    destination = "/home/ec2-user/startup_helper.py"
#
#    connection {
#      type        = "ssh"
#      user        = "ec2-user"
#      private_key = file("${abspath(path.cwd)}/id")
#      host        = self.public_ip
#
#    }
#  }
#
#  provisioner "remote-exec" {
#
#    inline = [
#      "sudo amazon-linux-extras enable python3.8",
#      "sudo amazon-linux-extras enable nginx1",
#      "sudo yum clean metadata && sudo yum -y install python38 && sudo yum -y install nginx && sudo systemctl start nginx.service",
#      "chmod +x /home/ec2-user/startup_helper.py",
#      "/home/ec2-user/startup_helper.py",
#      "sudo cp index.html /usr/share/nginx/html/"
#    ]
#
#    connection {
#      type        = "ssh"
#      user        = "ec2-user"
#      private_key = file("${abspath(path.cwd)}/id")
#      host        = self.public_ip
#
#    }
#  }
}
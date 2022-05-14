resource "aws_key_pair" "my_key_pair" {
  key_name   = var.key_name
  public_key = file("${abspath(path.cwd)}/id.pub")
}

resource "aws_instance" "nano" {
  count = 2

  ami           = "ami-0fe23c115c3ba9bac"
  instance_type = "t3a.nano"
  key_name = aws_key_pair.my_key_pair.key_name
  vpc_security_group_ids = [aws_security_group.lb_sg.id]
  subnet_id = aws_subnet.sbnt1.id

  tags = {
    Name  = var.tag_name,
    Owner = var.tag_owner
  }
  user_data = <<EOF
#!/usr/bin/bash
sudo amazon-linux-extras enable python3.8
sudo yum clean metadata && sudo yum -y install python38 && sudo amazon-linux-extras install -y nginx1 && sudo systemctl start nginx.service
echo '#!/usr/bin/python
import json
#lines = ["Tags of instance-${count.index}:\n", "Name: ${var.tag_name}\n", "Owner: ${var.tag_owner}"]
#file1 = open("index.html", "w")
#file1.writelines(lines)
#output = json.dumps({"Instance" : ${count.index}, "Name" : ${var.tag_name}, "Owner" : ${var.tag_owner}})
output = json.dumps({"Name" : "${var.tag_name}", "Owner" : "${var.tag_owner}"})
file1 = open("index.html", "w")
file1.write(output)
file1.close' > /home/ec2-user/startup_helper.py
chmod +x /home/ec2-user/startup_helper.py
/home/ec2-user/startup_helper.py
sudo cp index.html /usr/share/nginx/html/
EOF

# ------------------------------------------------------------------
# ----------------------- An alternative way -----------------------
# ------------------------------------------------------------------
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
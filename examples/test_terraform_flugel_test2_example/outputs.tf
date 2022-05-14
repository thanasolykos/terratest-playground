#output "instance_id" {
#  value = aws_instance.nano.id
#}
#
#output "public_dns" {
#  value = aws_instance.nano.public_dns
#}
output "alb_url" {
  value = "http://${aws_lb.nginx.dns_name}"
}

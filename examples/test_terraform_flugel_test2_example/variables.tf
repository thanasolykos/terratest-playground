variable "tag_name" {
  description = "Name for the tag in resources."
  type        = string
  default     = "Terraform"
}

variable "tag_owner" {
  description = "Owner for the tag in resources."
  type        = string
  default     = "Terraform"
}

variable "key_name" {
  description = "EC2 instace key pair."
  type        = string
  default     = "my_precious"
}

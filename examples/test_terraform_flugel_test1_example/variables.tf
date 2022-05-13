variable "tag_name" {
  description = "Name for the tag in resources."
  type        = string
  default     = "Flugl"
}

variable "tag_owner" {
  description = "Owner for the tag in resources."
  type        = string
  default     = "InfraTem"
}

variable "key_name" {
  description = "EC2 instace key pair."
  type        = string
  default     = "my_precious"
}
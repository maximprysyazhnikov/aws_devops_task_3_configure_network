variable "vpc_id" {
  description = "ID of existing VPC"
  type        = string
}

variable "my_ip_cidr" {
  description = "Your public IP in CIDR /32 (e.g. 37.52.92.49/32) for SSH access"
  type        = string
}

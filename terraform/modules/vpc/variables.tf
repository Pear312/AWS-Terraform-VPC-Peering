variable "env" {
  description = "Environment name for tagging"
  type        = string
}

variable "instance_number" {
  description = "Distinguishes multiple VPC instances"
  type        = string
}

variable "cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}


variable "igw_name" {
  description = "Name for internet gateway"
  type        = string
}


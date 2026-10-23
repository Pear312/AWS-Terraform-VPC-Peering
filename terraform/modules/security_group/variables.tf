variable "name" {
  description = "name of security group"
  type = string
}

variable "description" {
  description = "description of the security group"
  type = string
}

variable "vpc_id" {
  description = "VPC id"
  type = string
}

variable "ingress" {
  description = "inbound rules"
  type = list(object({
    description = string
    from_port  = number
    to_port    = number
    protocol   = string
    cidr_blocks = list(string)
  }))
  default = []
}

variable "egress" {
  description = "outbound rules"
  type = list(object({
    description = string
    from_port  = number
    to_port    = number
    protocol   = string
    cidr_blocks = list(string)
  }))
  default = []
}
variable "vpc_id" {
  description = "VPC id"
  type = string
}

variable "subnet_ids" {
  description = "list of subnet ids"
  type = list(string)
}

variable "ingress" {
  description = "inbound rules"
  type = list(object({
    protocol   = string
    rule_no    = number
    action     = string
    cidr_block = string
    from_port  = number
    to_port    = number
  }))
  default = []
}

variable "egress" {
  description = "outbound rules"
  type = list(object({
    protocol   = string
    rule_no    = number
    action     = string
    cidr_block = string
    from_port  = number
    to_port    = number
  }))
  default = []
}
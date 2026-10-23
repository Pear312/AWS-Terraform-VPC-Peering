variable "routetable_name"{
  description = "Name for route table"
  type        = string
}

variable "routes"{
  description = "A list of routes for the route table"
  type = list(object({
    cidr_block                 = string
    gateway_id                 = optional(string)
    nat_gateway_id             = optional(string)
    vpc_peering_connection_id  = optional(string)
  }))
  default = []
}

variable "vpc_id" {
  description = "VPC id"
  type        = string
}

variable "subnet_id" {
  type    = list(string)
  default = []
}


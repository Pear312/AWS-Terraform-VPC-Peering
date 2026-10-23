variable "name" {
  description = "Instance Name"
  type        = string
}

variable "ami" {
  description = "ami code"
  type        = string
}

variable "instance_type" {
  description = "Instance size"
  type        = string
  default     = "t2.micro"
}

variable "subnet_id" {
  description = "Subnet ID"
  type        = string
}
       
variable "security_group_ids" {
  description = "List of security group ids"
  type        = list(string)
}
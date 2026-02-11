variable "bastion_ingress" {
  default     = []
  type        = list(string)
  description = "CIDR blocks for bastion ingress"
}

variable "name" {
  description = "Name of the cloud resource"
  type        = string
}


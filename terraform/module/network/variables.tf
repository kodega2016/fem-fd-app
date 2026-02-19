variable "name" {
  type        = string
  description = "Name of the network"
}

variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones"
}

variable "cidr" {
  description = "The CIDR block for the vpc"
  type        = string
}


variable "bastion_ingress" {
  default     = []
  description = "List of CIDR blocks to whitelist for bastion host"
  type        = list(string)
}

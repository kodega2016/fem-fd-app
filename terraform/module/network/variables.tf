variable "name" {
  type        = string
  description = "The name of the vpc"
}

variable "availability_zones" {
  type        = list(string)
  description = "The availability zones for the vpc"
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

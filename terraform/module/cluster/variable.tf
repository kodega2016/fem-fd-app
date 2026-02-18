variable "name" {
  type = string
}

variable "security_groups" {
  type        = list(string)
  description = "The security groups for the ec2 instances for the cluster"
}


variable "capacity_providers" {
  type = map(object({
    instance_type = string
    spot          = bool
    volume_size   = number
    volume_type   = string
  }))
  description = "The capacity providers for the ec2 instance"
}

variable "subnets" {
  type        = list(string)
  description = "The subnet groups for the ec2 instances"
}

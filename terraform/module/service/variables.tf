variable "name" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "cluster_id" {
  type = string

}
variable "capacity_provider" {
  type = string
}

variable "secrets" {
  type = list(string)
}

variable "config" {
  default = {}
  type    = map(string)
}

variable "log_retention" {
  type    = string
  default = 7
}

variable "cpu" {
  default = 256
  type    = number
}

variable "image_registry" {
  default = "public.ecr.aws"
  type    = string
}

variable "image_repository" {
  default = "nginx/nginx"
  type    = string
}

variable "image_tag" {
  default = "alpine"
  type    = string
}

variable "memory" {
  default = 512
  type    = number
}


variable "port" {
  default = 80
  type    = number
}

variable "paths" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}
variable "listener_arn" {
  type = string
}

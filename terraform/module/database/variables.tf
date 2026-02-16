variable "name" {
  type        = string
  description = "The name for the database"
}

variable "engine" {
  type        = string
  description = "The database engine"
  default     = "postgres"
}

variable "engine_version" {
  type        = number
  description = "The database engine version"
  default     = 17.2
}

variable "instance_class" {
  type        = string
  description = "The database engine instance class"
  default     = "db.t4g.micro"

}

variable "security_groups" {
  type        = list(string)
  description = "The security groups for the database"
}

variable "vpc_name" {
  type        = string
  description = "The name of the vpc"
}

variable "subnets" {
  type        = list(string)
  description = "The subnets to deploy the database"
}

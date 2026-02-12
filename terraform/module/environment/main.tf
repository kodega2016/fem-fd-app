module "network" {
  source             = "../network"
  name               = var.name
  cidr               = var.cidr
  availability_zones = ["us-east-1a", "us-east-1b"]
}

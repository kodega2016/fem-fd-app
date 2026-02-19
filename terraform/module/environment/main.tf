module "network" {
  source             = "../network"
  name               = var.name
  cidr               = var.cidr
  availability_zones = ["us-east-1a", "us-east-1b"]
  bastion_ingress    = var.bastion_ingress
}
module "database" {
  source          = "../database"
  name            = var.name
  vpc_name        = module.network.vpc_name
  security_groups = [module.network.database_security_group]
  subnets         = module.network.database_subnets
}

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

module "cluster" {
  source          = "../cluster"
  name            = var.name
  vpc_id          = module.network.vpc_id
  security_groups = [module.network.private_security_groups]
  subnets         = module.network.private_subnets
  capacity_providers = {
    "spot" = {
      instance_type = "t3.medium"
      spot          = true
      volume_size   = 50
      volume_type   = "gp2"
    }
  }
}

module "network" {
  source             = "../network"
  name               = var.name
  cidr               = var.cidr
  availability_zones = ["us-east-1a", "us-east-1b"]
  bastion_ingress    = var.bastion_ingress
}

# module "database" {
#   source          = "../database"
#   name            = var.name
#   vpc_name        = module.network.vpc_name
#   security_groups = [module.network.database_security_group]
#   subnets         = module.network.database_subnets
# }

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


# module "service" {
#   source            = "../service"
#   capacity_provider = "spot"
#   cluster_id        = module.cluster.cluster_arn
#   cluster_name      = var.name
#   image_registry    = "${data.aws_caller_identity.this.account_id}.dkr.ecr.${data.aws_region.this.region}.amazonaws.com"
#   image_repository  = "fem-fd-service-preview"
#   image_tag         = var.name
#   listener_arn      = module.cluster.listener_arn
#   name              = "service"
#   paths             = ["/*"]
#   port              = 8080
#   vpc_id            = module.network.vpc_id

#   config = {
#     GOOGLE_REDIRECT_URL = "https://${module.cluster.distribution_domain}/auth/google/callback"
#     GOOSE_DRIVER        = "postgres"
#   }

#   secrets = [
#     "GOOGLE_CLIENT_ID",
#     "GOOGLE_CLIENT_SECRET",
#     "GOOSE_DBSTRING",
#     "POSTGRES_URL",
#   ]
# }

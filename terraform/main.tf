module "staging" {
  source          = "./module/environment"
  name            = "staging"
  cidr            = "10.0.0.0/16"
  bastion_ingress = local.bastion_ingress
}

module "prod" {
  source          = "./module/environment"
  name            = "prod"
  cidr            = "10.100.0.0/16"
  bastion_ingress = local.bastion_ingress
}

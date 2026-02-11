module "security_group_bastion" {
  source = "terraform-aws-modules/security-group/aws"

  name               = "${var.name}-bastion"
  description        = "Security group for bastion server"
  vpc_id             = module.vpc.vpc_id
  egress_cidr_blocks = ["0.0.0.0/0"]
  ingress_with_cidr_blocks = [
    for cidr in var.bastion_ingress : {
      cidr_blocks = cidr
      rule        = "ssh-tcp"
    }
  ]
  ingress_with_self = [
    {
      rule = "all-all"
    }
  ]
  egress_with_self = [
    {
      rule = "all-all"
    }
  ]
}

module "security_group_db" {
  source = "terraform-aws-modules/security-group/aws"

  name               = "${var.name}-db"
  description        = "Security group for database"
  vpc_id             = module.vpc.vpc_id
  egress_cidr_blocks = ["0.0.0.0/0"]
  ingress_with_self = [
    {
      rule = "all-all"
    }
  ]
  egress_with_self = [
    {
      rule = "all-all"
    }
  ]
}

module "security_group_elasticache" {
  source = "terraform-aws-modules/security-group/aws"

  name               = "${var.name}-elasticache"
  description        = "Security group for elastic cache"
  vpc_id             = module.vpc.vpc_id
  egress_cidr_blocks = ["0.0.0.0/0"]
  ingress_with_self = [
    {
      rule = "all-all"
    }
  ]
  egress_with_self = [
    {
      rule = "all-all"
    }
  ]
}

module "security_group_private" {
  source = "terraform-aws-modules/security-group/aws"

  name               = "${var.name}-private"
  description        = "Security group for private subnets"
  vpc_id             = module.vpc.vpc_id
  egress_cidr_blocks = ["0.0.0.0/0"]
  ingress_with_self = [
    {
      rule = "all-all"
    }
  ]
  egress_with_self = [
    {
      rule = "all-all"
    }
  ]
}

resource "aws_vpc_security_group_ingress_rule" "db_allow_private" {
  description                  = "Allow private subnet to access db"
  security_group_id            = module.security_group_db.security_group_id
  referenced_security_group_id = module.security_group_private.security_group_id
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
}


resource "aws_vpc_security_group_ingress_rule" "elasticache_allow_private" {
  description                  = "Allow private subnet to access elasticache"
  security_group_id            = module.security_group_elasticache.security_group_id
  referenced_security_group_id = module.security_group_private.security_group_id
  from_port                    = 6379
  to_port                      = 6379
  ip_protocol                  = "tcp"
}

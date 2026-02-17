resource "random_string" "password" {
  length  = 32
  special = false
}

resource "aws_ssm_parameter" "password" {
  name  = "/${var.name}/database/password"
  type  = "SecureString"
  value = random_string.password.result
}

module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "7.1.0"

  allocated_storage                   = 50
  create_db_option_group              = false
  create_db_parameter_group           = false
  create_db_subnet_group              = false
  create_monitoring_role              = false
  db_subnet_group_name                = var.vpc_name
  engine                              = var.engine
  engine_version                      = var.engine_version
  iam_database_authentication_enabled = false
  identifier                          = var.name
  instance_class                      = var.instance_class
  manage_master_user_password         = false
  max_allocated_storage               = 100
  option_group_name                   = "default:postgres-17"
  parameter_group_name                = "default.postgres17"
  password_wo                         = random_string.password.result
  password_wo_version                 = 0
  publicly_accessible                 = false
  skip_final_snapshot                 = true
  username                            = replace(var.name, "-", "_")
  vpc_security_group_ids              = var.security_groups
}

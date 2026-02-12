resource "tls_private_key" "bastion" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "bastion" {
  key_name   = "${var.name}-bastion"
  public_key = tls_private_key.bastion.public_key_openssh
}


module "secret" {
  source      = "terraform-aws-modules/ssm-parameter/aws"
  name        = "/${var.name}/bastion/private-key"
  value       = tls_private_key.bastion.private_key_pem
  secure_type = true
}


module "ec2_instance" {
  source                      = "terraform-aws-modules/ec2-instance/aws"
  name                        = "${var.name}-bastion"
  instance_type               = "t3a.micro"
  monitoring                  = true
  subnet_id                   = module.vpc.public_subnets[0]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.bastion.key_name


  vpc_security_group_ids = [
    module.security_group_bastion.security_group_id,
    module.security_group_private.security_group_id,
  ]
}

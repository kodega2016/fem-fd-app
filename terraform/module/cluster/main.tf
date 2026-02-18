resource "aws_ecs_cluster" "this" {
  name = var.name

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_iam_role" "this" {
  name               = var.name
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_policy_attachment" "service_role" {
  name       = var.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerServiceForEC2Role"
  roles      = [aws_iam_role.this.name]
}


resource "aws_iam_instance_profile" "this" {
  name = var.name
  role = aws_iam_role.this.name
}

resource "tls_private_key" "this" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "this" {
  key_name   = "${var.name}-cluster"
  public_key = tls_private_key.this.public_key_openssh
}


module "private-key" {
  source  = "terraform-aws-modules/ssm-parameter/aws"
  version = "2.1.0"

  name        = "/${var.name}/cluster/private-key"
  value       = tls_private_key.this.private_key_pem
  secure_type = true
}


resource "aws_launch_template" "this" {
  for_each = {
    for provider_name, provider in var.capacity_providers : provider_name => provider
  }


  name_prefix   = "${var.name}-${each.key}-"
  instance_type = each.value.instance_type
  image_id      = jsondecode(data.aws_ssm_parameter.ecs-optimized-ami.value)["image_id"]
  key_name      = aws_key_pair.this.key_name


  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = each.value.volume_size
      volume_type           = each.value.volume_type
      delete_on_termination = true
    }
  }

  network_interfaces {
    security_groups             = var.security_groups
    associate_public_ip_address = false
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.this.name
  }


  instance_market_options {
    market_type = each.value.spot ? "spot" : "on-demand"
  }

  user_data = base64encode(templatefile("${path.module}/user_data.tpl", {
    cluster_name = var.name
  }))
}


resource "aws_autoscaling_group" "this" {
  for_each = {
    for provider_name, provider in var.capacity_providers : provider_name => provider
  }

  name_prefix         = "${var.name}-${each.key}-"
  desired_capacity    = 1
  min_size            = 1
  max_size            = 5
  vpc_zone_identifier = var.subnets

  launch_template {
    id      = aws_launch_template.this[each.key].id
    version = "$Latest"
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
    triggers = ["tag"]
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = true
    propagate_at_launch = true
  }

  tag {
    key                 = "Name"
    value               = var.name
    propagate_at_launch = true
  }
}

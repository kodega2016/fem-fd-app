module "parameter_secure" {
  source = "terraform-aws-modules/ssm-parameter/aws"

  for_each             = { for item in var.secrets : item => item }
  name                 = "/${var.cluster_name}/service/${lower(replace(each.key, "-", "_"))}"
  value                = "some-value"
  ignore_value_changes = true
  secure_type          = true
}

resource "aws_cloudwatch_log_group" "this" {
  name              = local.fullname
  retention_in_days = var.log_retention
}

resource "aws_iam_role" "execution" {
  assume_role_policy = data.aws_iam_policy_document.execution_assume_role.json
  name               = "${local.fullname}-execution"
}

resource "aws_iam_policy" "execution_policy" {
  count  = length(var.secrets) > 0 ? 1 : 0
  name   = "${local.fullname}-execution"
  policy = data.aws_iam_policy_document.execution_policy.json
}

resource "aws_iam_role_policy_attachment" "execution_policy" {
  count = length(var.secrets) > 0 ? 1 : 0

  role       = aws_iam_role.execution.name
  policy_arn = aws_iam_policy.execution_policy[0].arn
}

resource "aws_iam_role_policy_attachment" "execution_ecr" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.execution.name
}

resource "aws_iam_role_policy_attachment" "execution_ec2" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
  role       = aws_iam_role.execution.name
}

resource "aws_iam_role" "task" {
  assume_role_policy = data.aws_iam_policy_document.task_assume_role.json
  name               = "${local.fullname}-task"
}


resource "aws_ecs_task_definition" "this" {
  family             = local.fullname
  execution_role_arn = aws_iam_role.execution.arn
  task_role_arn      = aws_iam_role.task.arn


  container_definitions = jsonencode([
    {
      name         = var.name
      image        = "${var.image_registry}/${var.image_repository}:${var.image_tag}"
      cpu          = var.cpu
      memory       = var.memory
      essential    = true
      portMappings = var.port != null ? [{ containerPort = var.port }] : [],

      environment = [
        for item_name, item in var.config : {
          name  = upper(replace(item_name, "-", "_"))
          value = item
        }
      ]

      secrets = [
        for item in var.secrets : {
          name      = upper(replace(item, "-", "_"))
          valueFrom = module.parameter_secure[item].ssm_parameter_arn
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.this.name
          "awslogs-region"        = data.aws_region.this.region
          "awslogs-stream-prefix" = "svc"
        }
      }
    }
  ])
}


resource "aws_ecs_service" "this" {
  cluster         = var.cluster_id
  desired_count   = 1
  name            = local.fullname
  task_definition = aws_ecs_task_definition.this.arn

  capacity_provider_strategy {
    base              = 1
    capacity_provider = "${var.cluster_name}-${var.capacity_provider}"
    weight            = 100
  }

  load_balancer {
    container_name   = var.name
    container_port   = var.port
    target_group_arn = aws_lb_target_group.service.arn
  }
}

resource "aws_lb_target_group" "service" {
  deregistration_delay              = 60
  load_balancing_cross_zone_enabled = true
  port                              = var.port
  protocol                          = "HTTP"
  vpc_id                            = var.vpc_id
}

resource "aws_lb_listener_rule" "service" {
  listener_arn = var.listener_arn

  action {
    target_group_arn = aws_lb_target_group.service.arn
    type             = "forward"
  }

  condition {
    path_pattern {
      values = var.paths
    }
  }
}

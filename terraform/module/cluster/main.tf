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


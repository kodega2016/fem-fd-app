data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}


data "aws_ssm_parameter" "ecs-optimized-ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended"
}

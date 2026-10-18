# Shape-valid fake values for attributes the AWS provider validates as ARNs.
# The mock provider otherwise fills computed strings with random text, which
# fails the provider's own ARN checks on resources that reference them.

mock_data "aws_caller_identity" {
  defaults = {
    account_id = "111122223333"
  }
}

mock_data "aws_kms_alias" {
  defaults = {
    arn            = "arn:aws:kms:us-east-1:111122223333:alias/mock"
    target_key_arn = "arn:aws:kms:us-east-1:111122223333:key/00000000-0000-0000-0000-000000000000"
  }
}

mock_data "aws_ssm_parameter" {
  defaults = {
    value = "ami-0123456789abcdef0"
  }
}

mock_resource "aws_iam_role" {
  defaults = {
    arn = "arn:aws:iam::111122223333:role/mock"
  }
}

mock_resource "aws_iam_instance_profile" {
  defaults = {
    arn = "arn:aws:iam::111122223333:instance-profile/mock"
  }
}

mock_resource "aws_kms_key" {
  defaults = {
    arn = "arn:aws:kms:us-east-1:111122223333:key/00000000-0000-0000-0000-000000000000"
  }
}

mock_resource "aws_sns_topic" {
  defaults = {
    arn = "arn:aws:sns:us-east-1:111122223333:mock-alarms"
  }
}

mock_resource "aws_s3_bucket" {
  defaults = {
    arn = "arn:aws:s3:::mock-bucket"
  }
}

mock_resource "aws_lb" {
  defaults = {
    arn        = "arn:aws:elasticloadbalancing:us-east-1:111122223333:loadbalancer/app/mock/0123456789abcdef"
    arn_suffix = "app/mock/0123456789abcdef"
  }
}

mock_resource "aws_lb_target_group" {
  defaults = {
    arn        = "arn:aws:elasticloadbalancing:us-east-1:111122223333:targetgroup/mock/0123456789abcdef"
    arn_suffix = "targetgroup/mock/0123456789abcdef"
  }
}

mock_resource "aws_lb_listener" {
  defaults = {
    arn = "arn:aws:elasticloadbalancing:us-east-1:111122223333:listener/app/mock/0123456789abcdef/0123456789abcdef"
  }
}

mock_resource "aws_lb_listener_rule" {
  defaults = {
    arn = "arn:aws:elasticloadbalancing:us-east-1:111122223333:listener-rule/app/mock/0123456789abcdef/0123456789abcdef/0123456789abcdef"
  }
}

mock_resource "aws_ecs_task_definition" {
  defaults = {
    arn = "arn:aws:ecs:us-east-1:111122223333:task-definition/mock:1"
  }
}

mock_resource "aws_ecs_cluster" {
  defaults = {
    arn = "arn:aws:ecs:us-east-1:111122223333:cluster/mock"
  }
}

mock_resource "aws_autoscaling_group" {
  defaults = {
    arn = "arn:aws:autoscaling:us-east-1:111122223333:autoScalingGroup:00000000-0000-0000-0000-000000000000:autoScalingGroupName/mock"
  }
}

mock_resource "aws_launch_template" {
  defaults = {
    id  = "lt-0123456789abcdef0"
    arn = "arn:aws:ec2:us-east-1:111122223333:launch-template/lt-0123456789abcdef0"
  }
}

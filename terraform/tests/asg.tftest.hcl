# Regression test for the 1.3.1 user-data bug: with an indented <<EOF heredoc
# the script started with four spaces, cloud-init could not exec it and the
# instances never joined their cluster.

mock_provider "aws" {
  source          = "./tests/mocks"
  override_during = plan
}

run "user_data_starts_with_a_shebang" {
  command = plan

  module {
    source = "./asg"
  }

  variables {
    name                   = "test-app"
    ecs_cluster_name       = "test-app-cluster"
    ecs_instance_role_name = "test-app-EcsInstanceRole"
    asg_ec2_image_id       = "ami-0123456789abcdef0"
    asg_ec2_instance_type  = "t3.large"
    security_group_ids     = ["sg-0123456789abcdef0"]
    asg_desired_capacity   = 2
    asg_max_size           = 4
    asg_min_size           = 2
    private_subnets        = ["subnet-0000000000000000c", "subnet-0000000000000000d"]
  }

  assert {
    condition     = startswith(base64decode(aws_launch_template.ecs_ec2.user_data), "#!/bin/bash\n")
    error_message = "User data must start with #!/bin/bash at byte 0 or cloud-init cannot run it."
  }

  assert {
    condition     = strcontains(base64decode(aws_launch_template.ecs_ec2.user_data), "\necho ECS_CLUSTER=test-app-cluster >> /etc/ecs/ecs.config;")
    error_message = "User data must register the instance with its own cluster, unindented."
  }

  assert {
    condition     = aws_launch_template.ecs_ec2.metadata_options[0].http_tokens == "required"
    error_message = "IMDSv2 must stay required."
  }
}

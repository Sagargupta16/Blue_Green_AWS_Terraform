variable "name" {
    description = "The name of the CodeDeploy application used for blue-green deployments"
    type = string
}
variable "vpc_id" {
    description = "The ID of the VPC where CodeDeploy resources will operate"
    type = string
}
variable "app_task_role_arn" {
    description = "The ARN of the IAM role assigned to ECS tasks for application-level permissions"
    type = string
}
variable "task_definition_arn" {
    description = "The ARN of the ECS task definition used for deployment"
    type = string
}
variable "public_subnets" {
    description = "List of public subnet IDs where load balancer and public-facing resources are deployed"
    type = list(string)
}
variable "asg_ec2_ami_name" {
    description = "The name of the Amazon Machine Image (AMI) used for Auto Scaling Group instances"
    type = string
}
variable "asg_ec2_instance_type" {
    description = "The EC2 instance type for Auto Scaling Group instances supporting the deployment"
    type = string
}
variable "asg_desired_capacity" {
    description = "The desired number of EC2 instances in the Auto Scaling Group for deployment"
    type = number
}
variable "asg_max_size" {
    description = "The maximum number of EC2 instances allowed in the Auto Scaling Group during deployment"
    type = number
}
variable "asg_min_size" {
    description = "The minimum number of EC2 instances required in the Auto Scaling Group during deployment"
    type = number
}
variable "desired_count" {
    description = "The desired number of running ECS tasks for the application deployment"
    type = number
}
variable "container_name" {
    description = "The name of the application container in the ECS task definition"
    type = string
}
variable "container_port" {
    description = "The port number on which the application container listens for traffic"
    type = number
}
variable "private_subnets" {
    description = "List of private subnet IDs where application instances and internal resources are deployed"
    type = list(string)
}
variable "ecs_instance_role_name" {
    description = "The name of the IAM role attached to ECS instances for AWS service access"
    type = string
}
variable "s3_bucket_name" {
    description = "The name of the S3 bucket used for storing deployment artifacts and application revisions"
    type = string
}

variable "tags" {
    description = "A map of tags to assign to CodeDeploy resources for resource management and cost tracking"
    type        = map(string)
    default     = {}
}
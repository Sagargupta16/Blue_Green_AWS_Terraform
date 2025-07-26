variable "name" {
    description = "The name of the ECS cluster that will host the containerized application"
    type = string
}
variable "vpc_id" {
    description = "The ID of the VPC where the ECS cluster and related resources will be deployed"
    type = string
}
variable "public_subnets" {
    description = "List of public subnet IDs where load balancers and public-facing ECS resources are deployed"
    type = list(string)
}
variable "asg_ec2_ami_name" {
    description = "The name of the Amazon Machine Image (AMI) used for ECS container instances"
    type = string
}
variable "asg_ec2_instance_type" {
    description = "The EC2 instance type for ECS container instances in the cluster"
    type = string
}
variable "asg_desired_capacity" {
    description = "The desired number of ECS container instances in the Auto Scaling Group"
    type = number
}
variable "asg_max_size" {
    description = "The maximum number of ECS container instances allowed in the Auto Scaling Group"
    type = number
}
variable "asg_min_size" {
    description = "The minimum number of ECS container instances required in the Auto Scaling Group"
    type = number
}
variable "desired_count" {
    description = "The desired number of running tasks for the ECS service"
    type = number
}
variable "container_name" {
    description = "The name of the application container defined in the ECS task definition"
    type = string
}
variable "container_port" {
    description = "The port number on which the application container listens for incoming traffic"
    type = number
}
variable "private_subnets" {
    description = "List of private subnet IDs where ECS container instances and internal resources are deployed"
    type = list(string)
}
variable "task_definition_arn" {
    description = "The ARN of the ECS task definition that defines the containerized application"
    type = string
}
variable "ecs_instance_role_name" {
    description = "The name of the IAM role attached to ECS container instances for AWS service access"
    type = string
}
variable "s3_bucket_name" {
    description = "The name of the S3 bucket used for storing ECS-related artifacts and logs"
    type = string
}

variable "tags" {
    description = "A map of tags to assign to ECS cluster and service resources for resource management and cost tracking"
    type        = map(string)
    default     = {}
}
variable "name" {
    description = "The name of the Auto Scaling Group used for resource identification and tagging"
    type = string
}
variable "asg_ec2_image_id" {
    description = "The Amazon Machine Image (AMI) ID used to launch EC2 instances in the Auto Scaling Group"
    type = string
}
variable "asg_ec2_instance_type" {
    description = "The EC2 instance type for Auto Scaling Group instances (e.g., t3.micro, t3.small, m5.large)"
    type = string
}
variable "security_group_ids" {
    description = "List of security group IDs to attach to the Auto Scaling Group instances for network access control"
    type = list(string)
}
variable "asg_desired_capacity" {
    description = "The desired number of EC2 instances that should be running in the Auto Scaling Group"
    type = number
}
variable "asg_max_size" {
    description = "The maximum number of EC2 instances allowed in the Auto Scaling Group"
    type = number
}
variable "asg_min_size" {
    description = "The minimum number of EC2 instances required in the Auto Scaling Group"
    type = number
}
variable "private_subnets" {
    description = "List of private subnet IDs where the Auto Scaling Group instances will be deployed"
    type = list(string)
}
variable "ecs_cluster_name" {
    description = "The name of the ECS cluster that the Auto Scaling Group instances will join"
    type = string
}
variable "ecs_instance_role_name" {
    description = "The name of the IAM role attached to ECS instances for AWS service permissions"
    type = string
}

variable "tags" {
    description = "A map of tags to assign to Auto Scaling Group resources for resource management and cost tracking"
    type        = map(string)
    default     = {}
}

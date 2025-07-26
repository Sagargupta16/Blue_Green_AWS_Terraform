variable "name" {
    description = "Name of the ECS Cluster"
    type = string
}
variable "vpc_id" {
    description = "VPC ID"
    type = string
}
variable "public_subnets" {
    description = "Public Subnets"
    type = list(string)
}
variable "asg_ec2_ami_name" {
    description = "AMI Name"
    type = string
}
variable "asg_ec2_instance_type" {
    description = "Instance Type"
    type = string
}
variable "asg_desired_capacity" {
    description = "Desired Capacity"
    type = number
}
variable "asg_max_size" {
    description = "Max Size"
    type = number
}
variable "asg_min_size" {
    description = "Min Size"
    type = number
}
variable "desired_count" {
    description = "Desired Count"
    type = number
}
variable "container_name" {
    description = "Container Name"
    type = string
}
variable "container_port" {
    description = "Container Port"
    type = number
}
variable "private_subnets" {
    description = "Private Subnets"
    type = list(string)
}
variable "task_definition_arn" {
    description = "Task Definition ARN"
    type = string
}
variable "ecs_instance_role_name" {
    description = "ECS Instance Role Name"
    type = string
}
variable "s3_bucket_name" {
    description = "S3 Bucket Name"
    type = string
}
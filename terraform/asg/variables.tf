variable "name" {
    description = "Name of the ASG"
    type = string
}
variable "asg_ec2_image_id" {
    description = "AMI ID"
    type = string
}
variable "asg_ec2_instance_type" {
    description = "Instance Type"
    type = string
}
variable "security_group_ids" {
    description = "Security Group IDs"
    type = list(string)
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
variable "private_subnets" {
    description = "Private Subnets"
    type = list(string)
}
variable "ecs_cluster_name" {
    description = "ECS Cluster Name"
    type = string
}
variable "ecs_instance_role_name" {
    description = "ECS Instance Role Name"
    type = string
}

variable "vpc_id" {
    description = "The ID of the VPC where the Application Load Balancer will be deployed"
    type = string
}

variable "name" {
    description = "The name of the Application Load Balancer used for resource identification"
    type = string
}

variable "subnets" {
    description = "List of subnet IDs where the Application Load Balancer will be deployed across multiple AZs"
    type = list(string)
}

variable "security_group_ids" {
    description = "List of security group IDs to attach to the Application Load Balancer for network access control"
    type = list(string)
}

variable "tags" {
    description = "A map of tags to assign to Application Load Balancer resources for resource management and cost tracking"
    type        = map(string)
    default     = {}
}

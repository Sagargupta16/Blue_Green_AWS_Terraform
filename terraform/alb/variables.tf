variable "vpc_id" {
    description = "VPC ID"
    type = string
}

variable "name" {
    description = "Name of the ALB"
    type = string
}

variable "subnets" {
    description = "Subnets to deploy the ALB"
    type = list(string)
}

variable "security_group_ids" {
    description = "Security Group IDs"
    type = list(string)
}

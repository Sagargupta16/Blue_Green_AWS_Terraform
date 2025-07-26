variable "name" {
    description = "The name of the security group used for controlling network access to infrastructure resources"
    type        = string
}
variable "vpc_id" {
    description = "The ID of the VPC where the security group will be created to control network traffic"
    type        = string
}

variable "tags" {
    description = "A map of tags to assign to security groups for resource management and cost tracking"
    type        = map(string)
    default     = {}
}
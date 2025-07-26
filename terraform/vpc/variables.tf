variable "vpc_cidr" {
    description = "CIDR block for the Virtual Private Cloud (VPC) that defines the IP address range for the network"
    type        = string
}
variable "availability_zones" {
    description = "List of AWS availability zones where subnets will be created for high availability deployment"
    type        = list(string)
}
variable "tags" {
    description = "A map of tags to assign to VPC resources for resource management and cost tracking"
    type        = map(string)
    default     = {}
}
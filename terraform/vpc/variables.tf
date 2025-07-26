variable "vpc_cidr" {
    description = "VPC CIDR"
    type        = string
}
variable "availability_zones" {
    description = "Availability Zones"
    type        = list(string)
}
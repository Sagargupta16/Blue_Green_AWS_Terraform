################################################################################
# VPC Module - outputs.tf
################################################################################

output "vpc_id" {
  description = "ID of the VPC."
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "IDs of the two public subnets (one per AZ)."
  value       = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]
}

output "private_subnet_ids" {
  description = "IDs of the two private subnets (one per AZ)."
  value       = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
}

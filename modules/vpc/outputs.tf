# VPC
output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.vpc.id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = aws_vpc.vpc.cidr_block
}

output "default_security_group_id" {
  description = "The ID of the security group created by default on VPC creation"
  value       = aws_vpc.vpc.default_security_group_id
}

output "default_network_acl_id" {
  description = "The ID of the default network ACL"
  value       = aws_vpc.vpc.default_network_acl_id
}

# Subnets
output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = [aws_subnet.private.*.id]
}

output "private_subnets_cidr_blocks" {
  description = "List of cidr_blocks of private subnets"
  value       = [aws_subnet.private.*.cidr_block]
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = [aws_subnet.public.*.id]
}

output "public_subnets_cidr_blocks" {
  description = "List of cidr_blocks of public subnets"
  value       = [aws_subnet.public.*.cidr_block]
}

# Route tables
output "public_route_table_ids" {
  description = "List of IDs of public route tables"
  value       = [aws_route_table.public.*.id]
}

output "private_route_table_ids" {
  description = "List of IDs of private route tables"
  value       = [aws_route_table.private.*.id]
}

output "nat_ids" {
  description = "List of allocation ID of Elastic IPs created for AWS NAT Gateway"
  value       = [aws_eip.nat.*.id]
}

output "nat_public_ips" {
  description = "List of public Elastic IPs created for AWS NAT Gateway"
  value       = [aws_eip.nat.*.public_ip]
}

output "natgw_ids" {
  description = "List of NAT Gateway IDs"
  value       = [aws_nat_gateway.vpc_nat_gw.*.id]
}

# Internet Gateway
output "igw_id" {
  description = "The ID of the Internet Gateway"
  value       = element(concat(aws_internet_gateway.vpc_internet_gw.*.id, [""]), 0)
}


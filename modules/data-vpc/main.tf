### Variables

variable "environment" {}

variable "config_name" {}

variable "vpc_name" {}

### Data Sources

data "aws_vpc" "main" {
  tags = {
    Name        = var.vpc_name != "" ? var.vpc_name :"${var.config_name}-${var.environment}-vpc"
    Environment = var.environment
  }
}

data "aws_subnet_ids" "private" {
  vpc_id = data.aws_vpc.main.id

  tags = {
    Environment = var.environment
    Tier        = "private"
  }
}

data "aws_subnet" "private" {
  count = length(data.aws_subnet_ids.private.ids)
  id    = element(tolist(data.aws_subnet_ids.private.ids), count.index)
}

data "aws_subnet_ids" "public" {
  vpc_id = data.aws_vpc.main.id

  tags = {
    Environment = var.environment
    Tier        = "public"
  }
}

data "aws_subnet" "public" {
  count = length(data.aws_subnet_ids.public.ids)
  id    = element(tolist(data.aws_subnet_ids.public.ids), count.index)
}

### outputs

output "vpc_id" {
  value = data.aws_vpc.main.id
}

output "vpc_cidr" {
  value = data.aws_vpc.main.cidr_block
}

output "private_subnet_ids" {
  value = data.aws_subnet_ids.private.ids
}

output "private_subnet_azids" {
  value = sort(
    formatlist(
      "%s:%s",
      data.aws_subnet.private.*.availability_zone,
      data.aws_subnet.private.*.id,
    ),
  )
}

output "private_subnet_cidr" {
  value = data.aws_subnet.private.*.cidr_block
}

output "public_subnet_ids" {
  value = data.aws_subnet_ids.public.ids
}

output "public_subnet_azids" {
  value = sort(
    formatlist(
      "%s:%s",
      data.aws_subnet.public.*.availability_zone,
      data.aws_subnet.public.*.id,
    ),
  )
}

output "public_subnet_cidr" {
  value = data.aws_subnet.public.*.cidr_block
}

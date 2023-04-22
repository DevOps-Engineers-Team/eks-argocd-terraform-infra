resource "aws_vpc" "vpc" {
  cidr_block           = var.cidr
  instance_tenancy     = var.instance_tenancy
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  tags = merge(
    var.tags,
    var.default_tags,
    {
      "Name" = "${var.config_name}-${var.environment}-vpc"
      "Environment" = format("%s", var.environment)
    },
  )
}

resource "aws_internet_gateway" "vpc_internet_gw" {
  count = length(var.public_subnets) > 0 ? 1 : 0

  vpc_id = aws_vpc.vpc.id

  tags = merge(
    var.tags,
    var.default_tags,
    {
      "Name" = "${var.config_name}-${var.environment}-igw"
      "Environment" = format("%s", var.environment)
    },
  )
}

resource "aws_route_table" "public" {
  count = length(var.public_subnets) > 0 ? 1 : 0

  vpc_id = aws_vpc.vpc.id
  propagating_vgws = compact(
    concat(aws_vpn_gateway.vpc_vpn_gw.*.id, var.public_propagating_vgws),
  )

  tags = merge(
    var.tags,
    var.default_tags,
    var.public_route_table_tags,
    {
      "Name"        = "${var.config_name}-${var.environment}-public-rt"
      "Environment" = var.environment
    },
  )
}

resource "aws_route" "public_internet_gateway" {
  count = length(var.public_subnets) > 0 ? 1 : 0

  route_table_id         = aws_route_table.public[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.vpc_internet_gw[0].id
}

resource "aws_route_table" "private" {
  count = length(var.azs)

  vpc_id = aws_vpc.vpc.id
  propagating_vgws = compact(
    concat(
      aws_vpn_gateway.vpc_vpn_gw.*.id,
      var.private_propagating_vgws,
    ),
  )

  tags = merge(
    var.tags,
    var.default_tags,
    var.private_route_table_tags,
    {
       "Name"        = "${var.config_name}-${var.environment}-private-rt${count.index}"
      "Environment" = format("%s", var.environment)
    },
  )
}

resource "aws_subnet" "public" {
  count = length(var.public_subnets)

  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = var.map_public_ip_on_launch

  tags = merge(
    var.tags,
    var.default_tags,
    var.public_subnet_tags,
    {
          "Name" = format("%s-%s-pub-%s-subnet%s",
        var.config_name,
        var.environment,
        substr(var.azs[count.index], -1, -1),
        count.index),
      "Environment" = format("%s", var.environment)
    },
  )
}

resource "aws_subnet" "private" {
  count = length(var.private_subnets)

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = element(var.azs, count.index)

  tags = merge(
    var.tags,
    var.default_tags,
    var.private_subnet_tags,
    {
      "Name" = format("%s-%s-pri-%s-subnet%s",
        var.config_name,
        var.environment,
        substr(var.azs[count.index], -1, -1),
        count.index),
      "Environment" = format("%s", var.environment)
    },
  )
}

resource "aws_eip" "nat" {
  count = var.enable_nat_gateway ? var.single_nat_gateway ? 1 : length(var.azs) : 0

  vpc = true
}

resource "aws_nat_gateway" "vpc_nat_gw" {
  count = var.enable_nat_gateway ? var.single_nat_gateway ? 1 : length(var.azs) : 0

  allocation_id = element(aws_eip.nat.*.id, var.single_nat_gateway ? 0 : count.index)
  subnet_id = element(
    aws_subnet.public.*.id,
    var.single_nat_gateway ? 0 : count.index,
  )

  tags = merge(
    var.tags,
    var.default_tags,
    {
      "Name" = "${var.config_name}-${var.environment}-ngw${count.index}",
      "Environment" = format("%s", var.environment)
    },
  )

  depends_on = [aws_internet_gateway.vpc_internet_gw]
}

resource "aws_route" "private_nat_gateway" {
  count = var.enable_nat_gateway ? length(var.azs) : 0

  route_table_id         = element(aws_route_table.private.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.vpc_nat_gw.*.id, count.index)
}

resource "aws_route_table_association" "private" {
  count = length(var.private_subnets)

  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}

resource "aws_route_table_association" "public" {
  count = length(var.public_subnets)

  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public[0].id
}

resource "aws_vpn_gateway" "vpc_vpn_gw" {
  count = var.enable_vpn_gateway ? 1 : 0

  vpc_id = aws_vpc.vpc.id

  tags = merge(
    var.tags,
    var.default_tags,
    {
      "Name"             = "${var.config_name}-${var.environment}-vgw",
      "Environment"      = var.environment
    },
  )
}

resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.vpc.id
}



resource "aws_iam_instance_profile" "instance_profile" {
  name = "${var.config_name}-${var.environment}-instance-profile"
  role = aws_iam_role.instance-role.name
}

resource "aws_iam_role" "instance-role" {
  name = "${var.config_name}-${var.environment}-vpc-instance-role"
  path = "/"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
         "Service": [ "ec2.amazonaws.com" ]
      },
      "Action": [ "sts:AssumeRole" ]
    }]
}
EOF

}

resource "aws_iam_policy" "ec2-access-policy" {
  name = "${var.config_name}-${var.environment}-ec2-access-ip"
  description = "EC2 full access policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "ec2:*",
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": "elasticloadbalancing:*",
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": "cloudwatch:*",
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": "autoscaling:*",
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": "rds:*",
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": "ses:*",
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": "sns:*",
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": "sqs:*",
      "Resource": "*"
    }
  ]
}
EOF

}

resource "aws_iam_policy_attachment" "policy-attach" {
  name = "${var.config_name}-${var.environment}-iam-pa"
  roles      = [aws_iam_role.instance-role.name]
  policy_arn = aws_iam_policy.ec2-access-policy.arn
}

resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  count = var.enable_vpc_flow_logs ? 1 : 0

  name = var.cloudwatch_vpc_flow_logs_group
  tags = merge(
    var.tags,
    var.default_tags,
    {
      "Name"        = "${var.config_name}-${var.environment}-vpc"
      "Environment" = format("%s", var.environment)
    },
  )
  retention_in_days = local.flow_logs_retention_days
}

resource "aws_iam_role" "cloudwatch_flow_logs_role" {
  count = var.enable_vpc_flow_logs ? 1 : 0

  name = "${var.config_name}-cloudwatch-${var.environment}-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "vpc-flow-logs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "this" {
  count = var.enable_vpc_flow_logs ? 1 : 0

  name = "${var.config_name}-${var.environment}-rp"
  role = aws_iam_role.cloudwatch_flow_logs_role[count.index].id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:logs:*:*:log-group:${var.cloudwatch_vpc_flow_logs_group}",
        "arn:aws:logs:*:*:log-group:${var.cloudwatch_vpc_flow_logs_group}:log-stream:*"
      ]
    }
  ]
}
EOF
}

resource "aws_flow_log" "flow_logs" {
  count = var.enable_vpc_flow_logs ? 1 : 0

  log_destination      = aws_cloudwatch_log_group.vpc_flow_logs[count.index].arn
  iam_role_arn         = aws_iam_role.cloudwatch_flow_logs_role[count.index].arn
  log_destination_type = "cloud-watch-logs"
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.vpc.id
}


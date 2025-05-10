# Copyright Amazon.com, Inc. or its affiliates. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

resource "aws_subnet" "public" {
  for_each = local.azs

  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(local.cidrsubnets[2], 2, each.value.index)
  availability_zone       = each.value.name
  map_public_ip_on_launch = false

  tags = merge(
    { "Name" = "${local.vpc_name}-public-subnet-${each.value.id}" },
    var.tags
  )
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id
  tags = merge(
    { "Name" = "${local.vpc_name}-public-rtb-${var.region_name}" },
    var.tags
  )
}

resource "aws_route_table_association" "public" {
  for_each = local.azs

  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public[each.key].id
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = merge(
    { "Name" = "${local.vpc_name}-igw-${var.region_name}" },
    var.tags
  )
}

resource "aws_eip" "ngw" {
  depends_on = [aws_internet_gateway.igw]
  for_each   = local.azs

  public_ipv4_pool = "amazon"
  tags = merge(
    { "Name" = "${local.vpc_name}-eip-${each.value.id}" },
    var.tags
  )
}

resource "aws_nat_gateway" "ngw" {
  depends_on = [aws_internet_gateway.igw]
  for_each   = local.azs

  connectivity_type = "public"
  allocation_id     = aws_eip.ngw[each.key].id
  subnet_id         = aws_subnet.public[each.key].id
  tags = merge(
    { "Name" = "${local.vpc_name}-ngw-${each.value.id}" },
    var.tags
  )
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  gateway_id             = aws_internet_gateway.igw.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route" "private" {
  for_each = toset(var.private_routes)

  route_table_id         = aws_route_table.public.id
  transit_gateway_id     = aws_ec2_transit_gateway_vpc_attachment.tgw.transit_gateway_id
  destination_cidr_block = each.value
}

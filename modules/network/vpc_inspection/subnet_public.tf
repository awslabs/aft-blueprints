# Copyright Amazon.com, Inc. or its affiliates. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

resource "aws_subnet" "public" {
  for_each = var.enable_egress ? local.azs : {}

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
  for_each = var.enable_egress ? local.azs : {}

  vpc_id = aws_vpc.vpc.id
  tags = merge(
    { "Name" = "${local.vpc_name}-public-rtb-${each.value.id}" },
    var.tags
  )
}

resource "aws_route_table_association" "public" {
  for_each = var.enable_egress ? local.azs : {}

  route_table_id = aws_route_table.public[each.key].id
  subnet_id      = aws_subnet.public[each.key].id
}

resource "aws_internet_gateway" "igw" {
  count = var.enable_egress ? 1 : 0

  vpc_id = aws_vpc.vpc.id
  tags = merge(
    { "Name" = "${local.vpc_name}-igw-${var.region_name}" },
    var.tags
  )
}

resource "aws_eip" "ngw" {
  depends_on = [aws_internet_gateway.igw]
  for_each   = var.enable_egress ? local.azs : {}

  public_ipv4_pool = "amazon"
  tags = merge(
    { "Name" = "${local.vpc_name}-eip-${each.value.id}" },
    var.tags
  )
}

resource "aws_nat_gateway" "ngw" {
  depends_on = [aws_internet_gateway.igw]
  for_each   = var.enable_egress ? local.azs : {}

  connectivity_type = "public"
  allocation_id     = aws_eip.ngw[each.key].id
  subnet_id         = aws_subnet.public[each.key].id
  tags = merge(
    { "Name" = "${local.vpc_name}-ngw-${each.value.id}" },
    var.tags
  )
}

resource "aws_route" "public_igw" {
  for_each = var.enable_egress ? local.azs : {}

  route_table_id         = aws_route_table.public[each.key].id
  gateway_id             = aws_internet_gateway.igw[0].id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route" "public_nfw" {
  depends_on = [aws_subnet.private]
  for_each   = var.enable_egress ? { for route in local.internal_tgw_routes : "${route.id}_${route.cidr}" => route } : {}

  route_table_id         = aws_route_table.public[each.value.id].id
  vpc_endpoint_id        = element([for e in local.nfw_endpoints : e.id if e.az_name == "${each.value.az_name}"], 0)
  destination_cidr_block = each.value.cidr
}

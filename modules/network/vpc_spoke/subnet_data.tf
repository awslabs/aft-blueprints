# Copyright Amazon.com, Inc. or its affiliates. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

resource "aws_subnet" "data" {
  for_each = var.create_data_subnets ? local.azs : {}

  vpc_id                  = aws_vpc.this.id
  cidr_block              = cidrsubnet(local.cidrsubnets[1], local.newbits, each.value.index)
  availability_zone       = each.value.name
  map_public_ip_on_launch = false
  tags = merge(
    { "Name" = "${local.vpc_name}-data-subnet-${each.value.id}" },
    var.tags,
    var.data_subnet_tags
  )
}

resource "aws_route_table_association" "data" {
  for_each = var.create_data_subnets ? local.azs : {}

  route_table_id = aws_route_table.private[each.key].id
  subnet_id      = aws_subnet.data[each.key].id
}

# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

resource "aws_subnet" "subnets" {
  for_each   = { for subnet in local.subnets : subnet.key => subnet }
  depends_on = [aws_vpc.this]

  vpc_id            = aws_vpc.this.id
  cidr_block        = cidrsubnet(aws_vpc.this.cidr_block, each.value.newbits, each.value.index)
  availability_zone = each.value.az_name
  tags = merge(
    { "Name" = "${local.vpc_name}-${each.value.name}-subnet-${each.value.az_id}" },
    var.tags,
    each.value.tags
  )
}

resource "aws_route_table" "subnets" {
  for_each = { for subnet in local.subnets : subnet.key => subnet }

  vpc_id = aws_vpc.this.id
  tags = merge(
    { "Name" = "${local.vpc_name}-${each.value.name}-rtb-${each.value.az_id}" },
    var.tags
  )
}

resource "aws_route_table_association" "subnets" {
  for_each = { for subnet in local.subnets : subnet.key => subnet }

  subnet_id      = aws_subnet.subnets[each.key].id
  route_table_id = aws_route_table.subnets[each.key].id
}

resource "aws_route" "subnets" {
  for_each   = { for subnet in local.subnets : subnet.key => subnet }
  depends_on = [module.tgw_attachment_automation]

  route_table_id         = aws_route_table.subnets[each.key].id
  transit_gateway_id     = var.use_tgw_attachment_automation ? module.tgw_attachment_automation[0].transit_gateway_id : var.tgw_id
  destination_cidr_block = "0.0.0.0/0"
  timeouts {
    create = "10m"
  }
}


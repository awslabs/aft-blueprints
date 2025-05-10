# Copyright Amazon.com, Inc. or its affiliates. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

resource "aws_vpn_connection" "vpn_connection" {
  customer_gateway_id      = var.customer_gateway_id
  transit_gateway_id       = var.transit_gateway_id
  static_routes_only       = var.static_routes_only
  local_ipv4_network_cidr  = var.local_ipv4_network_cidr
  remote_ipv4_network_cidr = var.remote_ipv4_network_cidr
  type                     = "ipsec.1"
  tags = merge(
    { "Name" = var.connection_name },
    var.tags
  )
  lifecycle {
    ignore_changes = [
      tunnel1_dpd_timeout_action,
      tunnel1_dpd_timeout_seconds,
      tunnel1_enable_tunnel_lifecycle_control,
      tunnel1_ike_versions,
      tunnel1_inside_cidr,
      tunnel1_phase1_dh_group_numbers,
      tunnel1_phase1_encryption_algorithms,
      tunnel1_phase1_integrity_algorithms,
      tunnel1_phase1_lifetime_seconds,
      tunnel1_phase2_dh_group_numbers,
      tunnel1_phase2_encryption_algorithms,
      tunnel1_phase2_integrity_algorithms,
      tunnel1_phase2_lifetime_seconds,
      tunnel1_preshared_key,
      tunnel1_rekey_fuzz_percentage,
      tunnel1_rekey_margin_time_seconds,
      tunnel1_replay_window_size,
      tunnel1_startup_action,
      tunnel2_dpd_timeout_seconds,
      tunnel2_enable_tunnel_lifecycle_control,
      tunnel2_ike_versions,
      tunnel2_inside_cidr,
      tunnel2_phase1_dh_group_numbers,
      tunnel2_phase1_encryption_algorithms,
      tunnel2_phase1_integrity_algorithms,
      tunnel2_phase1_lifetime_seconds,
      tunnel2_phase2_dh_group_numbers,
      tunnel2_phase2_encryption_algorithms,
      tunnel2_phase2_integrity_algorithms,
      tunnel2_phase2_lifetime_seconds,
      tunnel2_preshared_key,
      tunnel2_rekey_fuzz_percentage,
      tunnel2_rekey_margin_time_seconds,
      tunnel2_replay_window_size
    ]
  }
}

resource "aws_ec2_transit_gateway_route_table_association" "this" {
  transit_gateway_attachment_id  = aws_vpn_connection.vpn_connection.transit_gateway_attachment_id
  transit_gateway_route_table_id = var.tgw_rt_association
}

resource "aws_ec2_transit_gateway_route_table_propagation" "this" {
  for_each = var.tgw_rt_propagations

  transit_gateway_attachment_id  = aws_vpn_connection.vpn_connection.transit_gateway_attachment_id
  transit_gateway_route_table_id = each.value
}

resource "aws_ec2_tag" "vpn_attachment" {
  resource_id = aws_vpn_connection.vpn_connection.transit_gateway_attachment_id
  key         = "Name"
  value       = "${var.account_id}-tgw-attach-${var.connection_name}"
}

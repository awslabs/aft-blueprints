# Copyright Amazon.com, Inc. or its affiliates. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

module "s2s_vpn_gw" {
  source = "../../../../common/modules/network/vpn_customer_gateway"

  customer_gateway_name       = "cgw-${var.region_name}"
  customer_gateway_bgp_asn    = var.vpn_cgw_bgp_asn
  customer_gateway_ip_address = var.vpn_cgw_ip_address

}

module "s2s_vpn_connection" {
  source = "../../../../common/modules/network/vpn_s2s_connection"
  depends_on = [
    module.tgw,
    module.s2s_vpn_gw
  ]

  account_id          = var.account_id
  connection_name     = "vpn-conn-${var.region_name}"
  customer_gateway_id = module.s2s_vpn_gw.customer_gateway_id
  transit_gateway_id  = module.tgw.transit_gateway_id
  static_routes_only  = var.vpn_static_routes_only
  tgw_rt_association  = module.tgw.route_table_id["gateway"]
  tgw_rt_propagations = { "security" = module.tgw.route_table_id["security"] }
}

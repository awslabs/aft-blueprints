# Copyright Amazon.com, Inc. or its affiliates. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

aws_ip_address_plan = {
  global_cidr_blocks = ["10.10.0.0/16", "10.20.0.0/16"]
  primary_region = {
    cidr_blocks = ["10.10.0.0/16"]
    shared = {
      cidr_blocks = ["10.10.0.0/18"]
    }
    prod = {
      cidr_blocks = ["10.10.64.0/18"]
    }
    stage = {
      cidr_blocks = ["10.10.128.0/18"]
    }
    dev = {
      cidr_blocks = ["10.10.192.0/18"]
    }
  }
  secondary_region = {
    cidr_blocks = ["10.20.0.0/16"]
    shared = {
      cidr_blocks = ["10.20.0.0/18"]
    }
    prod = {
      cidr_blocks = ["10.20.64.0/18"]
    }
    stage = {
      cidr_blocks = ["10.20.128.0/18"]
    }
    dev = {
      cidr_blocks = ["10.20.192.0/18"]
    }
  }
}

aws_availability_zones = {
  primary_region = {
    az1 = "us-east-1a"
    az2 = "us-east-1b"
  }
  secondary_region = {
    az1 = "us-west-2a"
    az2 = "us-west-2b"
  }
}

aws_vpc_endpoint_services = [
  "ssm",
  "ssmmessages",
  "ec2messages",
  "logs",
  "kms"
]

aws_vpn_info = {
  primary_region = {
    cgw_ip_address = "1.1.1.1"
    cgw_bgp_asn    = 64521
  }
  secondary_region = {
    cgw_ip_address = "2.2.2.2"
    cgw_bgp_asn    = 64522
  }
}

aws_dx_info = {
  gateway_name = "aws-dx-gateway"
  bgp_asn      = "64550"
}


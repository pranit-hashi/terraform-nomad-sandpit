locals {
  region_asn_mapping = {
    "ap-southeast-2" = 64512
    "ap-southeast-1" = 64513
  }
}

resource "aws_ec2_transit_gateway" "this" {
  amazon_side_asn                 = lookup(local.region_asn_mapping, var.region)
  auto_accept_shared_attachments  = "enable"
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"
  dns_support                     = "enable"
  vpn_ecmp_support                = "enable"

  tags = {
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "this" {
  subnet_ids         = module.vpc.private_subnets
  transit_gateway_id = aws_ec2_transit_gateway.this.id
  vpc_id             = module.vpc.vpc_id
  dns_support        = "enable"

  tags = {
  }
}

locals {
  region_asn_mapping = {
    "ap-southeast-2" = 64512
    "ap-southeast-1" = 64513
  }
}

data "aws_ec2_transit_gateway" "region_1" {
  provider = aws.syd

  filter {
    name   = "options.amazon-side-asn"
    values = ["${lookup(local.region_asn_mapping, var.region_1)}"]
  }
}

data "aws_ec2_transit_gateway" "region_2" {
  provider = aws.sgp

  filter {
    name   = "options.amazon-side-asn"
    values = ["${lookup(local.region_asn_mapping, var.region_2)}"]
  }
}

resource "aws_ec2_transit_gateway_peering_attachment" "region_1_to_region_2" {
  provider                = aws.syd

  peer_region             = "ap-southeast-1"
  peer_transit_gateway_id = data.aws_ec2_transit_gateway.region_2.id
  transit_gateway_id      = data.aws_ec2_transit_gateway.region_1.id

  tags = {
  }
}

resource "aws_ec2_transit_gateway_peering_attachment_accepter" "region_2_accepter" {
  provider                      = aws.sgp

  transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.region_1_to_region_2.id

  tags = {
  }
}
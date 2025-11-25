locals {
  region_vpc_cidr_mapping = {
    "ap-southeast-2" = "10.200.0.0/16"
    "ap-southeast-1" = "10.210.0.0/16"
  }
}

data "aws_vpc" "region_1" {
  provider = aws.syd

  filter {
    name   = "tag:Name"
    values = ["${var.deployment_id}-*"]
  }
}

data "aws_vpc" "region_2" {
  provider = aws.sgp

  filter {
    name   = "tag:Name"
    values = ["${var.deployment_id}-*"]
  }
}

data "aws_subnets" "region_1_private" {
  provider = aws.syd

  filter {
    name   = "tag:Name"
    values = ["*private*"]
  }
}

data "aws_subnets" "region_2_private" {
  provider = aws.sgp

  filter {
    name   = "tag:Name"
    values = ["*private*"]
  }
}

data "aws_route_table" "region_1_private" {
  provider = aws.syd

  filter {
    name   = "tag:Name"
    values = ["*private*"]
  }
}

data "aws_route_table" "region_2_private" {
  provider = aws.sgp

  filter {
    name   = "tag:Name"
    values = ["*private*"]
  }
}

resource "aws_ec2_transit_gateway_route" "region_1_to_region_2" {
  provider                       = aws.syd

  destination_cidr_block         = lookup(local.region_vpc_cidr_mapping, var.region_2)
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.region_1_to_region_2.id
  transit_gateway_route_table_id = data.aws_ec2_transit_gateway.region_1.association_default_route_table_id

  depends_on = [
    aws_ec2_transit_gateway_peering_attachment_accepter.region_2_accepter
]
}

resource "aws_route" "region_1_to_region_2" {
  provider               = aws.syd

  route_table_id         = data.aws_route_table.region_1_private.id
  destination_cidr_block = data.aws_vpc.region_2.cidr_block
  transit_gateway_id     = data.aws_ec2_transit_gateway.region_1.id
}

resource "aws_ec2_transit_gateway_route" "region_2_to_region_1" {
  provider                       = aws.sgp
  
  destination_cidr_block         = lookup(local.region_vpc_cidr_mapping, var.region_1)
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.region_1_to_region_2.id
  transit_gateway_route_table_id = data.aws_ec2_transit_gateway.region_2.association_default_route_table_id

  depends_on = [
    aws_ec2_transit_gateway_peering_attachment_accepter.region_2_accepter
  ]
}

resource "aws_route" "region_2_to_region_1" {
  provider               = aws.sgp

  route_table_id         = data.aws_route_table.region_2_private.id
  destination_cidr_block = data.aws_vpc.region_1.cidr_block
  transit_gateway_id     = data.aws_ec2_transit_gateway.region_2.id
}

locals {
  deployment_id = lower("${var.deployment_name}-${random_string.suffix.result}")
}

resource "random_string" "suffix" {
  length  = 4
  special = false
}

# amazon web services (aws) infrastructure region 1

module "infra-aws-region-1" {
  source = "./01-prerequisites/aws"
  
  providers = {
    aws = aws.syd
  }

  region        = var.aws_region_1
  deployment_id = "${local.deployment_id}-region-1"
  vpc_cidr      = "10.200.0.0/16"
}

# amazon web services (aws) infrastructure region 2

module "infra-aws-region-2" {
  source = "./01-prerequisites/aws"
  
  providers = {
    aws = aws.sgp
  }

  deployment_id = "${local.deployment_id}-region-2"
  region        = var.aws_region_2
  vpc_cidr      = "10.210.0.0/16"
}

# amazon web services (aws) transit gateway peering between regions

module "infra-aws-tgw-peering" {
  source = "./01-prerequisites/aws/region-peering"
  
  providers = {
    aws.syd = aws.syd
    aws.sgp = aws.sgp
  }

  deployment_id = local.deployment_id
  region_1      = var.aws_region_1
  region_2      = var.aws_region_2
}

# hashicorp nomad enterprise server ec2 deployment region 1

module "solution-ec2-nomad-server-region-1" {
  source = "./02-solution/ec2/nomad-servers"

  providers = {
    aws = aws.syd
  }

  region                 = var.aws_region_1
  deployment_id          = "${local.deployment_id}-region-1"
  key_pair_private_key   = module.infra-aws-region-1.key_pair_private_key
  bastion_public_fqdn    = module.infra-aws-region-1.bastion_public_fqdn
  nomad_ent_license      = var.nomad_ent_license
  route53_sandbox_prefix = var.aws_route53_sandbox_prefix
  nomad_federation_peer_address = ""
}

# hashicorp nomad enterprise client ec2 deployment region 1

module "solution-ec2-nomad-client-region-1" {
  source = "./02-solution/ec2/nomad-clients"

  providers = {
    aws = aws.syd
  }

  region                 = var.aws_region_1
  deployment_id          = "${local.deployment_id}-region-1"
  key_pair_private_key   = module.infra-aws-region-1.key_pair_private_key
  bastion_public_fqdn    = module.infra-aws-region-1.bastion_public_fqdn
}

# hashicorp nomad enterprise server ec2 deployment region 2

module "solution-ec2-nomad-server-region-2" {
  source = "./02-solution/ec2/nomad-servers"

  providers = {
    aws = aws.sgp
  }

  region                 = var.aws_region_2
  deployment_id          = "${local.deployment_id}-region-2"
  key_pair_private_key   = module.infra-aws-region-2.key_pair_private_key
  bastion_public_fqdn    = module.infra-aws-region-2.bastion_public_fqdn
  nomad_ent_license      = var.nomad_ent_license
  route53_sandbox_prefix = var.aws_route53_sandbox_prefix
  nomad_federation_peer_address = "${module.solution-ec2-nomad-server-region-1.nomad-private-ip}:4648"
}

# hashicorp nomad enterprise client ec2 deployment region 2

module "solution-ec2-nomad-client-region-2" {
  source = "./02-solution/ec2/nomad-clients"

  providers = {
    aws = aws.sgp
  }

  region                 = var.aws_region_2
  deployment_id          = "${local.deployment_id}-region-2"
  key_pair_private_key   = module.infra-aws-region-2.key_pair_private_key
  bastion_public_fqdn    = module.infra-aws-region-2.bastion_public_fqdn
}
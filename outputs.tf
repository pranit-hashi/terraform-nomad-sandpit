# generic outputs

output "deployment_id" {
  description = "deployment identifier"
  value       = local.deployment_id
}

# amazon web services (aws) outputs

output "aws_bastion_public_fqdn_region_1" {
  description = "aws public fqdn of bastion node"
  value       = module.infra-aws-region-1.bastion_public_fqdn
}

output "aws_bastion_public_fqdn_region_2" {
  description = "aws public fqdn of bastion node"
  value       = module.infra-aws-region-2.bastion_public_fqdn
}

# hashicorp nomad outputs

output "nomad-http-api-public-dns-region-1" {
  description = "public dns name of nomad http api region 1"
  value       = "http://${module.solution-ec2-nomad-server-region-1.nomad-http-api-public-dns}:4646"
}

output "nomad-http-api-public-dns-region-2" {
  description = "public dns name of nomad http api region 2"
  value       = "http://${module.solution-ec2-nomad-server-region-2.nomad-http-api-public-dns}:4646"
}
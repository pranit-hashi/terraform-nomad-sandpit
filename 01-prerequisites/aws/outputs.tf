output "key_pair_private_key" {
  description = "private key of key pair"
  value       = module.key_pair.private_key_pem
  sensitive   = true
}

output "bastion_public_fqdn" {
  description = "public fqdn of bastion"
  value       = aws_instance.bastion.public_dns
}

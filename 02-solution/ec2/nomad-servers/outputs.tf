output "nomad-http-api-public-dns" {
  description = "public dns name of nomad http api"
  value       = aws_route53_record.nomad-datacenter.fqdn

}

output "nomad-private-ip" {
  description = "private ip address of nomad server"
  value       = aws_instance.nomad-server.private_ip
}
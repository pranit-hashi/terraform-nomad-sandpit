data "aws_route53_zone" "hashidemos" {
  name         = "${var.route53_sandbox_prefix}.sbx.hashidemos.io."
  private_zone = false
}

resource "aws_route53_record" "nomad-datacenter" {
  zone_id = data.aws_route53_zone.hashidemos.zone_id
  name    = "nomad-${lookup(local.region_friendly_mapping, var.region)}"
  type    = "CNAME"
  ttl     = 300
  records = [aws_lb.nomad-http-api.dns_name]
}
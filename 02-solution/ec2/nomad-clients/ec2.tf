locals {
  region_friendly_mapping = {
    "ap-southeast-2" = "sydney"
    "ap-southeast-1" = "singapore"
  }
}

resource "local_file" "nomad-client-config" {
  content = templatefile("${path.module}/templates/nomad-client-config.hcl.tpl", {
    datacenter = "dc1"
    deployment_id = var.deployment_id
    region     = lookup(local.region_friendly_mapping, var.region)
  })
  filename = "${path.module}/configs/${lookup(local.region_friendly_mapping, var.region)}-client-config.hcl.tmp"
}

data "archive_file" "config-bundle" {
  type        = "zip"
  source_dir = "${path.module}/configs"
  output_path = "${path.module}/config-bundle/${lookup(local.region_friendly_mapping, var.region)}-client-config-bundle.zip.tmp"

  depends_on = [
    local_file.nomad-client-config
  ]
}

data "aws_ami" "nomad" {
  most_recent      = true
  owners           = ["self"]

  filter {
    name   = "name"
    values = ["nomad-ubuntu-*"]
  }

  filter {
    name   = "tag:application"
    values = ["nomad"]
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "tag:Name"
    values = ["*private*"]
  }
}

resource "aws_instance" "nomad-client" {
  ami                  = data.aws_ami.nomad.id
  instance_type        = "t2.large"
  iam_instance_profile = aws_iam_instance_profile.nomad-join.name
  key_name             = var.deployment_id
  subnet_id            = element(data.aws_subnets.private.ids, 1)
  security_groups      = [data.aws_security_group.sg-ssh.id, module.sg-nomad-client.security_group_id]

  lifecycle {
    ignore_changes = all
  }
  
  tags = {
    Name  = "${var.deployment_id}-nomad-client"
  }

  connection {
    host          = aws_instance.nomad-client.private_dns
    user          = "ubuntu"
    agent         = false
    private_key   = var.key_pair_private_key
    bastion_host  = var.bastion_public_fqdn
  }

  provisioner "file" {
    source      = data.archive_file.config-bundle.output_path
    destination = "/var/tmp/nomad-client-config-bundle.zip"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mkdir /var/tmp/nomad-client-configs",
      "sudo unzip -d /var/tmp/nomad-client-configs /var/tmp/nomad-client-config-bundle.zip",
      "sudo cp /var/tmp/nomad-client-configs/${lookup(local.region_friendly_mapping, var.region)}-client-config.hcl.tmp /opt/nomad/config/config.hcl",
      "sudo /opt/nomad/bin/run-nomad"
    ]
  }
}
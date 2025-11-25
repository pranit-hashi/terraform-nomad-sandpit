locals {
  region_friendly_mapping = {
    "ap-southeast-2" = "sydney"
    "ap-southeast-1" = "singapore"
  }
}

resource "local_file" "nomad-server-config" {
  content = templatefile("${path.module}/templates/nomad-ent-server-config.hcl.tpl", {
    datacenter = "dc1"
    region     = lookup(local.region_friendly_mapping, var.region)
    nomad_federation_peer_address = var.nomad_federation_peer_address
  })
  filename = "${path.module}/configs/${lookup(local.region_friendly_mapping, var.region)}-server-config.hcl.tmp"
}

resource "local_file" "nomad-ent-license" {
  content = var.nomad_ent_license
  filename = "${path.module}/configs/nomad-ent-license.hclic"
}

data "archive_file" "config-bundle" {
  type        = "zip"
  source_dir = "${path.module}/configs"
  output_path = "${path.module}/config-bundle/${lookup(local.region_friendly_mapping, var.region)}-server-config-bundle.zip.tmp"

  depends_on = [
    local_file.nomad-server-config
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

resource "aws_instance" "nomad-server" {
  ami             = data.aws_ami.nomad.id
  instance_type   = "t2.small"
  key_name        = var.deployment_id
  subnet_id       = element(data.aws_subnets.private.ids, 1)
  security_groups = [data.aws_security_group.sg-ssh.id, module.sg-nomad-server.security_group_id]

  lifecycle {
    ignore_changes = all
  }
  
  tags = {
    Name  = "${var.deployment_id}-nomad-server"
  }

  connection {
    host          = aws_instance.nomad-server.private_dns
    user          = "ubuntu"
    agent         = false
    private_key   = var.key_pair_private_key
    bastion_host  = var.bastion_public_fqdn
  }

  provisioner "file" {
    source      = data.archive_file.config-bundle.output_path
    destination = "/var/tmp/nomad-server-config-bundle.zip"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mkdir /var/tmp/nomad-server-configs",
      "sudo unzip -d /var/tmp/nomad-server-configs /var/tmp/nomad-server-config-bundle.zip",
      "sudo cp /var/tmp/nomad-server-configs/${lookup(local.region_friendly_mapping, var.region)}-server-config.hcl.tmp /opt/nomad/config/config.hcl",
      "sudo cp /var/tmp/nomad-server-configs/nomad-ent-license.hclic /opt/nomad/nomad-ent-license.hclic",
      "sudo /opt/nomad/bin/run-nomad"
    ]
  }
}